Programming Haskell without LSP is extremely unpleasant.

In general, HLS needs to be compiled with the same version of GHC used by the
project.

Issues often arise if there are multiple tools managing HLS/GHC versions. For
example, Stack wants to (by default) manage its own versions of GHC. This is
really bad for user experience with HLS. It's not clear, but the version of
GHCUp packaged by Gentoo may not provide the hooks to allow GHCUp to manage GHC
versions on behalf of Stack. When used with Lazyvim, Mason will also attempt to
install a version of HLS (equally bad).

Debugging steps:
1. Determine GHC version: `stack exec ghc -- --numeric-version`
  The [stackage server](https://www.stackage.org/) also has a list that
  correlates GHC version to release channel. This will be handy to get all
  projects using the same GHC version.
2. Compile HLS at that version:
```
ghcup list | grep hls | grep recommended
ghcup compile hls -v <hls-version> --ghc <ghc-version>
```
