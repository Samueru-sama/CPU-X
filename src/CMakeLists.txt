include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

### TIP: CMake commands orders
# - link_directories: The command will apply only to targets created after it is called.
# - add_executable: Adds an executable target called <name> to be built from the source files listed in the command invocation.
#                   (The source files can be omitted here if they are added later using target_sources().)
# - target_sources: The named <target> must have been created by a command such as add_executable().


### FIND REQUIRED LIBRAIRIES

# GTK3+
if(WITH_GTK)
	pkg_check_modules(GTK3 REQUIRED gtkmm-3.0>=3.12.0)
	if(GTK3_FOUND)
		include_directories(${GTK3_INCLUDE_DIRS})
		link_directories(${GTK3_LIBRARY_DIRS})
		add_definitions(${GTK3_CFLAGS_OTHER})
	endif(GTK3_FOUND)
endif(WITH_GTK)

# NCurses
if(WITH_NCURSES)
	set(CURSES_NEED_NCURSES TRUE)
	set(CURSES_NEED_WIDE TRUE)
	if(NOT CURSES_FOUND AND CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
		set(CURSES_INCLUDE_PATH "/usr/local/include")
	endif(NOT CURSES_FOUND AND CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
	find_package(Curses REQUIRED)
	if(CURSES_FOUND)
		include_directories(${CURSES_INCLUDE_DIRS})
	endif(CURSES_FOUND)
endif(WITH_NCURSES)

# Gettext
if(Intl_FOUND)
	include_directories(${Intl_INCLUDE_DIRS})
endif(Intl_FOUND)

# Libcpuid
if(WITH_LIBCPUID)
	pkg_check_modules(LIBCPUID REQUIRED libcpuid>=0.8.0)
	if(LIBCPUID_FOUND)
		include_directories(${LIBCPUID_INCLUDE_DIRS})
		link_directories(${LIBCPUID_LIBRARY_DIRS})
		add_definitions(${LIBCPUID_CFLAGS_OTHER})
		set(CMAKE_REQUIRED_LIBRARIES ${LIBCPUID_LIBRARIES})
	endif(LIBCPUID_FOUND)
endif(WITH_LIBCPUID)

# Libpci
if(WITH_LIBPCI)
	pkg_check_modules(LIBPCI REQUIRED libpci)
	if(LIBPCI_FOUND)
		include_directories(${LIBPCI_INCLUDE_DIRS})
		link_directories(${LIBPCI_LIBRARY_DIRS})
		add_definitions(${LIBPCI_CFLAGS_OTHER})
	endif(LIBPCI_FOUND)
endif(WITH_LIBPCI)

# Libegl
if(WITH_LIBEGL)
	pkg_check_modules(LIBEGL REQUIRED egl>1.4)
	find_package(OpenGL REQUIRED COMPONENTS OpenGL EGL)
	if(LIBEGL_FOUND AND OpenGL_OpenGL_FOUND AND OpenGL_EGL_FOUND)
		include_directories(${OPENGL_INCLUDE_DIRS} ${OPENGL_EGL_INCLUDE_DIRS})
		set(LIBOPENGL_LIBRARIES OpenGL::OpenGL OpenGL::EGL)
	endif(LIBEGL_FOUND AND OpenGL_OpenGL_FOUND AND OpenGL_EGL_FOUND)
endif(WITH_LIBEGL)

# Vulkan
if(WITH_VULKAN)
	find_package(Vulkan REQUIRED)
	if(Vulkan_FOUND)
		include_directories(${Vulkan_INCLUDE_DIRS})
		set(LIBVUKLAN_LIBRARIES ${Vulkan_LIBRARIES})
	endif(Vulkan_FOUND)
endif(WITH_VULKAN)

# OpenCL
if(WITH_OPENCL)
	find_package(OpenCL REQUIRED)
	if(OpenCL_FOUND)
		include_directories(${OpenCL_INCLUDE_DIRS})
		set(LIBOPENCL_LIBRARIES ${OpenCL_LIBRARIES})
	endif(OpenCL_FOUND)
endif(WITH_OPENCL)

# Libprocps
set(LIBSYSTEM_LIBRARIES)
set(LIBSYSTEM 0)
set(LIBPROC2 -1)
if(WITH_LIBPROCPS AND CMAKE_SYSTEM_NAME MATCHES "Linux" AND NOT FORCE_LIBSTATGRAB)
	pkg_check_modules(LIBPROC2 libproc2) # REQUIRED not present here to allow to fallback to libprocps
	if(LIBPROC2_FOUND)
		include_directories(${LIBPROC2_INCLUDE_DIRS})
		link_directories(${LIBPROC2_LIBRARY_DIRS})
		add_definitions(${LIBPROC2_CFLAGS_OTHER})
		set(LIBSYSTEM_LIBRARIES ${LIBPROC2_LIBRARIES})
		set(LIBSYSTEM 1)
		set(LIBPROC2 1)
	else()
		pkg_check_modules(LIBPROCPS REQUIRED libprocps)
		set(LIBPROC2 0)
	endif()
	if(LIBPROCPS_FOUND)
		include_directories(${LIBPROCPS_INCLUDE_DIRS})
		link_directories(${LIBPROCPS_LIBRARY_DIRS})
		add_definitions(${LIBPROCPS_CFLAGS_OTHER})
		set(LIBSYSTEM_LIBRARIES ${LIBPROCPS_LIBRARIES})
		set(LIBSYSTEM 1)
	endif(LIBPROCPS_FOUND)
endif(WITH_LIBPROCPS AND CMAKE_SYSTEM_NAME MATCHES "Linux" AND NOT FORCE_LIBSTATGRAB)

# Libstatgrab
if(WITH_LIBSTATGRAB AND (NOT CMAKE_SYSTEM_NAME MATCHES "Linux" OR FORCE_LIBSTATGRAB))
	pkg_check_modules(LIBSTATGRAB REQUIRED libstatgrab)
	if(LIBSTATGRAB_FOUND)
		include_directories(${LIBSTATGRAB_INCLUDE_DIRS})
		link_directories(${LIBSTATGRAB_LIBRARY_DIRS})
		add_definitions(${LIBSTATGRAB_CFLAGS_OTHER})
		set(LIBSYSTEM_LIBRARIES ${LIBSTATGRAB_LIBRARIES})
		set(LIBSYSTEM 2)
	endif(LIBSTATGRAB_FOUND)
endif(WITH_LIBSTATGRAB AND (NOT CMAKE_SYSTEM_NAME MATCHES "Linux" OR FORCE_LIBSTATGRAB))

# Dmidecode
if(WITH_DMIDECODE)
	add_subdirectory(core/dmidecode)
	include_directories(core/dmidecode)
	set(DMIDECODE_LIBRARIES "dmidecode")
endif(WITH_DMIDECODE)

# Bandwidth
if(CPU_ISA_X86 AND WITH_BANDWIDTH)
	add_subdirectory(core/bandwidth)
	if(BANDWIDTH_FOUND)
		include_directories(core/bandwidth)
		set(BANDWIDTH_LIBRARIES "bandwidth")
	endif(BANDWIDTH_FOUND)
endif(CPU_ISA_X86 AND WITH_BANDWIDTH)


### FINAL CONFIG

message("${BoldCyan}** ${CMAKE_PROJECT_NAME} ${PROJECT_VERSION} configuration (${CMAKE_SYSTEM_PROCESSOR}) **${ColourReset}")

# UI libraries
print_config("GTK"                 "${GTK3_VERSION}"            WITH_GTK)
print_config("NCURSES"             "${NCURSES_VERSION}"         WITH_NCURSES)

# Other libraries
print_config("GETTEXT"             "${GETTEXT_VERSION_STRING}"  WITH_GETTEXT)
print_config("LIBCPUID"            "${LIBCPUID_VERSION}"        WITH_LIBCPUID)
print_config("LIBPCI"              "${LIBPCI_VERSION}"          WITH_LIBPCI)
print_config("LIBEGL"              "${LIBEGL_VERSION}"          WITH_LIBEGL)
print_config("VULKAN"              "${Vulkan_VERSION}"          WITH_VULKAN)
print_config("OPENCL"              "${OpenCL_VERSION_STRING}"   WITH_OPENCL)
if(CMAKE_SYSTEM_NAME MATCHES "Linux" AND NOT FORCE_LIBSTATGRAB)
	if(${LIBPROC2} EQUAL 1)
		print_config("LIBPROC2"    "${LIBPROC2_VERSION}"        WITH_LIBPROCPS)
	else()
		print_config("LIBPROCPS"   "${LIBPROCPS_VERSION}"       WITH_LIBPROCPS)
	endif()
else()
	print_config("LIBSTATGRAB"     "${LIBSTATGRAB_VERSION}"     WITH_LIBSTATGRAB)
endif()

# Subprojects
print_config("DMIDECODE"           "${DMIDECODE_VERSION}"       WITH_DMIDECODE)
print_config("BANDWIDTH"           "${BANDWIDTH_VERSION}"       WITH_BANDWIDTH)


### BINARIES

# Executables
add_executable(${APP_EXEC}
	core/benchmarks.cpp
	core/core.cpp
	core/core.hpp
	core/internal.hpp
	daemon/client.cpp
	daemon/client.hpp
	daemon/daemon.h
	data.cpp
	data.hpp
	logger.cpp
	logger.hpp
	main.cpp
	options.cpp
	options.hpp
	util.cpp
	util.hpp
)

add_executable(${DAEMON_EXEC}
	daemon/server.cpp
	daemon/server.hpp
	daemon/daemon.h
	data.cpp
	data.hpp
	logger.cpp
	logger.hpp
	options.cpp
	options.hpp
	util.cpp
	util.hpp
)


# Additional source files
# GTK3+
if(WITH_GTK AND GTK3_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		ui/gtk.cpp
		ui/gtk.hpp
	)
endif(WITH_GTK AND GTK3_FOUND)

# NCurses
if(WITH_NCURSES AND NCURSES_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		ui/ncurses.cpp
		ui/ncurses.hpp
	)
endif(WITH_NCURSES AND NCURSES_FOUND)

# Libcpuid
if(WITH_LIBCPUID AND LIBCPUID_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		core/libcpuid.cpp
		core/databases.h
	)
	target_sources(${DAEMON_EXEC}
		PRIVATE
		core/libcpuid.cpp
		core/databases.h
	)
endif(WITH_LIBCPUID AND LIBCPUID_FOUND)

# Libpci
if(WITH_LIBPCI AND LIBPCI_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		core/libpci.cpp
	)
endif(WITH_LIBPCI AND LIBPCI_FOUND)

# Libegl
if(WITH_LIBEGL AND OpenGL_OpenGL_FOUND AND OpenGL_EGL_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		core/libopengl.cpp
	)
endif(WITH_LIBEGL AND OpenGL_OpenGL_FOUND AND OpenGL_EGL_FOUND)

# Vulkan
if(WITH_VULKAN AND Vulkan_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		core/libvulkan.cpp
	)
endif(WITH_VULKAN AND Vulkan_FOUND)

# OpenCL
if(WITH_OPENCL AND OpenCL_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		core/libopencl.cpp
		core/opencl_ext.h
	)
endif(WITH_OPENCL AND OpenCL_FOUND)

# Libsystem (libproc2/libprocps/libstatgrab)
if(${LIBSYSTEM} GREATER 0)
	target_sources(${APP_EXEC}
		PRIVATE
		core/libsystem.cpp
	)
endif(${LIBSYSTEM} GREATER 0)

# Dmidecode
if(WITH_DMIDECODE)
	target_sources(${APP_EXEC}
		PRIVATE
		core/dmidecode/libdmidecode.cpp
		core/dmidecode/libdmidecode.h
	)
	target_sources(${DAEMON_EXEC}
		PRIVATE
		core/dmidecode/libdmidecode.cpp
		core/dmidecode/libdmidecode.h
	)
endif(WITH_DMIDECODE)

# Bandwidth
if(WITH_BANDWIDTH AND BANDWIDTH_FOUND)
	target_sources(${APP_EXEC}
		PRIVATE
		core/bandwidth/libbandwidth.cpp
		core/bandwidth/libbandwidth.h
	)
endif(WITH_BANDWIDTH AND BANDWIDTH_FOUND)


### DEFINITIONS & LINK

# Libsystem extra-definitions
if(${LIBSYSTEM} EQUAL 0 OR ${LIBSYSTEM} EQUAL 1) # When Libprocps is used
	add_definitions(-DHAS_LIBSTATGRAB=0 -DLIBSTATGRAB_VERSION=NULL)
	if(${LIBPROC2} EQUAL 1)
		add_definitions(-DHAS_LIBPROCPS=0 -DLIBPROCPS_VERSION=NULL)
	else(${LIBPROC2} EQUAL 0)
		add_definitions(-DHAS_LIBPROC2=0  -DLIBPROC2_VERSION=NULL)
	endif()
endif()
if(${LIBSYSTEM} EQUAL 0 OR ${LIBSYSTEM} EQUAL 2) # When Libstatgrab is used
	add_definitions(-DHAS_LIBPROC2=0  -DLIBPROC2_VERSION=NULL)
	add_definitions(-DHAS_LIBPROCPS=0 -DLIBPROCPS_VERSION=NULL)
endif()

# ARM CPUs workarounds
if(CPU_ISA_ARM AND CMAKE_SYSTEM_NAME MATCHES "Linux")
	set(OTHER_LIBRARIES "-latomic")
endif(CPU_ISA_ARM AND CMAKE_SYSTEM_NAME MATCHES "Linux")

# AppImage workarounds
if(APPIMAGE)
	add_definitions(-DAPPIMAGE
		-DDAEMON_TMP_EXEC="/tmp/${DAEMON_EXEC}"
	)
endif(APPIMAGE)

# Flatpak workarounds
if(FLATPAK)
	add_definitions(-DFLATPAK)
	set(DAEMON_SOCKET cpu-x.sock)
	if(LIBCPUID_FOUND)
		# flatpak-spawn command will not be able to find libcpuid.so when starting cpu-x-daemon
		set(LIBCPUID_LIBRARIES "-l:libcpuid.a")
	endif(LIBCPUID_FOUND)
endif(FLATPAK)

# Various definitions
add_definitions(-DPRGVER="${PROJECT_VERSION}"
	-DGITREV="${GIT_REVISION}"
	-DSYSTEM_NAME="${CMAKE_SYSTEM_NAME}"
	-DSYSTEM_PROCESSOR="${CMAKE_SYSTEM_PROCESSOR}"
	-DC_COMPILER_ID="${CMAKE_C_COMPILER_ID}"
	-DHAS_LIBSYSTEM=${LIBSYSTEM}
	-DGETTEXT_PACKAGE="${CMAKE_PROJECT_NAME}"
	-DLOCALEDIR="${CMAKE_INSTALL_FULL_LOCALEDIR}"
	-DCPUX_DATA_DIRECTORY="${CPU_X_DATA_DIRECTORY}"
	-DTERMINFODIR="/lib/terminfo"
	-DDAEMON_EXEC="${DAEMON_EXEC}"
	-DDAEMON_PATH="${DAEMON_PATH}"
	-DSOCKET_NAME="${DAEMON_SOCKET}"
)

# Link libraries
target_link_libraries(${APP_EXEC}
	${Intl_LIBRARIES}
	${CMAKE_THREAD_LIBS_INIT}
	${Backtrace_LIBRARIES}
	std::filesystem

	${GTK3_LIBRARIES}
	${CURSES_LIBRARIES}
	${LIBCPUID_LIBRARIES}
	${LIBPCI_LIBRARIES}
	${LIBOPENGL_LIBRARIES}
	${LIBVUKLAN_LIBRARIES}
	${LIBOPENCL_LIBRARIES}
	${LIBSYSTEM_LIBRARIES}
	${DMIDECODE_LIBRARIES}
	${BANDWIDTH_LIBRARIES}
	${OTHER_LIBRARIES}
)

target_link_libraries(${DAEMON_EXEC}
	${Intl_LIBRARIES}
	${CMAKE_THREAD_LIBS_INIT}
	std::filesystem

	${LIBCPUID_LIBRARIES}
	${DMIDECODE_LIBRARIES}
)


### INSTALLATION

install(TARGETS ${APP_EXEC}    DESTINATION ${CMAKE_INSTALL_FULL_BINDIR}/)
install(TARGETS ${DAEMON_EXEC} DESTINATION ${CMAKE_INSTALL_FULL_LIBEXECDIR}/)
