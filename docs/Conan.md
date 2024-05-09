# Conan

This document goes over creating, uploading, and using C++ packages with the
Conan Package Manager. The examples in this document will make use of Xiph's
FLAC library, but can obviously be extended to any existing (or not!) C++
project.

# Initializing The Package Repository
To begin, create a new Conan package with the `conan new` command. To
initialize a package for the FLAC library, which is (at the time of this
writing) in version 1.3.3, execute the following:

```bash-session
$ conan new flac/1.3.3 -t
```

This will generate a boilerplate `conanfile.py`. The `-t`
directive instructs conan to create a test package that can be used to test the
installation of the package. The documentation on writing the
`conanfile.py` is very complete and legible, but it's generally easier
to begin by copying it from an existing project.

# The Conan Build Process
Generally speaking, the process for developing Conan packages follows a
standard routine:

1. Initialize the package with `conan new`
2. Implement the `source()`, `build()` and `package()` methods, testing each using Conan
   commands along the way.
3. Use `conan create` to simplify the package build process
4. Upload the package to a repository

# The `source()` Method}
This method is used to obtain the sources with which to build the package, if
for example they reside in an online Git repository, etc. For packages created
with the `-s` flag (having integrated sources), this method may not need
to be implemented. The source method for the FLAC package is given below.

```python
  def source(self):
      self.run("git clone https://github.com/xiph/flac")
      self.run("git --git-dir=flac/.git --work-tree=flac checkout {}"
               .format(self.version))
```

To test this method, execute `conan source .`

## The `install()` Method
This method is used to install prerequisites and build requirements. It does
not normally need to be implemented by the user, but it does need to be invoked
between `conan source` and `conan build`. Normal invocation of
this command can be executed with `conan install .`.

If using a profile other than the system default, this is the time to specify
that profile, as in: `conan install . -pr=<profileName>`.

## The `build()` Method
This method is used to build the package resources (e.g. the binaries). Conan
provides a set of helpful generators that can be used to simplify the code that
invokes the build process. For more information on using generators, view the
online documentation.

If there isn't a generator that fits the build needs of the process (which,
I've found, is often the case), Conan provides the `run()` method which
can be used to explicitly invoke commands. This function is essentially a
wrapper for the `os.system()` function. The build method for the FLAC
package is provided here:

```python
  def build(self):
      self.run("./autogen.sh", cwd="flac")
      self.run("autoreconf -i", cwd="flac")
      self.run("automake", cwd="flac")

      options = ["--disable-asm-optimizations"]
      if self.options['static']:
          options.append('--enable-static=yes')
      else:
          options.append('--enable-static=no')

      if self.options['shared']:
          options.append('--enable-shared=yes')
      else:
          options.append('--enable-shared=no')

      if not self.options['ogg']:
          options.append('--disable-ogg')
      self.run(' '.join(["LT_MULTI_MODULE=1", "emconfigure", "./configure"]
                        + options),
               cwd="flac")
      self.run("emmake make -C src/libFLAC", cwd="flac")
      self.run("emmake make -C src/libFLAC++", cwd="flac")
```

## The `package()` Method
This method, for the most part, just copies the build artifacts into a package,
especially by making use of the `copy()` method. Test this method by
invoking `conan package .`. This command also requires the profile to be
specified. The `package()` method for the FLAC package is given below.

```python
  def package(self):
      self.copy("*.h", dst="include/FLAC", src="flac/include/FLAC")
      self.copy("*.h", dst="include/FLAC++", src="flac/include/FLAC++")
      self.copy("libFLAC.a", dst="lib", src="flac/src/libFLAC/.libs/",
                keep_path=False)
      self.copy("libFLAC++.a", dst="lib", src="flac/src/libFLAC++/.libs/",
                keep_path=False)
```

Note that it is VERY IMPORTANT to specify the destination directories correctly
for packaged files, otherwise generators such as `cmake` will not
correctly set library link and include paths. Headers should be placed into a
destination that begins with `include/`, and library files should be
placed into a destination that begins with `lib/`.

