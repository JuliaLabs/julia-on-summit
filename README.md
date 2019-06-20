# julia-on-summit
Instructions and scripts to run Julia on Summit

## Compiling Julia

Currently Julia supports PowerPC on Julia 1.2 or the master branch

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
# LLVM_VER=8.0.0 # optional
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




