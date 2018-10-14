- Overview

Early experiments for an emulation of an ARMv5TE hosted on 6502.  This
repository does not run, nor do anything useful at this time.

This experiment is to be hosted on Ubuntu 18.04.  A Dockerfile is provided
that sets up a Docker host with all requirements.  Please see the Dockerfile
if you are setting up an interactive environment.

Phases of development involve the following.

1. Bring up buildroot on qemu targeting the arm_versatile_nommu_defconfig
   environment.  Make sure to be able to single-step through debuggable
   kernel.

2. Reduce total RAM/ROM usage to 16MB or lower.  Remove any drivers not
   necessary for kernel bringup.

   1. There are alternatives to buildroot, but they have done much of 
      the heavy lifting for size reduction and nommu patches for 
      the arm_versatile_nommu platform.

   2. There is a bunch of interrupt hardware on the arm_versatile_pb.
      We want to see how little we can get away with emulating.  If we
      do have to emulate, then we have to check every memory write and read
      against the emulated hardware, and this will slow us down a great
      deal.

3. Fork 6502 dummy target on cc65 to be new ARMv5TE emulator.  Add gdb
   ARM stub to open a debug port on this emulator.

4. Write ARM emulator in cc65.  Develop ARM instruction decoder first,
   followed by THUMB decoder.  Write thunk layers for 16MB memory access.

   1. The ARM instruction set has some patterns in its instruction layout
      which may help to simplify decoding their formats.  The THUMB
      instruction sets are even simpler.  The backend for the decoder
      can be implemented in a couple ways.  The most obvious is an
      instant instruction dispatch where code is executed immediately 
      after decoding.  However, it would be nice to be able to decode
      a non-branching sequence of code to 6502 and then execute that 
      directly as a function.  If we are careful to keep track of the 
      virtual ARM's status flags versus the 6502's, we may be able to
      implement ARM's conditional instruction flags "for free" as part
      of the decode process.  Might be better to implement a plain
      decoder before jumping to the dynamic compiler version... doing
      this correctly would require branch analysis of the ARMv5TE, and 
      there are soooo many addressing modes on the ARM to get right anyway.

   2. Writing a memory cache should be a lot easier.  I see an n-way 
      associative cache with aging implemented... something like four 256-
      byte caches covering the 16MB external memory.  Accessing greater
      than 64KB on a 6502 device will always come at a cost, even in 
      the best case, which is the REU's DMA-like behavior for reads
      and writes.

5. If necessary, write thunk layer for ARM emulator to access virtual
   block driver to emulate SD/MMC or the like.

   1. Linux purposely keeps block drivers simple.  This could be brought 
      up using an IDE64

6. Single-step through new ARM emulator using gdb, using qemu as a reference
   emulator.  Possibly, script operation of two gdb instances, run in
   parallel, and compare outputs.

7. Port emulator to Commodore 64 using vice as a testbed.  Write drivers for 
   Commodore 16MB REU and for IDE64 and possibly for Ethernet driver (?!).
   Run vice in warp mode for testing.

8. Get some poor soul to run the result on practical hardware.
   
- Docker notes

A Dockerfile has been created that sets up a minimal Ubuntu environment 
sufficient for compiling the world.

sudo docker exec $CONTAINER_ID cat /home/ubuntu/password.txt
sudo docker run -itd -p 80:6080 -e PASSWORD=$YOUR_PASSWORD $DOCKER_ID
