# Overview

_This repository does not do anything useful at this time. Do not get excited. Please come back later._

This repository hosts early experiments for an emulation of an ARMv5TE hosted on 6502.

# Building

This experiment can be built on Ubuntu 18.04 LTS. The following instructions work from a clean install of that distribution.

You will need to install git in order to acquire skateboard:

```
sudo apt install git
```

Acquire the skateboard code base:

```
git clone https://github.com/johnwbyrd/skateboard.git
```

Install prerequisite software:

```
cd skateboard/scripts
sudo ./install-prerequisites
cd ..
```

Then, use cmake to build:

```
mkdir build
cd build
cmake
make
```

A Dockerfile is provided that sets up a Docker host with all requirements. You can use that for automating builds if you prefer.

# Debugging

For initial bringup, we use qemu as a first emulator, performing the functions that we hope to perform with the Skateboard emulator.

## qemu

There are two ways to debug buildroot running on qemu. The first is by using a traditional gdb text-mode interface with qemu. The second is by using Eclipse as an IDE.

### qemu with gdb

To debug buildroot with qemu and gdb, open up two terminal windows. In the first terminal window, launch qemu:

```
cd scripts
./run-qemu
```

And in the second window, launch gdb:

```
cd scripts
./run-gdb
```

gdb will launch and connect to the qemu instance, with a breakpoint on the start_kernel function, ready for debugging. Note also the [tui mode of gdb](https://sourceware.org/gdb/onlinedocs/gdb/TUI.html), which can be used for text-mode debugging as well.

### qemu with eclipse

It is also possible to debug buildroot with qemu and eclipse. This requires more setup, but provides debugging services in a comfortable IDE.

However, Eclipse is not terribly stable or sensible in its defaults, and it does not seem to deal well with avoiding re-entering information. In default settings, it seems to want to go off and index the entire world, which either slows the IDE to a crawl or hangs it entirely. So, a fairly long dance seems to be required to convince Eclipse that it's ok to debug the way we want. If you can improve upon this sequence of operations, please do and let us know how you did it.

You may be able to get indexing working with your project, but in my case Eclipse quickly runs out of heap space and dies. So these steps disable C/C++ indexing for this Eclipse project.

- Download and install the latest [Eclipse for C/C++](https://www.eclipse.org/). As of this writing, it is 2019-03.

- In eclipse.ini, which exists at the same directory of the eclipse installation, change the -Xmx1024m line to be -Xmx4096m (assuming you have 8 GB or more of working memory for Eclipse to use).

- Close the Welcome window and run File > Makefile Project with Existing Code.

- For Existing Code Location, click Browse and select the skateboard/build/buildroot/src/buildroot-build/ directory. Deselect C++. For Toolchain for Indexer, select Linux GCC.

- Right-click on the newly created buildroot-build project in the Project Explorer pane, and select Properties. Select C/C++ General, and select Indexer. Click on Enable project specific settings, and deselect Enable indexer.

- Verify that buildroot builds correctly by selecting Project > Build Project.

- Create a debug configuration by selecting Run > Debug Configurations... Select GDB Hardware Debug, and then click on the New icon above it (New launch configuration). For Name, enter QEMU Debug. Project should be set to "buildroot-build".

- We would prefer to use variables here, but they do not seem to work as designed in Eclipse. For C/C++ Application, enter the full path to the vmlinux file created as part of the build process. This normally resides at skateboard/build/buildroot/src/buildroot-build/linux-X.XX.XXX/vmlinux, where X.XX.XXX can be deteremined by running the skateboard/scripts/show-linux-version command. Click Disable auto build.

- Click on the Debugger tab. For GDB Command, enter the full path to the arm-linux-gdb program, which normally resides at skateboard/build/buildroot/src/buildroot-build/host/bin/arm-linux-gdb .

- Under Remote Target, enable Use remote target, enable Remote timeout (seconds), and set the timeout to 2 seconds.

- Select the Startup tab. Under Initialization commands, enter the following information:

  set sysroot .../buildroot-build/host/arm-skateboard-linux-musleabi/sysroot file .../buildroot-build/build/linux-X.XX.XXX/vmlinux b start_kernel

- Replace any ... above with the full path to the buildroot-build directory. Also, replace X.XX.XXX with the version of Linux you are building.

- Under Load image and symbols, deselect Load image. Select Load symbols and select Use project binary.

- Under Run commands..., enable Set breakpoint at: and enter "start_kernel".

- Click Apply and then click Close.

# Usage

In addition to the normal make command from the build directory:

```
make
```

From within the build directory that you created above, the following commands may be used:

```
make buildroot-qemu
```

make buildroot-qemu launches an instance of qemu with a breakpoint set at the entry function for debugging Linux. Ctrl-A C enters the monitor mode for qemu, so that you can stop or restart qemu.

```
make buildroot-gdb
```

make buildroot-gdb launches an instance of gdb and tries to connect to an instance of qemu on the local machine. Run this in a different process than make buildroot-qemu.

# Development strategy

Getting a full ARM system emulator to run in the restricted memory of a 6502, even with a memory upgrade, is not easy. We'll need multiple intermediate steps to get the code running on the ultimate targets.

The basic strategy is to start by targeting an emulated [arm_versatile_pb](https://developer.arm.com/docs/dsi0034/a) with 16 MB of memory on [qemu](https://www.qemu.org/). This is a first-class Linux target and has been for some time. Support for this already exists in [buildroot](https://buildroot.org/). Although a no-MMU version of buildroot exists, the MMU is needed to be able to successfully run Linux in this small of a footprint.

Then, an ARM926EJ-S emulator will need to be written. The logic for this emulator (we'll call it skateboard) needs to be hosted in 6502 microcode. This microcode will run on the [sim6502](https://cc65.github.io/doc/sim65.html), which is a part of [cc65](https://github.com/cc65/cc65).

This emulator will need to be debugged remotely via gdb. I can find two already existing gdb stubs that could be used here. One is [here](https://github.com/avatarone/avatar-gdbstub). This seems small and self-contained but a bit hacky. Another was done by Embecosm, and resides [here](). It has a lot more dependencies and would be harder to rip out, but it also has the advantage of [immaculate documentation on porting gdb itself](https://www.embecosm.com/appnotes/ean3/embecosm-howto-gdb-porting-ean3-issue-2.html). Embecosm has also documented the [rsp server protocol](https://www.embecosm.com/appnotes/ean4/embecosm-howto-rsp-server-ean4-issue-2.html) upon which gdb depends.

As this emulated ARM is coming up, David Welch has written some [verification samples](https://github.com/dwelch67/qemu_arm_samples), specifically for bringing up and verifying emulation an arm_versatile_pb. These were designed for running on qemu as arm_versatile_pb, so they will be helpful in testing the new emulator.

Once the emulator is up and walking, several virtual devices will need to be added. Probably the first device will need to be a block reader representing a virtual disk. It is important not to introduce any specific device dependencies into the main emulator, as it will probably be ported to other 6502 targets later. So each target must be permitted to add its own physical devices.

All targets will need a serial port emulation. While arm_versatile_pb has an ARM specific UART implementation, there is also the good old fashioned [8250 chip](https://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming) which could be used instead. Additionally, the ARM PrimeCell PL011 does not look that complicated either.

All targets will need a timer emulation. We should probably write a timer as part of the core 6502 implementation, although the C64 has an RTC that could be read from the emulated guest. The arm_versatile_pb uses the SP804 ARM dual-timer module.

For the C64 implementation, the host block device will probably be an IDE64, which has a direct-access mode. The IDE64 permits access to devices with 128M blocks of 512 or 2048 bytes each, so this should be plenty. A simple Linux guest driver will need to be written that thunks to the 6502 emulation for the request.

# Host memory management

Most period designs used something like the MOS 8722 as an MMU for the 6502-likes.

Even with memory upgrades, the most a period-appropriate 6502 could address was 16 MB. The 65816 could address this much memory directory, but the 6510 used bank switching to address more than 64KB.

# Development tasks

Phases of development involve the following.

1. Bring up buildroot on qemu targeting the qemu_arm_versatile_defconfig environment. (Done, works in 15MB of memory with MMU enabled)

2. Make sure to be able to single-step through debuggable kernel. (Done)

3. Get source-level kernel debugging working with Eclipse. This is technically not required, but it's source level debugging and will save so much time later. See verbose console mode to debug communication with qemu.

4. Build a virtual gdb remote target which is able to speak as an RSP server. Every instruction needs to be a no-op.

5. Link in the sim6502 code.

6. Allow the gdb stub to get virtual register states and memory states out of the emulator.

7. Set up the emulator to be able to run in two modes. The first mode would permit the ARM emulator to run on the development machine itself, using normal source debugging. The second mode would permit the ARM emulator to run on the virtual 6502, compiled by cc65 from the same source code used in the first mode. The bring-up test would involve running the ARM emulator from an imaginary memory filled with no-op instructions

7) Get dwelch67's examples running.

8) Remove as many drivers as possible.

9) Write ARM emulator in cc65 with dummy 6502 as target. Develop ARM instruction decoder first, followed by THUMB decoder if necessary. Write thunk layers for 16MB memory access, as well as I/O drivers for keyboard and terminal, and possibly a network transport layer.

- The ARM instruction set has some patterns in its instruction layout which may help to simplify decoding their formats. The THUMB instruction sets are even simpler, but it is not clear that we will need a THUMB decoder at all, and an ARM decoder is required no matter what, even if we implement a THUMB decoder as well.

- The backend of the decoder can be implemented in a couple ways. The most obvious is an instant instruction dispatch where code is executed immediately after decoding. However, it would be nice to be able to decode a non-branching sequence of code to 6502 and then execute that directly as a function. If we are careful to keep track of the virtual ARM's status flags versus the 6502's, we may be able to implement ARM's conditional instruction flags "for free" as part of the decode process. Might be better to implement a plain decoder before jumping to the dynamic compiler version... doing this correctly would require branch analysis of the ARMv5TE, and there are soooo many addressing modes on the ARM to get right anyway.

- For performance, the implementation will probably want to do its own private caching in some 6502 low-memory area. This may or may not emulate real cache behavior -- but our basic policy MUST BE to emulate as little hardware as possible.

- There are only 31 total 32 bit registers in ARM. Most of that can go into 6502 zero page. The special things that ARM can do is conditionally execute any instruction based on processor flags, the A operand, and the barrel shifted B operand.

- Unfortunately, the nommu version of buildroot is not terribly stable, and has trouble running even a few programs. ARM MMU emulation will slow down the 6502 implementation enormously, but the good news is that a) we will have an extra 1 MB available if we need it for other stuff, and b) we only need to get enough of the MMU emulation working to make Linux happy.

10) Single-step through new ARM emulator using gdb, using qemu as a reference emulator. Possibly, script operation of two gdb instances, run in parallel, and compare outputs.

11) Port emulator to Commodore 64 using vice as a testbed. Write drivers for Commodore 16MB REU and for IDE64 and possibly for Ethernet driver (?!). Run vice in warp mode for testing.

12) Get some poor soul to run the result on practical hardware.

# Docker notes

A Dockerfile has been created that sets up a minimal Ubuntu environment sufficient for compiling the world.

# Editor notes

For Atom, _Ctrl-Shift-Q_ reflows a paragraph, and _Ctrl-Alt-B_ runs atom-beautify.
