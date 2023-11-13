cmake_minimum_required(VERSION 2.8)

project(provaFederico LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB THIS_APP_SOURCES *.cpp)
file(GLOB THIS_APP_HEADERS *.h)

add_executable(${PROJECT_NAME} ${THIS_APP_SOURCES} ${THIS_APP_HEADERS})

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -pthread")

find_package(QT NAMES Qt6 Qt5 COMPONENTS Core REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core REQUIRED)

#include_directories(HEADER_FILE_ONLY)

#add_executable(provaFederico
 # main.cpp
#)

add_library(libsmpt STATIC IMPORTED)
set_target_properties(libsmpt PROPERTIES
    IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libsmpt.a)

target_link_libraries(${PROJECT_NAME} pthread rt libsmpt)

target_link_libraries(provaFederico Qt${QT_VERSION_MAJOR}::Core)


