---
title: Using clangd with the kernel sources
---

# Using clangd

Naturally, the first step is to ensure that `clangd` is correctly integrated 
with your editor. It's always safe to run `clangd` on the command line to 
ensure that it starts up correctly.

This language server requires the existence of a compiler database to inform
itself about include paths and such. The kernel source tree contains a script
to generate one:

```bash-session
$ ./scripts/clang-tools/gen_compile_commands.py
```

This script uses the `*.cmd` files generated by Kbuild, so the kernel must
have been built at least once before in order to succeed.

When the editor is launched, ensure that clangd is executed in the same
directory as the `compile_commands.json` database. For compiling out of tree
(e.g. on Gentoo), this usually means one has to symlink the compiler database
into the source directory:

```bash-session
$ ln -s $PWD/compile_commands.json /usr/src/linux/compiler_commands.json
```
