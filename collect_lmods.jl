using JSON
library = JSON.Parser.parsefile("library.json")
mappings = library["mappings"]

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

paths = Dict{String, String}()
for (lib, map) in mappings
    map == "julia" && continue
    path = lmod(map)

    if path === nothing
        @warn "Could not map lib; Skipping" lib map
        continue
    end
    paths[lib] = path
end
open("paths.json", "w") do io
    write(io, json(paths)
end


