---
title: Compiler Resources
---

# Type Systems
* [Thunderseethe's Devlog Series on Making a Language][9]

# LLVM
* [LLVM Language Reference Manual](https://llvm.org/docs/LangRef.html)
* [LLVM API Reference](https://llvm.org/doxygen/)
* [Official LLVM Kaleidoscope Tutorial](https://llvm.org/docs/tutorial/)
* [isuckatcs: How to Compile your Language][2]

# Parsing
* [Compiling to Assembly from Scratch: Chapter 5: Parser Combinators][1]
* [Parsing with OCamllex and Menhir][13]
* [Menhir manual][14]

# Compiler Architecture
* [Rust Compiler Development Guide: Overview of the Compiler][15]

# OCaml
* [Command-Line Parsing][16]
* [Building OCaml Packages with Nix][17]

How to Generate the OCamldoc for packages within a Nix flake. As long as both
`odoc` and `ocamlfind` are included in the flake, as well as any packages that
you want to generate the documentation for are also installed in the flake.

```
odig doc --lib-dir=$(ocamlfind query llvm)/.. -u
```

# Proof Assistants
* [Loogle][11]
* [Functional Programming in Lean][3]
* [Theorem Proving in Lean4][4]
* [The Lean Language Reference][5]
* [Debugging Lean Programs][12]
* [The Mechanics of Proof][6]
* [The Hitchhiker's Guide to Logical Verification][7]
* [Certified Programming with Dependent Types][8]
* [Neovim Lean Abbreviations][10]

# Operating Systems
* [Memfault: Cortex-M RTOS Context Switching][18]
* [GCC Inline Assembly Language in C][19]
* [ARM Procedure Call Standard][20]
* [ARMv7-M Architecture Reference Manual][21]
* [Libaco: Asynchronous Coroutine Library in C][22]
* [minicoro: Single header stackul cross-platform coroutine library][23]

[1]: https://keleshev.com/compiling-to-assembly-from-scratch/05-parser-combinators
[2]: https://isuckatcs.github.io/how-to-compile-your-language/
[3]: https://lean-lang.org/functional_programming_in_lean/
[4]: https://leanprover.github.io/theorem_proving_in_lean4/
[5]: https://lean-lang.org/doc/reference/latest/
[6]: https://hrmacbeth.github.io/math2001/
[7]: https://cs.brown.edu/courses/cs1951x/static_files/main.pdf
[8]: http://adam.chlipala.net/cpdt/
[9]: https://thunderseethe.dev/series/making-a-language/
[10]: https://github.com/Julian/lean.nvim/blob/main/vscode-lean/abbreviations.json
[11]: https://loogle.lean-lang.org/
[12]: https://github.com/leanprover/lean4/blob/master/doc/dev/debugging.md
[13]: https://dev.realworldocaml.org/parsing-with-ocamllex-and-menhir.html
[14]: https://gallium.inria.fr/~fpottier/menhir/manual.pdf
[15]: https://rustc-dev-guide.rust-lang.org/overview.html
[16]: https://dev.realworldocaml.org/command-line-parsing.html
[17]: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/ocaml.section.md
[18]: https://interrupt.memfault.com/blog/cortex-m-rtos-context-switching#context-switching
[19]: https://gcc.gnu.org/onlinedocs/gcc/Using-Assembly-Language-with-C.html
[20]: https://developer.arm.com/documentation/102374/0103/Procedure-Call-Standard?lang=en
[21]: https://developer.arm.com/documentation/ddi0403/ee/?lang=en
[22]: https://libaco.org/docs
[23]: https://github.com/edubart/minicoro
