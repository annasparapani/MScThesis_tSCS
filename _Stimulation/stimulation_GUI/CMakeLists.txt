cmake_minimum_required(VERSION 3.5)

project(stimulation_GUI LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check https://doc.qt.io/qt/deployment-android.html for more information.
# They need to be set before the find_package( ...) calls below.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()

find_package(QT NAMES Qt6 Qt5 COMPONENTS Widgets REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Widgets REQUIRED)

set(PROJECT_SOURCES
        main.cpp
        mainwindow.cpp
        mainwindow.h
        mainwindow.ui
        headers.h
        globals.h
        globals.cpp
        protocol1.cpp
        protocol1.h
        protocol1.ui
        protocol2.cpp
        protocol2.h
        protocol2.ui
        protocol3.cpp
        protocol3.h
        protocol3.ui
        protocol4.cpp
        protocol4.h
        protocol4.ui

)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(stimulation_GUI
        ${PROJECT_SOURCES}
    )
else()
    if(ANDROID)
        add_library(stimulation_GUI SHARED
            ${PROJECT_SOURCES}
        )
    else()
        add_executable(stimulation_GUI
            ${PROJECT_SOURCES}
        )
    endif()
endif()

target_link_libraries(stimulation_GUI PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)
