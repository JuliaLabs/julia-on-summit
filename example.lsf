#!/bin/bash
# Begin LSF Directives
#BSUB -P # YOUR PROJECT HERE
#BSUB -W 0:15
#BSUB -nnodes 1
#BSUB -J prof
#BSUB -o out.%J
#BSUB -e out.%J

module use $HOME/modulefiles
module load julia cuda/9.2.148 git spectrum-mpi

echo "Preparing environment..."
julia -e 'using Pkg; Pkg.API.precompile()'
julia -e 'using CUDAnative; CUDAnative.load_runtime.(CUDAnative.target_support)'
# julia -e 'using MPI; using CUDAdrv; using CuArrays'
echo

# PAMI_DISABLE_IPC is needed on Ascent/CUDA 9.2
jsrun -n 2 -r 2 -a 1 -g 1 -c 7 --smpiargs="-gpu -x PAMI_DISABLE_IPC=1" julia -e 'using InteractiveUtils; versioninfo()'
