project(po
	LANGUAGES NONE
)


### INTERNATIONALIZATION TARGETS

# PO files
set(pot_file ${CMAKE_PROJECT_NAME}.pot)
file(GLOB
	po_files
	*.po
)

if(GETTEXT_FOUND)
	set(GETTEXT_FOUND ON PARENT_SCOPE)
	include(gettext_create_translations)
	file(GLOB_RECURSE CPP_FILES
		RELATIVE "${CMAKE_SOURCE_DIR}/src"
		"${CMAKE_SOURCE_DIR}/src/*.c"
		"${CMAKE_SOURCE_DIR}/src/*.cpp"
		"${CMAKE_SOURCE_DIR}/src/*.h"
		"${CMAKE_SOURCE_DIR}/src/*.hpp"
	)
	add_custom_target(genpot
		COMMAND xgettext
			--language=C++
			--keyword=_ --keyword=N_ --indent
			--add-comments=TRANSLATORS:
			--package-name=${CMAKE_PROJECT_NAME}
			--package-version=${PROJECT_VERSION}
			--default-domain=${CMAKE_PROJECT_NAME}
			--msgid-bugs-address=https://github.com/TheTumultuousUnicornOfDarkness/CPU-X/issues
			--copyright-holder=TheTumultuousUnicornOfDarkness
			--output-dir=${CMAKE_CURRENT_BINARY_DIR}
			--output=source_c.pot
			--directory="${CMAKE_SOURCE_DIR}/src"
			--from-code="utf-8"
			${CPP_FILES}
		COMMAND xgettext
			--language=Glade
			--keyword=translatable --indent
			--add-comments
			--package-name=${CMAKE_PROJECT_NAME}
			--package-version=${PROJECT_VERSION}
			--default-domain=${CMAKE_PROJECT_NAME}
			--msgid-bugs-address=https://github.com/TheTumultuousUnicornOfDarkness/CPU-X/issues
			--copyright-holder=TheTumultuousUnicornOfDarkness
			--output-dir=${CMAKE_CURRENT_BINARY_DIR}
			--output=source_ui.pot
			--directory="${CMAKE_SOURCE_DIR}/data"
			--from-code="utf-8"
			"cpu-x-gtk-3.12.ui"
		COMMAND xgettext
			--language=Desktop
			--keyword --keyword=Comment --keyword=Keywords --indent
			--package-name=${CMAKE_PROJECT_NAME}
			--package-version=${PROJECT_VERSION}
			--default-domain=${CMAKE_PROJECT_NAME}
			--msgid-bugs-address=https://github.com/TheTumultuousUnicornOfDarkness/CPU-X/issues
			--copyright-holder=TheTumultuousUnicornOfDarkness
			--output-dir=${CMAKE_CURRENT_BINARY_DIR}
			--output=source_desktop.pot
			--directory="${CMAKE_SOURCE_DIR}/data"
			--from-code="utf-8"
			"io.github.thetumultuousunicornofdarkness.cpu-x.desktop.in"
		COMMAND	msgcat --indent --directory=${CMAKE_CURRENT_BINARY_DIR} source_c.pot source_ui.pot source_desktop.pot --output-file="${CMAKE_CURRENT_SOURCE_DIR}/${pot_file}"
		COMMAND sed --in-place "s/SOME DESCRIPTIVE TITLE./CPU-X translations template/" "${CMAKE_CURRENT_SOURCE_DIR}/${pot_file}"
		COMMAND sed --in-place "s/\\(C\\) YEAR/© 2014-2025/"  "${CMAKE_CURRENT_SOURCE_DIR}/${pot_file}"
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src
	)
	GETTEXT_CONVERT_TRANSLATIONS(${pot_file} ALL ${po_files})
else(GETTEXT_FOUND)
	set(GETTEXT_FOUND OFF PARENT_SCOPE)
endif(GETTEXT_FOUND)
