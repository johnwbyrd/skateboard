cmake_minimum_required(VERSION 3.10)
project(skateboard)

include(ExternalProject)

set( BUILDROOT_DEFCONFIG_DIR 
	${CMAKE_CURRENT_SOURCE_DIR}/config/buildroot/configs )
set( BUILDROOT_DEFCONFIG_FILE 
	${BUILDROOT_DEFCONFIG_DIR}/skateboard_defconfig 
)
execute_process(
	COMMAND echo grep 
		-Po 'BR2_LINUX_KERNEL_VERSION="\\K[^"]*' 
		${BUILDROOT_DEFCONFIG_FILE}
	OUTPUT_VARIABLE BUILDROOT_LINUX_KERNEL_VERSION
)

ExternalProject_Add(buildroot
	PREFIX buildroot
	GIT_REPOSITORY https://github.com/buildroot/buildroot.git
        GIT_TAG 2018.11
	BUILD_IN_SOURCE False
	GIT_PROGRESS True
	CONFIGURE_COMMAND make 
		-C <SOURCE_DIR> 
		O=<BINARY_DIR> 
		BR2_EXTERNAL=${CMAKE_CURRENT_SOURCE_DIR}/config/buildroot 
		skateboard_defconfig
	BUILD_COMMAND cd <BINARY_DIR> && make
	INSTALL_COMMAND ""
	TEST_COMMAND ""
	STEP_TARGETS qemu gdb
)

ExternalProject_Add_Step( buildroot qemu
	COMMAND QEMU_AUDIO_DRV=none ;
		<BINARY_DIR>/host/bin/qemu-system-arm
		-M versatilepb 
		-kernel <BINARY_DIR>/images/zImage
		-dtb <BINARY_DIR>/images/versatile-pb.dtb
		-drive file=<BINARY_DIR>/images/rootfs.ext2
		-append "root=/dev/sda console=ttyAMA0,115200"
		-nographic 
		-m 15 
		-net user 
		-net nic,model=rtl8139
		-s 
		-S
 	COMMENT "Launching qemu-system-arm debugging session..."
	ALWAYS True
	EXCLUDE_FROM_MAIN True
	WORKING_DIRECTORY <BINARY_DIR>
	USES_TERMINAL True
)

# todo: get the linux kernel version from skateboard_defconfig or from the 
# directory structure

ExternalProject_Add_Step(buildroot gdb
	COMMAND <BINARY_DIR>/host/bin/arm-linux-gdb
		-x <BINARY_DIR>/host/arm-buildroot-linux-musleabi/sysroot/usr/share/buildroot/gdbinit
		-ex 'file <BINARY_DIR>/build/linux-4.18.20/vmlinux'
	COMMENT "Launching arm-linux-gdb, please make sure target is running..."
	ALWAYS True
	EXCLUDE_FROM_MAIN True
	WORKING_DIRECTORY <BINARY_DIR>
	USES_TERMINAL True
)

ExternalProject_add(cc65
	PREFIX cc65
	GIT_REPOSITORY https://github.com/cc65/cc65.git
	GIT_PROGRESS True
        BUILD_IN_SOURCE False
	CONFIGURE_COMMAND ""
	BUILD_COMMAND PREFIX=<BINARY_DIR> make -e -C <SOURCE_DIR> PREFIX=<BINARY_DIR>
	INSTALL_COMMAND PREFIX=<BINARY_DIR> make -e -C <SOURCE_DIR> install PREFIX=<BINARY_DIR>
	TEST_COMMAND ""
)
