#include "bundle.h"
#include <lean/lean.h>
#include <raylib.h>
#include <stdint.h>

// leanc doesn't provide string.h
int strcmp(const char *s1, const char *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++;
    s2++;
  }
  return *(const unsigned char *)s1 - *(const unsigned char *)s2;
}

#define IO_UNIT (lean_io_result_mk_ok(lean_box(0)))

size_t resourceInfoSize = sizeof(resource_infos) / sizeof(ResourceInfo);

void *getFileData(char *filename, size_t *size) {
  for (size_t i = 0; i < resourceInfoSize; i++) {
    if (strcmp(resource_infos[i].filename, filename) == 0) {
      *size = resource_infos[i].size;
      return &bundle_data[resource_infos[i].offset];
    }
  }
  return NULL;
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

lean_obj_res getScreenToWorld2D(lean_obj_arg vector2_arg, lean_obj_arg camera_arg) {
  Vector2 worldV = GetScreenToWorld2D(vector2_of_arg(vector2_arg), camera2D_of_arg(camera_arg));
  return vector2_obj_mk(worldV);
}

lean_obj_res getFrameTime(void) {
  return lean_io_result_mk_ok(lean_box_float(GetFrameTime()));
}

lean_obj_res getMouseWheelMove(void) {
  return lean_io_result_mk_ok(lean_box_float(GetMouseWheelMove()));
}

lean_obj_res checkCollisionPointRec(lean_obj_arg vector2_arg, lean_obj_arg rectangle_arg) {
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
