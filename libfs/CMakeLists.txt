PROJECT(libfs C)
cmake_minimum_required(VERSION 3.0.0)

add_library(fs SHARED libfs.c)
set(CMAKE_C_FLAGS "-fPIC -DLUA_52UP -DRELEASE=\"$(VERSION)\" -pedantic -std=c99 -Wall -O2") 

find_package(Lua 5.2 REQUIRED)
if (LUA_FOUND) 
  message ("LUA found: include: " ${LUA_INCLUDE_DIR})
  include_directories(${LUA_INCLUDE_DIR})
  target_link_libraries (fs ${LUA_LIBRARIES})
else()
  message ("ERROR! LUA not found")
endif (LUA_FOUND) 

