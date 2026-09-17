#!/bin/bash
#SBATCH --account=nems
#SBATCH --qos=debug
#SBATCH --nodes=11
#SBATCH --partition=u1-compute
#SBATCH --ntasks-per-node=192
#SBATCH --cpus-per-task=1
#SBATCH --time=30
#SBATCH --job-name="test_scotch"
#SBATCH --output=tstscotch-impi.%j.out
#SBATCH --error=tstscotch-impi.%j.err

set -eo pipefail

module load intel-oneapi-compilers/2026.1.0
module load intel-oneapi-mpi/2021.13.1

for task in 60 2008; do
srun --label --mpi=pmi2 -n ${task} ./ww3_scotch_part 1> mout.${task} 2> merr.${task}
done
