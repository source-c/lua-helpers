PROJECT(lsqlite3 C)
cmake_minimum_required(VERSION 3.0.0)
add_library(lsqlite3 SHARED lsqlite3.c)
set_target_properties(lsqlite3 PROPERTIES PREFIX "")    
set(CMAKE_C_FLAGS  "-pedantic -std=c99 -Wall -O0 -ggdb") 


find_package(Lua 5.2 REQUIRED)
if (LUA_FOUND) 
  message ("LUA found:" ${LUA_LIBRARIES})
  include_directories(${LUA_INCLUDE_DIR})
  target_link_libraries (lsqlite3 ${LUA_LIBRARIES})
else()
  message ("ERROR! LUA not found")
endif (LUA_FOUND) 

find_library(SQLITE3_LIBRARY sqlite3)
if (SQLITE3_LIBRARY) 
  message ("SQLITE3 found")
  target_link_libraries (lsqlite3 ${SQLITE3_LIBRARY})
else()
  message (SEND_ERROR "ERROR! SQLITE not found")
endif (SQLITE3_LIBRARY) 

find_path(SQLITE3_INCLUDE_DIR sqlite3.h)
if(NOT SQLITE3_INCLUDE_DIR)
  message(SEND_ERROR "Failed to find sqlite3.h")
endif()

message("LINK FLAGS:" ${CMAKE_SHARED_LINKER_FLAGS} )

