cmake_minimum_required(VERSION 3.10)
project(skateboard)

include(ExternalProject)

find_program(QEMU_SYSTEM_ARM qemu-system-arm
	DOC "Path to qemu-system-arm"
)

ExternalProject_Add(buildroot
	PREFIX buildroot
	GIT_REPOSITORY https://github.com/buildroot/buildroot.git
        GIT_TAG 2018.11
	BUILD_IN_SOURCE False
	GIT_PROGRESS True
	CONFIGURE_COMMAND make -C <SOURCE_DIR> O=<BINARY_DIR> BR2_EXTERNAL=${CMAKE_CURRENT_SOURCE_DIR}/config/buildroot skateboard_defconfig
	BUILD_COMMAND cd <BINARY_DIR> && make
	INSTALL_COMMAND ""
	TEST_COMMAND ""
	STEP_TARGETS debug
)

ExternalProject_Add_Step( buildroot debug
	COMMAND ${QEMU_SYSTEM_ARM} 
		-M versatilepb 
		-kernel images/zImage
		-dtb images/versatile-pb.dtb
		-drive file=images/rootfs.ext2
		-append "root=/dev/sda console=ttyAMA0,115200" 
		-nographic 
		-m 15 
		-net user 
		-net nic,model=rtl8139
 	COMMENT "Launching qemu-system-arm debugging session..."
	ALWAYS True
	EXCLUDE_FROM_MAIN True
	WORKING_DIRECTORY <BINARY_DIR>
	USES_TERMINAL True
	DEPENDEES build
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
