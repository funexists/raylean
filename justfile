# set to non-empty string to disable use of the resource bundle.
#
# e.g:
#   just disableBundle=yes build
disableBundle := ''

# Flags used to configure the lake build
lake_config_opts := if disableBundle == "" { "-K bundle=on" } else { "" }

# Raylib CUSTOM_FLAGS tailed for the current os
#
# The macos differ from the raylib release workflow.
# We require `-fno-objc-msgsend-selector-stubs` to be set.
#
# If this is not set then the clang 15 linker bundled with lean gives the
# following error:
#
#   ld64.lld: error: undefined symbol: _objc_msgSend$update
#
# See https://stackoverflow.com/a/74054943
#
raylib_os_custom_cflags := if os() == "macos" { "-target arm64-apple-macos11 -DGL_SILENCE_DEPRECATION -fno-objc-msgsend-selector-stubs"  } else { "" }

# Enable extra raylib configuration flags
raylib_config_flags := ""

# Raylib CUSTOM_CFLAGS make parameter
raylib_custom_cflags := raylib_config_flags + " " + raylib_os_custom_cflags

# Raylib CC make paramter
raylib_cc_parameter := if os() == "macos" { "/usr/bin/clang" } else { "gcc" }

# The command used to invoke lake
#
# LEAN_CC is used for linux because the example executable will fail to link if
# raylib is built with a glibc that's incompatible with the one that's bundled
# with leanc.
lake_command := if os() == "linux" { "LEAN_CC=clang lake" } else { "lake" }

static_lib_path := join(justfile_directory(), "lib")
raylib_src_path := join(justfile_directory(), "raylib-5.0", "src")
resource_dir := join(justfile_directory(), "resources")
bundle_h_path := join(justfile_directory(), "c", "include", "bundle.h")
makebundle_src_path := join(justfile_directory(), "scripts", "makeBundle.lean")
makebundle_output_path := join(justfile_directory(), "build", "makeBundle")
resvg_c_api_path := join(justfile_directory(), "resvg-0.43.0", "crates", "c-api")

[private]
default:
    @just --list

check_cargo:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v cargo &> /dev/null
    then
        echo "cargo was not found. Please install rust: https://rustup.rs"
        exit 1
    fi

# build only the resvg static library
build_resvg: check_cargo
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{resvg_c_api_path}}
    cargo build --release
    mkdir -p {{static_lib_path}}
    cp {{resvg_c_api_path}}/../../target/release/libresvg.a {{static_lib_path}}

# build only the raylib static library
build_raylib:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{static_lib_path}}/libraylib.a" ]; then
        mkdir -p {{static_lib_path}}
        make -C {{raylib_src_path}} \
            CC={{raylib_cc_parameter}} \
            PLATFORM=PLATFORM_DESKTOP \
            RAYLIB_LIBTYPE=STATIC \
            RAYLIB_RELEASE_PATH={{static_lib_path}} \
            CUSTOM_CFLAGS="{{raylib_custom_cflags}}"
    fi

# build both the raylib library and the Lake project
build: build_resvg build_raylib bundler
    {{lake_command}} -R {{lake_config_opts}} build

# clean only the Lake project
clean:
    {{lake_command}} clean

clean_static_lib:
    rm -rf {{static_lib_path}}

# clean only the raylib build
clean_raylib:
    make -C {{raylib_src_path}} clean
    rm -rf {{static_lib_path}}/libraylib.a

clean_bundler:
    rm -rf {{parent_directory(bundle_h_path)}}
    rm -rf {{parent_directory(makebundle_output_path)}}

clean_resvg:
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{resvg_c_api_path}}
    cargo clean

# clean both the raylib build and the Lake project
clean_all: clean clean_raylib clean_bundler clean_resvg clean_static_lib

# run the demo executable
run: build
    .lake/build/bin/raylean

build-bundler:
    mkdir -p {{parent_directory(makebundle_output_path)}}
    lean -c {{makebundle_output_path}}.c {{makebundle_src_path}}
    leanc {{makebundle_output_path}}.c -o {{makebundle_output_path}}

# run the bundler
bundler: build-bundler
    mkdir -p {{parent_directory(bundle_h_path)}}
    {{makebundle_output_path}} {{justfile_directory()}} {{resource_dir}} {{bundle_h_path}}
