# julia-on-summit
Instructions and scripts to run Julia on Summit

## Compiling Julia

Currently Julia supports PowerPC on Julia 1.2 and above.

1. Download the Julia source code and configure the out-of-tree build.

```sh
module load gcc/6.4.0 cmake git
module unload xalt # xalt breaks SUITESPARSE compilation
git clone https://github.com/JuliaLang/julia
cd julia

# optionally: git checkout v1.2.0
# Setup out-of-tree build
make O=$HOME/builds/julia configure
```

2. Configure the build. Julia uses a `Make.user` file to adapt the build. 

```sh
cd $HOME/builds/julia
cat <<EOF > Make.user
USE_BINARYBUILDER=0
EOF
```

3. Compile Julia and dependencies

```sh
make -j
```

4. Install Julia to a prefix

```sh
PREFIX="/path/to/julia"
make prefix=${PREFIX} install

eval `make print-JULIA_VERSION`
mkdir -p ${HOME}/modulefiles/julia/

cat <<EOF > ${HOME}/modulefiles/julia/${JULIA_VERSION}.lua
whatis("Name : julia v${JULIA_VERSION}")
whatis("Short description : The Julia programming language.")
help([[The Julia programming language.]])
depends_on("gcc/6.4.0")
always_load("cmake")
add_property("state","experimental")
prepend_path("PATH","${PREFIX}/bin")
EOF
```

## Julia 1.3+

Julia 1.3 started using [Artifacts](https://julialang.github.io/Pkg.jl/v1.3/artifacts/). These are prebuilt binaries for dependencies,
to provide a transparent and user-friendly way to develiver binary dependencies. The buildservice for PowerPC has as a lowest common
denominator GLIBC v2.25. As of writing most IBM based supercomputers are configured with a RedHat 7.X system (including Summit),
which has a GLIBC v2.17. (See `ldd --version`). Due that we can not use `Artifacts` on Julia 1.3+

Luckily Julia has an override mechanism that we can use to substitute artifacts with system provided versions. See the `gen_overrides.jl`
script on how to create a list of overrides for the packages you are interested in. The generated `Overrides.toml` should be placed in one
of the depots in `Base.DEPOT_PATH`, at `artifcats/Overrides.toml`.




