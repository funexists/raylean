#include <lean/lean.h>
#include <raylib.h>
#include <resvg.h>
#include <stdint.h>

#define IO_UNIT (lean_io_result_mk_ok(lean_box(0)))

// leanc doesn't provide stdlib.h
void *memcpy(void *, const void *, size_t);
void *malloc(size_t);
void *calloc(size_t, size_t);

// leanc doesn't provide string.h
int strcmp(const char *s1, const char *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++;
    s2++;
  }
  return *(const unsigned char *)s1 - *(const unsigned char *)s2;
}

#ifdef RAYLEAN_NO_BUNDLE

void bundle_free_resource(void *data) {
  UnloadFileData(data);
}

void* bundle_load_resource(const char* filepath, size_t *size) {
  int dataSize;
  void* data = (void*) LoadFileData(filepath, &dataSize);
  *size = dataSize;
  return data;
}

#else

#include "bundle.h"

// The number of resources stored in the bundle
size_t resourceInfoSize = sizeof(resource_infos) / sizeof(ResourceInfo);

void bundle_free_resource(void *data) {}

// Load data from from the bundle
void *bundle_load_resource(const char *filename, size_t *size) {
  for (size_t i = 0; i < resourceInfoSize; i++) {
    if (strcmp(resource_infos[i].filename, filename) == 0) {
      *size = resource_infos[i].size;
      return (void*) &bundle_data[resource_infos[i].offset];
    }
  }
  return NULL;
}

#endif

static inline lean_obj_res string_io_error(const char *msg) {
  return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string(msg)));
}

/* TEXTURE */

static lean_external_class *raylib_texture2d_class = NULL;

// The finalizer is run by the lean runtime when a Texture2D is garbage
// collected
static void raylib_texture2d_finalizer(void *texture2d) {
  UnloadTexture(*(Texture2D *)texture2d);
  lean_free_small(texture2d);
}

static void raylib_texture2d_foreach(void *mod, b_lean_obj_arg fn) {}

static lean_external_class *get_raylib_texture2d_class(void) {
  if (raylib_texture2d_class == NULL) {
    raylib_texture2d_class = lean_register_external_class(
        &raylib_texture2d_finalizer, &raylib_texture2d_foreach);
  }
  return raylib_texture2d_class;
}

static inline Texture2D *texture2d_of_arg(b_lean_obj_arg texture2d) {
  return (Texture2D *)lean_get_external_data(texture2d);
}

static lean_object *texture2d_obj_mk(Texture2D texture2d) {
  // Allocate a pointer to the Texture2D struct on the heap
  Texture2D *texture2d_ptr = (void *)lean_alloc_small_object(sizeof(Texture2D));
  if (texture2d_ptr == NULL) {
    return string_io_error("texture2d_obj_mk: lean_alloc_small_object failed");
  }
  *texture2d_ptr = texture2d;
  // Register the Texture2D pointer in the Lean runtime
  return lean_alloc_external(get_raylib_texture2d_class(),
                             (void *)texture2d_ptr);
}

lean_obj_res texture2d_width(b_lean_obj_arg texture) {
  return lean_uint32_to_nat(texture2d_of_arg(texture)->width);
}

lean_obj_res texture2d_height(b_lean_obj_arg texture) {
  return lean_uint32_to_nat(texture2d_of_arg(texture)->height);
}

/* IMAGE  */

static lean_external_class *raylib_image_class = NULL;

// The finalizer is run by the lean runtime when an Image is garbage collected
static void raylib_image_finalizer(void *image) {
  UnloadImage(*(Image *)image);
  lean_free_small(image);
}

static void raylib_image_foreach(void *mod, b_lean_obj_arg fn) {}

static lean_external_class *get_raylib_image_class(void) {
  if (raylib_image_class == NULL) {
    raylib_image_class = lean_register_external_class(&raylib_image_finalizer,
                                                      &raylib_image_foreach);
  }
  return raylib_image_class;
}

static inline Image *image_of_arg(b_lean_obj_arg image) {
  return (Image *)lean_get_external_data(image);
}

