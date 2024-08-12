# raylib-lean

Lean4 bindings for [raylib](http://www.raylib.com/).

## How build the demo executable target (MacOS only)

The project comes with a demo executable target. To build and run this use the provided [justfile](./justfile).

For now only macOS is supported.

### Dependencies

#### [Lean](https://lean-lang.org)

Use the [official documentation](https://lean-lang.org/lean4/doc/quickstart.html) to setup Lean.

#### [Just command runner](https://github.com/casey/just)

Install using [Homebrew](https://brew.sh) with:

``` sh
brew install just
```

#### XCode Commandline Tools

The macOS clang installation and macOS SDK frameworks like OpenGL are required when linking the executable.

Install by running:

``` sh
xcode-select --install
```

### Build and Run

To build the raylib static library and the demo executable, run the following command in the project:

``` sh
just build
```

To run the demo, run the following command in the project:

``` sh
just run
```

### Assets

Assets used by the demo application are stored in the [resources](./resources) directory.


| Asset                                | Attribution                                              |
|--------------------------------------|----------------------------------------------------------|
| [walter.png](./resources/walter.png) | [Liza Schulze](https://www.linkedin.com/in/lizaschulze/) |

