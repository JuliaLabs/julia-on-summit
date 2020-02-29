using JSON

VENDORED = joinpath(Sys.BINDIR, Base.PRIVATE_LIBDIR)
JULIA_PRIVATE = abspath(Sys.BINDIR, "..", "local", "share", "julia")
ARTIFACTS = joinpath(JULIA_PRIVATE, "artifacts") 
OVERRIDES = joinpath(ARTIFACTS, "overrides")

mkpath(OVERRIDES)

function install_link(linkname, target)
    path = joinpath(OVERRIDES, linkname)
    mkpath(dirname(path))
    rm(path, force=true)
    symlink(target, path)
    return path
end

# okay this is stupid, but Overrides.toml path
# need to be able to append a `lib/libraryname.so`
#
# The julia vendored librarys are at `joinpath(Sys.BINDIR, Base.PRIVATE_LIBDIR)`
# so we need to create a symlink to that.
install_link(joinpath("julia","lib"), VENDORED)
JULIA_OVERRIDE = joinpath(OVERRIDES, "julia")

const OVERRIDE_MAP = Dict{String, String}(
    "julia" => JULIA_OVERRIDE,
)
library = JSON.Parser.parsefile("library.json")
mappings = library["mappings"]
uuids = library["uuids"]

if isfile("paths.json")
    paths = JSON.Parser.parsefile("paths.json")

    # CompilerSupportLibraries
    if haskey(paths, "gcc")
        csl = paths["gcc"]
        install_link(joinpath("gcc", "lib"), joinpath(csl, "lib64"))
        install_link(joinpath("gcc", "bin"), joinpath(csl, "bin"))
        OVERRIDE_MAP["gcc"] = joinpath(OVERRIDES, "gcc")
        delete!(paths, "gcc")
    end

    append!(OVERRIDE_MAP, paths)
else
    @warn "library.json not present, run collect_lmods.jl"
end

open(joinpath(ARTIFACTS, "Overrides.toml"), "w") do io
    for (lib, map) in mappings
        UUID = uuids[lib]
        
        if !haskey(OVERRIDE_MAP, map)
            @warn "Could not map lib; Skipping" lib map
            continue
        end
        path = OVERRIDE_MAP[map]

        println(io, "[", uuid, "]")
        println(io, lib, " = \"", path, "\"")
        println(io)
    end
end
