cmake_minimum_required(VERSION 3.10)
project(skateboard)

include(ExternalProject)

ExternalProject_Add(buildroot
	BUILD_IN_SOURCE True
	GIT_REPOSITORY https://github.com/buildroot/buildroot.git
        GIT_TAG 2018.08.x
        CONFIGURE_COMMAND make qemu_arm_versatile_nommu_defconfig
	BUILD_COMMAND make
	INSTALL_COMMAND ""
	TEST_COMMAND ""
)
