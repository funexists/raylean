raylib_release_path := join(justfile_directory(), "lib")
raylib_src_path := join(justfile_directory(), "raylib-5.0", "src")
extra_raylib_config_flags := "-DSUPPORT_FILEFORMAT_SVG"
resource_dir := join(justfile_directory(), "resources")
bundle_h_path := join(justfile_directory(), "c", "include", "bundle.h")
makebundle_src_path := join(justfile_directory(), "scripts", "makeBundle.lean")
makebundle_output_path := join(justfile_directory(), "build", "makeBundle")

[private]
default:
    @just --list

# build only the raylib static library
build_raylib:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{raylib_release_path}}/libraylib.a" ]; then
        mkdir -p {{raylib_release_path}}
        # This build differs from the raylib release workflow.
        # We require `-fno-objc-msgsend-selector-stubs` to be set.
        #
        # If this is not set then the clang 15 linker bundled with lean gives the
        # following error:
        #
        #   ld64.lld: error: undefined symbol: _objc_msgSend$update
        #
        # See https://stackoverflow.com/a/74054943
        #
        make -C {{raylib_src_path}} \
            CC=/usr/bin/clang \
            PLATFORM=PLATFORM_DESKTOP \
            RAYLIB_LIBTYPE=STATIC \
            RAYLIB_RELEASE_PATH={{raylib_release_path}} \
            CUSTOM_CFLAGS="{{extra_raylib_config_flags}} -target arm64-apple-macos11 -DGL_SILENCE_DEPRECATION -fno-objc-msgsend-selector-stubs"
    fi

# build both the raylib library and the Lake project
build: build_raylib bundler
    lake build

# clean only the Lake project
clean:
    lake clean

# clean only the raylib build
clean_raylib:
    make -C {{raylib_src_path}} clean
    rm -rf {{raylib_release_path}}

clean_bundler:
    rm -rf {{parent_directory(bundle_h_path)}}
    rm -rf {{parent_directory(makebundle_output_path)}}

# clean both the raylib build and the Lake project
clean_all: clean clean_raylib clean_bundler

# run the demo executable
run: build
    .lake/build/bin/raylib-lean

build-bundler:
    mkdir -p {{parent_directory(makebundle_output_path)}}
    lean -c {{makebundle_output_path}}.c {{makebundle_src_path}}
    leanc {{makebundle_output_path}}.c -o {{makebundle_output_path}}

# run the bundler
bundler: build-bundler
    mkdir -p {{parent_directory(bundle_h_path)}}
    {{makebundle_output_path}} {{resource_dir}} {{bundle_h_path}}