## The `export` and `export-pkg` Commands
The `export` command is used to export a package recipe to the local
cache. This allows the package to be used in projects on your system.

The `export-pkg` command, on the other hand, both exports a recipe and
invokes the `package()` method, allowing the package creator to combine
this step with the previous one. If `export-pkg` is used, the profile
must be specified.

## Testing Packages
This topic is very complex and nontrivial, so only the basics will be covered
here. At the minimum, a package test should attempt to include some headers
from the package and instantiate an object of a class exported by the library.
It's easiest to use the `cmake` generator for test projects, as one can
then integrate CTest to implement the testing.

### Setting Up the Test Package
The easiest way to set up the test package is to create the parent package with
the `-t` flag, e.g.: `conan new <pkg>/<version> -t`. This will
create the `test\_package` directory, with some boilerplates that test
a package called `hello`. These boilerplates are useful as references,
but definitely require some modification.

### The Test `conanfile.py`
The `conanfile.py` for a test package is significantly simpler than that
of a normal package. It's necessary to define the `test()` method for
the `conan test` command. The `conanfile.py` for the FLAC test
package is given below. In general, it's better practice to make use of the
Conan generators, however, since this project is built with Emscripten, it's
necessary to invoke the CMake commands directly using `run()`.

```python
  import os
  from conans import ConanFile, CMake, tools

  class FlacTestConan(ConanFile):
      settings = "os", "compiler", "build_type", "arch"
      generators = "cmake"

      def build(self):
          # Current dir is "test_package/build/<build_id>" and CMakeLists.txt
          # is in "test_package"
          self.run('emcmake cmake ../.. -B .')
          self.run('emmake make')

      def test(self):
          os.chdir("bin")
          self.run("node .{}FlacTest.js".format(os.sep))
```

### The Test `CMakeLists.txt`
This file is almost identical to a normal file for a project including packages
managed by Conan. The `CMakeLists.txt` file for the FLAC test package is
given below:

```cmake
  cmake_minimum_required(VERSION 2.8.12)
  project(PackageTest CXX)

  include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
  conan_basic_setup()

  add_executable(FlacTest FlacTest.cpp)
  set_target_properties(FlacTest PROPERTIES
    OUTPUT_NAME "FlacTest"
    SUFFIX ".js")
  target_link_libraries(FlacTest ${CONAN_LIBS})
  target_include_directories(FlacTest PRIVATE
    ${CONAN_INCLUDE_DIRS})
```

### Writing the Tests and Invoking `conan test`
The simplest possible test for the FLAC library is given below. It includes a
file from the package, to ensure that the symbols are reachable, and then
prints a victorious message to `stdout`.

```cpp
  #include <iostream>
  #include <FLAC++/decoder.h>

  int main() {
    std::cout << "It worked!\n";
  }
```

To test the package, invoke the `conan test` command. The invocation
for the FLAC package is provided below.

```bash-session
  conan test -pr=emscripten test_package flac/1.3.3@edtwardy/stable
```

Contrary to previous Conan commands, when executing `conan test`, the
user specifies the path of the `test package`, not of the parent
package, but the reference must be package which is desired to test.

## Putting It All Together: The `create` Command
This command streamlines the build/export process to combine all of the
previous commands (export, source, install, build, package, test) into one
command. The invocation is simple:

```bash-session
  conan create . <reference> -pr <profile>
```

Where `<reference>` is the reference to designate this project (in the
case of the FLAC package, `flac/1.3.3@edtwardy/stable`, or more
generally, `name/version@user/channel`), and `<profile>` is the
profile to use (if necessary).

# Uploading a Package
Once a package has been created, it can be uploaded to a remote using the
`conan upload` command.

```bash-session
  conan upload -r=<remote> --all <reference>
```

In this command, `<remote>` is the name of the remote (See the section
on remotes), and <reference> is the name of the package as it appears in the
local cache (found e.g. by running `conan search`). The `--all`
flag is used to direct conan to upload not only the recipe, but also the
package itself, so that users can download the package without having to build
it on their own system.

