whatis("Name : julia v1.2.0-rc1")
whatis("Short description : The Julia programming language.")
help([[The Julia programming language.]])
depends_on("gcc/6.4.0")
always_load("cmake")
add_property("state","experimental")
prepend_path("PATH","/ccsopen/proj/gen126/julia-1.2.0-rc1/bin")

