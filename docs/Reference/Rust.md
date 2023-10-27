---
title: Rust Development
---

# On Gentoo

On Gentoo, the `dev-util/rustup` package provides the `rustup` utility to
manage Rust toolchains. Run the `rustup-init-gentoo` script to set up the
necessary symlinks, and install either the `dev-lang/rust` or
`dev-lang/rust-bin` packages. All of this will set up the "gentoo" toolchain,
which can be used as the system rust toolchain:

```
$ rustup toolchain list
gentoo (default)
```

This is a custom toolchain--which means that `rustup` cannot be used to add
components. This is done via USE flags in the corresponding packages:

```
$ equery uses dev-lang/rust-bin
[ Legend : U - final flag setting for installation]
[        : I - package is installed with flag     ]
[ Colors : set, unset                             ]
 * Found these USE flags for dev-lang/rust-bin-1.73.0:
 U I
 + + clippy        : Install clippy, Rust code linter
 + + rust-analyzer : Install rust-analyzer, A Rust compiler front-end for IDEs
                     (language server)
 + + rust-src      : Install rust-src, needed by developer tools and for build-std
                     (cross)
 + + rustfmt       : Install rustfmt, Rust code formatter
 - - verify-sig    : Verify upstream signatures on distfiles
```

We can, however, add new toolchains:

```
rustup install stable
```

This creates the stable toolchain, which we can add components to:

```
rustup target add thumbv7m-none-eabi --toolchain stable-aarch64-unknown-linux-gnu
```

And use for some version control checkouts with `rustup override`:

```
rustup override set stable
```

# rust-analyzer Bug in rustup

There's currently an issue with rustup that create the following erroneous
output while attempting to run `rust-analyzer` in some circumstances:

```bash-session
$ rust-analyzer
error: unknown proxy name: 'rust-analyzer'; valid proxy names are 'rustc', 'rustdoc', 'cargo', 'rust-lldb', 'rust-gdb', 'rust-gdbgui', 'rls', 'cargo-clippy', 'clippy-driver', 'cargo-miri', 'rustfmt', 'cargo-fmt'
```

One way to resolve this is to use `rustup` to execute the tool:

```bash-session
$ rustup run stable rust-analyzer
```

This will run rust-analyzer for the installed `stable` toolchain. Use
`rustup show active-toolchain` to show the name of the active toolcahin
(this respects directory overrides, environment variables, etc.).

Finally, there may be an issue running rust-analyzer for embedded targets,
because rust-analyzer does not respect the contents of .cargo/config.toml.
Use `RUSTFLAGS` to get around this.

```bash-session
RUSTFLAGS="--target thumbv7m-none-eabi" nvim src/main.rs
```
