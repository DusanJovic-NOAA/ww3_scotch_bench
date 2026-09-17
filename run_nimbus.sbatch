#!/bin/bash
#SBATCH --nodes=11
#SBATCH --partition=superblock1
#SBATCH --ntasks-per-node=192
#SBATCH --cpus-per-task=1
#SBATCH --time=60
#SBATCH --job-name="test_scotch"
#SBATCH --output=tstscotch-impi.%j.out
#SBATCH --error=tstscotch-impi.%j.err

set -eo pipefail

source /opt/intel/oneapi/compiler/2026.1/env/vars.sh
source /opt/intel/oneapi/mpi/2021.18/env/vars.sh

module load pmix/5.0.11

# export I_MPI_HYDRA_IFACE=rdma0

# export FI_OFI_RXM_USE_ENV_ANY=1
# export FI_TCP_IFACE=rdma0
# export FI_VERBS_IFACE=rdma0

# # export FI_PROVIDER="verbs;ofi_rxm"
# export FI_PROVIDER="psm3"

# export FI_VERBS_INLINE_SIZE=39
# export FI_OFI_RXM_BUFFER_SIZE=4096
# export FI_UNIVERSE_SIZE=$SLURM_NTASKS

# export I_MPI_PIN_DOMAIN=numa

# export I_MPI_DEBUG=5


# libfabric logs
FI_LOG_LEVEL=""
FI_PROVIDER="psm3"

# Cloud RDMA
IRDMA_SHARED_UD_CREDITS=64
IRDMA_TRANSPARENT_UD_QD_OVERRIDE=1

# Intel MPI config defined in: https://www.intel.com/content/www/us/en/docs/mpi-library/developer-reference-linux/2021-8/overview.html
I_MPI_ADJUST_ALLREDUCE=4
I_MPI_ADJUST_ALLTOALL=1
I_MPI_ADJUST_BARRIER=7
I_MPI_ADJUST_BCAST=4
I_MPI_ADJUST_IALLTOALL=1
I_MPI_ADJUST_IBCAST=1
I_MPI_ADJUST_REDUCE=3
I_MPI_FABRICS="shm:ofi"
I_MPI_PIN_DOMAIN='omp'

# PSM3 config defined in: https://downloadmirror.intel.com/913765/632489_Intel_Ethernet_Fabric_Host_Software_User_Guide_v1.11.pdf
PSM3_ALLOW_ROUTERS=1
PSM3_ERRCHK_TIMEOUT="2000:2000"
PSM3_FLOW_CREDITS=256
PSM3_HAL="verbs"
PSM3_IDENTIFY=1
PSM3_MEMORY="large"
PSM3_MQ_RNDV_NIC_THRESH=65536
PSM3_MR_CACHE_MODE=1
PSM3_MR_CACHE_SIZE=512
PSM3_MTU="-1"
PSM3_NUM_RECV_WQES=32767
PSM3_NUM_RECV_CQES=65536
PSM3_RDMA=1
PSM3_RV_FR_PAGE_LIST_LEN=256
PSM3_RV_MR_CACHE_SIZE=1024
PSM3_SEND_REAP_THRESH=1

for task in 60 2008; do
srun --label --mpi=pmix -n ${task} ./ww3_scotch_part 1> mout.${task} 2> merr.${task}
done
