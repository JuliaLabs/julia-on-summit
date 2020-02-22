using BinaryBuilder

const mappings = Dict(
    "OpenBLAS" => "julia",
    )

# okay this is stupid, but Overrides.toml path
# need to be able to append a `lib/libraryname.so`
#
# The julia vendored librarys are at `joinpath(Sys.BINDIR, Base.PRIVATE_LIBDIR)`
# so we need to create a symlink...
#

const VENDORED = joinpath(Sys.BINDIR, Base.PRIVATE_LIBDIR)
const JULIA_PRIVATE = abspath(Sys.BINDIR, "..", "local", "share", "julia")
const JULIA_PRIVATE_LIBDIR = joinpath(JULIA_PRIVATE, "lib")

mkpath(JULIA_PRIVATE)
rm(JULIA_PRIVATE_LIBDIR, force=true)
run(`ln -s $VENDORED $JULIA_PRIVATE_LIBDIR`)

open("Overrides.toml", "w") do io
    for (lib, map) in mappings
        uuid = BinaryBuilder.jll_uuid(string(lib, "_jll"))
    
        if map == "julia"
            path = JULIA_PRIVATE        
        else
            # TODO: Query spack/module to find the correct path.
            path = map
        end

        println(io, "[", uuid, "]")
        println(io, lib, " = \"", path, "\"")
        println(io)
    end
end
