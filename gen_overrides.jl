using BinaryBuilder

const mappings = Dict(
    "OpenBLAS" => "julia",
    "SuiteSparse" => "julia",
    "HDF5" => "hdf5",
    )

# Arpack and OpenSpecFun currently load just fine

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
symlink(VENDORED, JULIA_PRIVATE_LIBDIR)


const LMOD = get(ENV, "LMOD_CMD", nothing)

function lmod(name)
  if LMOD === nothing
      return nothing
  end
  lines = readlines(`$LMOD --redirect show $name`)
  for line in lines
      m = match(r"LD_LIBRARY_PATH\\\",\\\"(.*)\\\"", line)
      if m !== nothing
          return dirname(m.captures[1])
      end
  end
  return nothing
end


open("Overrides.toml", "w") do io
    for (lib, map) in mappings
        uuid = BinaryBuilder.jll_uuid(string(lib, "_jll"))
    
        if map == "julia"
            path = JULIA_PRIVATE        
        else
            path = lmod(map)
        end

        if path === nothing
            @warn "Could not map lib; Skipping" lib map
            continue
        end

        println(io, "[", uuid, "]")
        println(io, lib, " = \"", path, "\"")
        println(io)
    end
end
