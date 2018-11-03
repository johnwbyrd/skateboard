cmake_minimum_required(VERSION 3.10)
project(skateboard)

option(SKATEBOARD_MMU 
"Enable MMU support in the Linux kernel.  This enables memory protection features in the \
kernel, at a cost of adding complexity in the emulation step."
ON)

if (${SKATEBOARD_MMU})
	set( BUILDROOT_BASE_CONFIG "qemu_arm_versatile_defconfig" )
else()
	set( BUILDROOT_BASE_CONFIG "qemu_arm_versatile_nommu_defconfig" )
endif()

include(ExternalProject)

ExternalProject_Add(buildroot
	PREFIX buildroot
	GIT_REPOSITORY https://github.com/buildroot/buildroot.git
        GIT_TAG 2018.08.x
	BUILD_IN_SOURCE True
	GIT_PROGRESS True
        CONFIGURE_COMMAND make clean 
		COMMAND make defconfig BR2_DEFCONFIG=${CMAKE_CURRENT_SOURCE_DIR}/config/buildroot/buildroot_nommu_defconfig
	BUILD_COMMAND make
	INSTALL_COMMAND ""
	TEST_COMMAND ""
)

ExternalProject_add(cc65
	PREFIX cc65
	GIT_REPOSITORY https://github.com/cc65/cc65.git
	GIT_PROGRESS True
        BUILD_IN_SOURCE True
	CONFIGURE_COMMAND make clean
	BUILD_COMMAND make all
	INSTALL_COMMAND ""
	TEST_COMMAND ""
)
