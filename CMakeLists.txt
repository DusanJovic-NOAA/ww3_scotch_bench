cmake_minimum_required(VERSION 3.24)

project(ww3_scotch_bench LANGUAGES C CXX Fortran)

find_package(MPI REQUIRED C CXX Fortran)

set(SCOTCH_DETERMINISTIC FULL)
add_subdirectory(scotch)

add_executable(ww3_scotch_part ww3_scotch_part.F90)
target_link_libraries(ww3_scotch_part ptscotchparmetisv3 ptscotch ptscotcherr scotch MPI::MPI_Fortran)