static lean_object *image_obj_mk(Image image) {
  // Allocate a pointer to the Image struct on the heap
  Image *image_ptr = (void *)lean_alloc_small_object(sizeof(Image));
  if (image_ptr == NULL) {
    return string_io_error("image_obj_mk: lean_alloc_small_object failed");
  }
  *image_ptr = image;
  // Register the Image pointer in the Lean runtime
  return lean_alloc_external(get_raylib_image_class(), (void *)image_ptr);
}

lean_obj_res image_width(b_lean_obj_arg image) {
  return lean_uint32_to_nat(image_of_arg(image)->width);
}

lean_obj_res image_height(b_lean_obj_arg image) {
  return lean_uint32_to_nat(image_of_arg(image)->height);
}


#ifdef RAYLEAN_NO_RESVG

Image loadImageFromData(const char *ext, const char *data, size_t size) {
  return LoadImageFromMemory(ext, (unsigned char *)data, size);
}

#else

Image loadImageFromData(const char *ext, const char *data, size_t size) {
  if (strcmp(".svg", ext) == 0 || strcmp(".SVG", ext) == 0) {
    Image image = {0};
    resvg_options *opt = resvg_options_create();
    resvg_render_tree *tree;
    int err = resvg_parse_tree_from_data(data, size, opt, &tree);
    resvg_options_destroy(opt);

    if (err != RESVG_OK) {
      TraceLog(LOG_ERROR, "resvg error: %i", err);
      resvg_tree_destroy(tree);
      return image;
    }

    resvg_size size = resvg_get_image_size(tree);
    int width = (int)size.width;
    int height = (int)size.height;

    TraceLog(LOG_INFO, "resvg calculated width: %i, height: %i", width, height);

    // Uses calloc here because the data should contain "premultiplied pixels" so
    // perhaps it's assumed it's initialized memory.
    //
    // The size is specified in the resvg docs.
    //
    // We use RL_CALLOC instead of calloc because UnloadImage uses RL_FREE.
    char *img = (char *) RL_CALLOC(width * height * 4, sizeof(char));
    resvg_render(tree, resvg_transform_identity(), width, height, img);
    resvg_tree_destroy(tree);

    image.data = img;
    image.width = width;
    image.height = height;
    image.mipmaps = 1;
    image.format = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
    return image;
  } else {
    return LoadImageFromMemory(ext, (unsigned char *)data, size);
  }
}


#endif

// Load an image from a resource
// Resources are loaded from the resources/ directory in the project
lean_obj_res loadImage(b_lean_obj_arg resource_name_arg) {
  // Load the data associated with the resource from the bundle
  const char *resource_name = lean_string_cstr(resource_name_arg);
  size_t size;
  const char *data = bundle_load_resource(resource_name, &size);
  if (data == NULL) {
    return string_io_error("loadImage: getFileData failed");
  }

  // Extract the extension from the resource_name
  const char *ext = GetFileExtension(resource_name);
  if (ext == NULL) {
    return string_io_error("loadImage: GetFileExtension failed");
  }

  Image image = loadImageFromData(ext, data, size);

  bundle_free_resource((void*) data);

  if (!IsImageReady(image)) {
    return string_io_error("loadImage: LoadImageFromMemory failed");
  }

  lean_object *image_lean = image_obj_mk(image);
  if (image_lean == NULL) {
    return string_io_error("loadImage: image_obj_mk failed");
  }

  return lean_io_result_mk_ok(image_lean);
}

static inline Color color_of_arg(lean_obj_arg color) {
  uint8_t r = lean_ctor_get_uint8(color, 0);
  uint8_t g = lean_ctor_get_uint8(color, 1);
  uint8_t b = lean_ctor_get_uint8(color, 2);
  uint8_t a = lean_ctor_get_uint8(color, 3);
  return (Color){r, g, b, a};
}

static inline Vector2 vector2_of_arg(lean_obj_arg vector2) {
  double x = lean_ctor_get_float(vector2, 0);
  double y = lean_ctor_get_float(vector2, sizeof(double));
  return (Vector2){x, y};
}

