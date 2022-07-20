# Interesting Operations on ELF Binaries
### Ethan D. Twardy
### April 24, 2021

## Determining the Interpreter

All programs on Linux have an interpreter, that is, a program responsible for
executing the program itself. For most dynamically-linked executables, this is
`ld`, the GNU dynamic linker. The filesystem path of the program's
interpreter is stored in the `.interp` section in ELF binaries, and can be
extracted using `readelf`::

```
  [~]$ readelf -p .interp /bin/ls
  
  String dump of section '.interp':
    [     0]  /lib64/ld-linux-x86-64.so.2
```

So for the executable ELF file `/bin/ls`, the interpreter on my system is
`/lib64/ld-linux-x86-64.so.s2`.

## Disassembling a Single Function

Sometimes, it's useful to examine the generated assembly of your program. To
do this, first dump the symbol table to get a list of all the symbols in
the binary. Symbols are labelled references to interesting locations in the
file containing code or data. There is a rough mapping between functions and
global data in a C program to symbols in an ELF symbol table. Note that there
are different flags to dump the static or dynamic symbol tables::

```
  [~]$ objdump -t <staticExecutable>
  [~]$ objdump -T <dynamicExecutable>
```

Note also that `objdump` is a part of your compiler toolchain, so in a cross
environment, where `arm-none-eabi` is my compiler toolchain, I would use
`arm-none-eabi-objdump`.

To obtain the assembly for a symbol:

```
  [~]$ objdump --disassemble=<symbolName> <staticExecutable>
```
