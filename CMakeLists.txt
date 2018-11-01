cmake_minimum_required(VERSION 3.10)
project(skateboard)

include(ExternalProject)

ExternalProject_Add(buildroot
	PREFIX buildroot
	GIT_REPOSITORY https://github.com/buildroot/buildroot.git
        GIT_TAG 2018.08.x
	BUILD_IN_SOURCE True
	GIT_PROGRESS True
        CONFIGURE_COMMAND make qemu_arm_versatile_defconfig
	BUILD_COMMAND make
	INSTALL_COMMAND ""
	TEST_COMMAND ""
)

ExternalProject_add(cc65
	PREFIX cc65
	GIT_REPOSITORY https://github.com/cc65/cc65.git
	GIT_PROGRESS True
        BUILD_IN_SOURCE True
	CONFIGURE_COMMAND ""
	BUILD_COMMAND make all
	INSTALL_COMMAND ""
	TEST_COMMAND ""
)