static inline lean_object *vector2_obj_mk(Vector2 vector2) {
  lean_object *vector2_obj = lean_alloc_ctor(0, 0, sizeof(double) * 2);
  lean_ctor_set_float(vector2_obj, 0, vector2.x);
  lean_ctor_set_float(vector2_obj, sizeof(double), vector2.y);
  return vector2_obj;
}

static inline Vector3 vector3_of_arg(lean_obj_arg vector3) {
  double x = lean_ctor_get_float(vector3, 0);
  double y = lean_ctor_get_float(vector3, sizeof(double));
  double z = lean_ctor_get_float(vector3, sizeof(double) * 2);
  return (Vector3){x, y, z};
}

static inline lean_object *vector3_obj_mk(Vector3 vector3) {
  lean_object *vector3_obj = lean_alloc_ctor(0, 0, sizeof(double) * 3);
  lean_ctor_set_float(vector3_obj, 0, vector3.x);
  lean_ctor_set_float(vector3_obj, sizeof(double), vector3.y);
  lean_ctor_set_float(vector3_obj, sizeof(double) * 2, vector3.z);
  return vector3_obj;
}

static inline Rectangle rectangle_of_arg(lean_obj_arg rectangle) {
  double x = lean_ctor_get_float(rectangle, 0);
  double y = lean_ctor_get_float(rectangle, sizeof(double));
  double width = lean_ctor_get_float(rectangle, sizeof(double) * 2);
  double height = lean_ctor_get_float(rectangle, sizeof(double) * 3);
  return (Rectangle){x, y, width, height};
}

static inline Camera3D camera3D_of_arg(lean_obj_arg camera) {
  Vector3 position = vector3_of_arg(lean_ctor_get(camera, 0));
  Vector3 target = vector3_of_arg(lean_ctor_get(camera, 1));
  Vector3 up = vector3_of_arg(lean_ctor_get(camera, 2));
  float fovy = lean_ctor_get_float(camera, sizeof(void *) * 3);
  CameraProjection projection =
      lean_ctor_get_uint8(camera, sizeof(void *) * 3 + sizeof(double));
  return (Camera3D){position, target, up, fovy, projection};
}

void camera3D_obj_init(lean_obj_arg camera_arg, Camera3D camera) {
  lean_ctor_set(camera_arg, 0, vector3_obj_mk(camera.position));
  lean_ctor_set(camera_arg, 1, vector3_obj_mk(camera.target));
  lean_ctor_set(camera_arg, 2, vector3_obj_mk(camera.up));
  lean_ctor_set_float(camera_arg, sizeof(void *) * 3, camera.fovy);
  lean_ctor_set_uint8(camera_arg, sizeof(void *) * 3 + sizeof(double),
                      camera.projection);
}

void camera3D_obj_update(lean_obj_arg camera_arg, Camera3D camera) {
  lean_dec_ref(lean_ctor_get(camera_arg, 0));
  lean_dec_ref(lean_ctor_get(camera_arg, 1));
  lean_dec_ref(lean_ctor_get(camera_arg, 2));
  camera3D_obj_init(camera_arg, camera);
}

static inline lean_object *camera3D_obj_mk(Camera3D camera) {
  lean_object *camera_obj = lean_alloc_ctor(0, 3, sizeof(double) + 1);
  camera3D_obj_init(camera_obj, camera);
  return camera_obj;
}

static inline Camera2D camera2D_of_arg(lean_obj_arg camera) {
  Vector2 offset = vector2_of_arg(lean_ctor_get(camera, 0));
  Vector2 target = vector2_of_arg(lean_ctor_get(camera, 1));
  double rotation = lean_ctor_get_float(camera, sizeof(void *) * 2);
  double zoom =
      lean_ctor_get_float(camera, sizeof(void *) * 2 + sizeof(double));
  return (Camera2D){offset, target, rotation, zoom};
}

lean_obj_res getRandomValue(uint32_t min, uint32_t max)
    __attribute__((optnone)) {
  // BUG: This always seems to return `min`
  return lean_io_result_mk_ok(lean_box_uint32(GetRandomValue(min, max)));
}

lean_obj_res initWindow(lean_obj_arg width, lean_obj_arg height,
                        b_lean_obj_arg title) {
  InitWindow(lean_uint32_of_nat_mk(width), lean_uint32_of_nat_mk(height),
             lean_string_cstr(title));
  return IO_UNIT;
}

