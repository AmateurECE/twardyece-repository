---
title: Inspecting Object Files
---

This page contains some tips I've found helpful occasionally when inspecting
various attributes of binary files.

## Determining the Interpreter

All programs on Linux have an interpreter, that is, a program responsible for
executing the program itself. For most dynamically-linked executables, this is
`ld`, the GNU dynamic linker. The filesystem path of the program's
interpreter is stored in the `.interp` section in ELF binaries, and can be
extracted using `readelf`:

```
  [~]$ readelf -p .interp /bin/ls
  
  String dump of section '.interp':
    [     0]  /lib64/ld-linux-x86-64.so.2
```

So for the executable ELF file `/bin/ls`, the interpreter on my system is
`/lib64/ld-linux-x86-64.so.2`.

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

## Listing Shared Object Dependencies

For native ELF files, this can be done using `ldd`:

```bash-session
[edtwardy@hackbook]$ file /usr/bin/ls
/usr/bin/ls: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, stripped
[edtwardy@hackbook]$ ldd /usr/bin/ls
	linux-vdso.so.1 (0x0000ffff97318000)
	libc.so.6 => /usr/lib64/libc.so.6 (0x0000ffff970c0000)
	/lib/ld-linux-aarch64.so.1 => /lib64/ld-linux-aarch64.so.1 (0x0000ffff972e0000)
```

However, for ELF files compiled for non-native targets, `ldd` may simply
report that the ELF file is "not a dynamic executable". Instead, we can use
`readelf`:

```bash-session
[edtwardy@hackbook]$ file bazel-bin/init
bazel-bin/init: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /nix/store/8jjax8ch07g90axrx64ncfrqkpahn2wn-glibc-armv7l-unknown-linux-gnueabihf-2.38-27/lib/ld-linux-armhf.so.3, for GNU/Linux 3.10.0, not stripped
[edtwardy@hackbook]$ readelf -d bazel-bin/init

Dynamic section at offset 0xeac contains 31 entries:
  Tag        Type                         Name/Value
 0x00000001 (NEEDED)                     Shared library: [libstdc++.so.6]
 0x00000001 (NEEDED)                     Shared library: [libm.so.6]
 0x00000001 (NEEDED)                     Shared library: [libgcc_s.so.1]
 0x00000001 (NEEDED)                     Shared library: [libc.so.6]
 0x0000001d (RUNPATH)                    Library runpath: [/nix/store/8jjax8ch07g90axrx64ncfrqkpahn2wn-glibc-armv7l-unknown-linux-gnueabihf-2.38-27/lib:/nix/store/p9ainll0v4yrf6y89ks17wapwl4hyb07-armv7l-unknown-linux-gnueabihf-gcc-12.3.0-lib/armv7l-unknown-linux-gnueabihf/lib]
 0x0000000c (INIT)                       0x1063c
 0x0000000d (FINI)                       0x10884
 0x00000019 (INIT_ARRAY)                 0x11ea0
 0x0000001b (INIT_ARRAYSZ)               8 (bytes)
 0x0000001a (FINI_ARRAY)                 0x11ea8
 0x0000001c (FINI_ARRAYSZ)               4 (bytes)
 0x00000004 (HASH)                       0x101e8
 0x6ffffef5 (GNU_HASH)                   0x1022c
 0x00000005 (STRTAB)                     0x10320
 0x00000006 (SYMTAB)                     0x10260
 0x0000000a (STRSZ)                      571 (bytes)
 0x0000000b (SYMENT)                     16 (bytes)
 0x00000015 (DEBUG)                      0x0
 0x00000003 (PLTGOT)                     0x11fcc
 0x00000002 (PLTRELSZ)                   48 (bytes)
 0x00000014 (PLTREL)                     REL
 0x00000017 (JMPREL)                     0x1060c
 0x00000011 (REL)                        0x105f4
 0x00000012 (RELSZ)                      24 (bytes)
 0x00000013 (RELENT)                     8 (bytes)
 0x0000001e (FLAGS)                      BIND_NOW
 0x6ffffffb (FLAGS_1)                    Flags: NOW
 0x6ffffffe (VERNEED)                    0x10574
 0x6fffffff (VERNEEDNUM)                 3
 0x6ffffff0 (VERSYM)                     0x1055c
 0x00000000 (NULL)                       0x0
```

## Mutating ELF Files

The NixOS folks (of all people--no surprise) have an interesting project for
performing various mutations on ELF files, called [patchelf][1].

## Inspecting Section Headers

Sometimes it's helpful to take a look at the section headers in an ELF file--
for example, to inspect the load memory addresss (LMA) of your `.text`
section, etc. This can be done with `objdump`. Note that unlike some other
tools, objdump works on ELF files compiled for any architecture. And, of
course, it works on both dynamic and static executables.

```
[edtwardy@hackbook]$ objdump -h bazel-bin/app/hello-world

bazel-bin/app/hello-world:     file format elf32-littlearm

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .isr_vector   00000298  08000000  08000000  00001000  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .text         00001cb4  08000298  08000298  00001298  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  2 .startup_copro_fw.Reset_Handler 00000050  08001f4c  08001f4c  00002f4c  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  3 .rodata       00000048  08001f9c  08001f9c  00002f9c  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .ARM.extab    00000000  08001fe4  08001fe4  00002fe4  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .ARM          00000008  08001fe4  08001fe4  00002fe4  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .preinit_array 00000000  08001fec  08001fec  00003558  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  7 .init_array   00000008  08001fec  08001fec  00002fec  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  8 .fini_array   00000004  08001ff4  08001ff4  00002ff4  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  9 .data         00000558  20000000  08001ff8  00003000  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 10 .bss          0000034c  20000558  08002550  00003558  2**2
                  ALLOC
 11 ._user_heap_stack 00000604  200008a4  08002550  000038a4  2**0
                  ALLOC
 12 .ARM.attributes 0000002e  00000000  00000000  00003558  2**0
                  CONTENTS, READONLY
 13 .comment      00000012  00000000  00000000  00003586  2**0
                  CONTENTS, READONLY
```

[1]: https://github.com/NixOS/patchelf
