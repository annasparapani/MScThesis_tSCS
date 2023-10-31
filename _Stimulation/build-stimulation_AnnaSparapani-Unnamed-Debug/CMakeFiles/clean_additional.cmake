# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/stimulation_AnnaSparapani_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/stimulation_AnnaSparapani_autogen.dir/ParseCache.txt"
  "stimulation_AnnaSparapani_autogen"
  )
endif()