lean_obj_res windowShouldClose(void) {
  return lean_io_result_mk_ok(lean_box(WindowShouldClose()));
}

lean_obj_res closeWindow(void) {
  CloseWindow();
  return IO_UNIT;
}

lean_obj_res beginDrawing(void) {
  BeginDrawing();
  return IO_UNIT;
}

lean_obj_res endDrawing(void) {
  EndDrawing();
  return IO_UNIT;
}

lean_obj_res clearBackground(lean_obj_arg color) {
  ClearBackground(color_of_arg(color));
  return IO_UNIT;
}

lean_obj_res setTargetFPS(lean_obj_arg fps) {
  SetTargetFPS(lean_uint32_of_nat_mk(fps));
  return IO_UNIT;
}

lean_obj_res drawFPS(lean_obj_arg posX, lean_obj_arg posY) {
  DrawFPS(lean_uint32_of_nat_mk(posX), lean_uint32_of_nat_mk(posY));
  return IO_UNIT;
}

lean_obj_res drawText(b_lean_obj_arg text, lean_obj_arg posX, lean_obj_arg posY,
                      lean_obj_arg fontSize, lean_obj_arg color) {
  DrawText(lean_string_cstr(text), lean_uint32_of_nat_mk(posX),
           lean_uint32_of_nat_mk(posY), lean_uint32_of_nat_mk(fontSize),
           color_of_arg(color));
  return IO_UNIT;
}

lean_obj_res drawCircleV(lean_obj_arg center, double radius,
                         lean_obj_arg color) {
  Vector2 centerV = vector2_of_arg(center);
  Color colorArg = color_of_arg(color);
  DrawCircleV(centerV, radius, colorArg);
  return IO_UNIT;
}

lean_obj_res isKeyDown(lean_obj_arg key) {
  bool res = IsKeyDown(lean_uint32_of_nat_mk(key));
  return lean_io_result_mk_ok(lean_box(res));
}

lean_obj_res endMode2D(void) {
  EndMode2D();
  return IO_UNIT;
}

lean_obj_res beginMode2D(lean_obj_arg camera) {
  BeginMode2D(camera2D_of_arg(camera));
  return IO_UNIT;
}

lean_obj_res endMode3D(void) {
  EndMode3D();
  return IO_UNIT;
}

lean_obj_res beginMode3D(lean_obj_arg camera) {
  BeginMode3D(camera3D_of_arg(camera));
  return IO_UNIT;
}

lean_obj_res drawCube(lean_obj_arg position, double width, double height,
                      double length, lean_obj_arg color) {
  DrawCube(vector3_of_arg(position), width, height, length,
           color_of_arg(color));
  return IO_UNIT;
}

lean_obj_res drawCubeWires(lean_obj_arg position, double width, double height,
                           double length, lean_obj_arg color) {
  DrawCubeWires(vector3_of_arg(position), width, height, length,
                color_of_arg(color));
  return IO_UNIT;
}

lean_obj_res drawGrid(lean_obj_arg slices, double spacing) {
  DrawGrid(lean_uint32_of_nat_mk(slices), spacing);
  return IO_UNIT;
}

lean_obj_res disableCursor(void) {
  DisableCursor();
  return IO_UNIT;
}

lean_obj_res updateCamera(lean_obj_arg camera_arg, uint8_t mode) {
  Camera3D camera = camera3D_of_arg(camera_arg);
  UpdateCamera(&camera, mode);
  if (lean_is_exclusive(camera_arg)) {
    camera3D_obj_update(camera_arg, camera);
    return lean_io_result_mk_ok(camera_arg);
  } else {
    lean_dec_ref(camera_arg);
    return lean_io_result_mk_ok(camera3D_obj_mk(camera));
  }
}

lean_obj_res drawRectangleRec(lean_obj_arg rectangle_arg,
                              lean_obj_arg color_arg) {
  DrawRectangleRec(rectangle_of_arg(rectangle_arg), color_of_arg(color_arg));
  return IO_UNIT;
}

