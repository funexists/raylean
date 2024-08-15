# raylean

Lean4 bindings for [raylib](http://www.raylib.com/).

## Community

If you want to contribute to Raylean, you can find us on [Discord](https://discord.gg/mdgKuGAMQj) <a href="https://discord.gg/mdgKuGAMQj"><img alt="Discord" title="Raylean's Discord" height="16" width="16" src="./resources/discord.svg"/></a>

## How build the demo executable target (MacOS only)

The project comes with a demo executable target. To build and run this use the provided [justfile](./justfile).

For now only macOS is supported.

### Dependencies

Raylean has several dependencies:

* [Lean](https://lean-lang.org), which we use for development of games.
* [Just](https://github.com/casey/just), as a replacement for Make.
* XCode for macOS SDK frameworks like OpenGL.
* [Rust](https://www.rust-lang.org/) for building resvg, which provides SVG support.

You need to install all four to build Raylean. Below follows instructions for each.

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

#### [Rust](https://www.rust-lang.org/)

```sh
curl https://sh.rustup.rs -sSf | sh
```

Or use the [official documentation](https://www.rust-lang.org/tools/install) to setup Rust.

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
| [Asset.svg](./resources/Asset.svg)   | [Liza Schulze](https://www.linkedin.com/in/lizaschulze/) |

