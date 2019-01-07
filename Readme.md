# Overview

_This repository does not do anything useful at this time. Do not
get excited. Please come back later._

This repository hosts early experiments for an emulation of an ARMv5TE
hosted on 6502.

This experiment is hosted on Ubuntu 18.04. First, install prerequisite
packages by running scripts/install-prerequisites. Then, use cmake to build:

    mkdir build
    cd build
    cmake
    make

A Dockerfile is provided that sets up a Docker host with all requirements.

# Usage

From within the build directory that you created above, the following
commands may be used:

    make buildroot-qemu

Launches an instance of qemu with a breakpoint set at the entry function
for debugging Linux.

    make buildroot-gdb

Launch an instance of gdb and try to connect to an instance of qemu on
the local machine.

# Phases of development

Phases of development involve the following.

1. Bring up buildroot on qemu targeting the qemu_arm_versatile_defconfig
   environment. (Done, works in 15MB of memory with MMU enabled)

2. Make sure to be able to single-step through debuggable kernel. (Done)

3. Remove as many drivers as possible

   - There is a bunch of interrupt hardware on the arm_versatile_pb. We want to
     see how little we can get away with emulating. If we do have to emulate,
     then we have to check every memory write and read against the emulated
     hardware, and this will slow us down a great deal.

   - So we probably want to create a virtual "skateboard" hardware target,
     and remove as much stuff from arm_versatile_pb to make it work, while
     still keeping it working. We want to remove all the DMA stuff, and
     possibly only use a tiny interrupt controller, and also remove all the
     graphics peripherals and the like.

4. Fork 6502 dummy target on cc65 to be new ARMv5TE emulator. Add gdb ARM stub
   to open a debug port on this emulator.

5. Write ARM emulator in cc65 with dummy 6502 as target. Develop ARM instruction
   decoder first, followed by THUMB decoder if necessary. Write thunk layers for
   16MB memory access, as well as I/O drivers for keyboard and terminal, and
   possibly a network transport layer.

   - The ARM instruction set has some patterns in its instruction layout which may
     help to simplify decoding their formats. The THUMB instruction sets are even
     simpler, but it is not clear that we will need a THUMB decoder at all, and an
     ARM decoder is required no matter what, even if we implement a THUMB decoder
     as well.

   - The backend of the decoder can be implemented in a couple ways. The most
     obvious is an instant instruction dispatch where code is executed
     immediately after decoding. However, it would be nice to be able to decode
     a non-branching sequence of code to 6502 and then execute that directly as
     a function. If we are careful to keep track of the virtual ARM's status
     flags versus the 6502's, we may be able to implement ARM's conditional
     instruction flags "for free" as part of the decode process. Might be better
     to implement a plain decoder before jumping to the dynamic compiler
     version... doing this correctly would require branch analysis of the
     ARMv5TE, and there are soooo many addressing modes on the ARM to get right
     anyway.

   - gdb has an ARM simulation layer already built into it based on ARMulator.
     However, that implementation has no emulated hardware whatsoever. The
     original ARMulator does seem to have enough emulated hardware to run
     Linux but it does not seem to be open source.

   - We would prefer to get by without any memory cache at all. ARMulator does
     not use one. For performance, the implementation will probably want to do
     its own private caching in some 6502 low-memory area. This may or may not
     emulate real cache behavior -- but our basic policy MUST BE to emulate as
     little hardware as possible.

   - There are only 31 total 32 bit registers in ARM. Most of that can go into
     6502 zero page. The special things that ARM can do is conditionally execute
     any instruction based on processor flags, the A operand, and the barrel
     shifted B operand.

   - Unfortunately, the nommu version of buildroot is not terribly stable, and
     has trouble running even a few programs. ARM MMU emulation will slow down
     the 6502 implementation enormously, but the good news is that a) we will
     have an extra 1 MB available if we need it for other stuff, and b) we only
     need to get enough of the MMU emulation working to make Linux happy.

6. Write thunk layer for ARM emulator to access virtual I/O from dummy block
   driver to emulate SD/MMC or the like.

   - Linux purposely keeps block drivers simple. This could be brought up using
     an IDE64

7. Single-step through new ARM emulator using gdb, using qemu as a reference
   emulator. Possibly, script operation of two gdb instances, run in parallel, and
   compare outputs.

8. Port emulator to Commodore 64 using vice as a testbed. Write drivers for
   Commodore 16MB REU and for IDE64 and possibly for Ethernet driver (?!). Run vice
   in warp mode for testing.

   - Linux already has a driver for a cs89x0 chipset already into it. We might be
     able to map the chipset's memory space into emulated memory, and have Linux
     drive the cs89x0 chip directly (!).

9) Get some poor soul to run the result on practical hardware.

# Docker notes

A Dockerfile has been created that sets up a minimal Ubuntu environment
sufficient for compiling the world.

# Editor notes

For Atom, _Ctrl-Shift-Q_ reflows a paragraph, and _Ctrl-Alt-B_ runs
atom-beautify.