lean_obj_res getScreenToWorld2D(lean_obj_arg vector2_arg,
                                lean_obj_arg camera_arg) {
  Vector2 worldV = GetScreenToWorld2D(vector2_of_arg(vector2_arg),
                                      camera2D_of_arg(camera_arg));
  return vector2_obj_mk(worldV);
}

lean_obj_res getFrameTime(void) {
  return lean_io_result_mk_ok(lean_box_float(GetFrameTime()));
}

lean_obj_res getMouseWheelMove(void) {
  return lean_io_result_mk_ok(lean_box_float(GetMouseWheelMove()));
}

lean_obj_res checkCollisionPointRec(lean_obj_arg vector2_arg,
                                    lean_obj_arg rectangle_arg) {
  Vector2 v = vector2_of_arg(vector2_arg);
  Rectangle r = rectangle_of_arg(rectangle_arg);
  return lean_io_result_mk_ok(lean_box(CheckCollisionPointRec(v, r)));
}

lean_obj_res isMouseButtonPressed(uint8_t button) {
  return lean_io_result_mk_ok(lean_box(IsMouseButtonPressed(button)));
}

lean_obj_res getMousePosition(void) {
  return lean_io_result_mk_ok(vector2_obj_mk(GetMousePosition()));
}

lean_obj_res loadTextureFromImage(b_lean_obj_arg image_arg) {
  Image *image = image_of_arg(image_arg);
  Texture2D texture = LoadTextureFromImage(*image);
  lean_obj_res texture2d_lean = texture2d_obj_mk(texture);
  if (texture2d_lean == NULL) {
    return string_io_error("loadTextureFromImage: texture2d_obj_mk failed");
  }
  return lean_io_result_mk_ok(texture2d_lean);
}

lean_obj_res drawTexture(b_lean_obj_arg texture_arg, lean_obj_arg posX_arg,
                         lean_obj_arg posY_arg, lean_obj_arg tint_arg) {
  Texture2D *texture = texture2d_of_arg(texture_arg);
  int posX = lean_uint32_of_nat_mk(posX_arg);
  int posY = lean_uint32_of_nat_mk(posY_arg);
  Color tint = color_of_arg(tint_arg);
  DrawTexture(*texture, posX, posY, tint);
  return IO_UNIT;
}

lean_obj_res drawTexturePro(b_lean_obj_arg texture_arg,
                            lean_obj_arg source_rect_arg,
                            lean_obj_arg dest_rect_arg, lean_obj_arg origin_arg,
                            double rotation, lean_obj_arg tint_arg) {
  Texture2D *texture = texture2d_of_arg(texture_arg);
  Rectangle source = rectangle_of_arg(source_rect_arg);
  Rectangle dest = rectangle_of_arg(dest_rect_arg);
  Vector2 origin = vector2_of_arg(origin_arg);
  Color tint = color_of_arg(tint_arg);
  DrawTexturePro(*texture, source, dest, origin, rotation, tint);
  return IO_UNIT;
}

lean_obj_res drawLineV(lean_obj_arg startPos_arg, lean_obj_arg endPos_arg, lean_obj_arg color_arg) {
  Vector2 startPos = vector2_of_arg(startPos_arg);
  Vector2 endPos = vector2_of_arg(endPos_arg);
  Color color = color_of_arg(color_arg);
  DrawLineV(startPos, endPos, color);
  return IO_UNIT;
}

lean_obj_res drawLineStrip(b_lean_obj_arg points_arg, lean_obj_arg color_arg) {
  size_t pointCount = lean_array_size(points_arg);
  Vector2* points = malloc(pointCount * sizeof(Vector2));
  for (size_t i = 0; i < pointCount; i++) {
    points[i] = vector2_of_arg(lean_array_get_core(points_arg, i));
  }
  DrawLineStrip(points, pointCount, color_of_arg(color_arg));
  free(points);
  return IO_UNIT;
}

lean_obj_res drawPixelV(lean_obj_arg position_arg, lean_obj_arg color_arg) {
  Vector2 position = vector2_of_arg(position_arg);
  Color color = color_of_arg(color_arg);
  DrawPixelV(position, color);
  return IO_UNIT;
}