# Using Conan Packages in a Project
Once packages are in the local cache or in an existing remote, they can then be
used in projects that implement useful applications. The recommended way of
doing this is to create a file at the root of the project called
`conanfile.txt`. A minimal `conanfile.txt` for a project
utilizing the FLAC package is given below.

```ini
[requires]
flac/1.3.3@edtwardy/stable

[generators]
cmake
```

This file declares that the project requires the FLAC package with the
reference `flac/1.3.3@edtwardy/stable` (the reference must be an exact
match), and that the `cmake` generator is to be used, which generates
output for use in a `CMakeLists.txt` file.

Next, install these dependencies and generate the lockfiles and build info
using the `conan install` command. It's only necessary to specify the
profile if the default profile is not being used.

```bash-session
conan install -pr=emscripten .
```

Finally, to use the build info in a `CMakeLists.txt` file, add the
following two lines above the target declarations:

```cmake
include(conanbuildinfo.cmake)
conan_basic_setup()
```

This macro defines useful variables for generating targets. The
[documentation](https://docs.conan.io/en/latest/reference/generators/cmake.html)
for the `cmake` generator provides a very good overview
of its usage, but the only two variables that are necessary to get a working
CMake configuration in most cases are `CMAKE\_LIBS` and
`CMAKE\_INCLUDE\_DIRS`. These variables contain information for linking
dependencies and locating headers of those dependencies, respectfully, and can
be used in the normal way to configure a target. For example, to build an
executable `example`, which is compiled from `example.cpp`:

```cmake
add_executable(FlacTest FlacTest.cpp)
set_target_properties(FlacTest PROPERTIES
  OUTPUT_NAME "FlacTest"
  SUFFIX ".js")
target_link_libraries(FlacTest ${CONAN_LIBS})
target_include_directories(FlacTest PRIVATE
  ${CONAN_INCLUDE_DIRS})
```

The project can then be build using CMake like any other project. It's not
necessary to commit any built output from the `conan install` command,
but it is necessary to rerun this command whenever the `conanfile.txt`
is modified.

# Conan Remotes
`Remote} is Conan nomenclature for repository. Remotes contain packages
and recipes that can be installed in the local cache to be used in projects. To
list your remotes, use the `conan remote list` command. The
`conan remote` command can also be used to add and remove remotes.

Some commands, such as `conan search` and `conan remove`, require
the remote to be specified directly on the command line, such as (for a remote
named `edtwardy`).

```bash-session
conan remote -r=edtwardy
```

Others, such as `conan install`, are smart enough to attempt to search
for packages in all your remotes.

# Adding a Cross Compiler
This becomes useful when generating packages to be used with the Emscripten
transcompiler, which compiles C/C++ code into WebAssembly for use in JavaScript
applications, or for any other cross compiling environment which is not
natively supported by Conan.

First, it is good practice to create a new profile with which to build
packages. This is done using the `conan profile` command. To create a
profile called `emscripten`, invoke this command like so:

```bash-session
conan profile new --detect emscripten
```

The `--detect` flag gives us a way to create a basic boilerplate for the
profile. Profiles are stored in `~/.conan/profiles/<profileName>`. The
next step is to manually edit this file. Profiles for cross compiler
environments should always define new values for the `os`,
`arch`, `compiler`, `compiler.version` and potentially
also the `compiler.libcxx` variables. The profile that I use for
compiling with Emscripten is given below:

```yaml
[settings]
os=Emscripten
os_build=Macos
arch=wasm
arch_build=x86_64
compiler=emcc
compiler.version=2.0
compiler.libcxx=emsdk
build_type=Release
[options]
[build_requires]
[env]
```

This profile can then be specified when building packages for this platform.
Note that it may be necessary to define new values for some of these in
`~/.conan/settings.yml`. When defining a new profile, always check this
file to ensure that all values of these variables are defined therein.
