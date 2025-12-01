#!/bin/bash
#SBATCH -A hpc2n2025-035
#SBATCH --time=00:5:00
# Send stderr of my program into <jobid>.error
#SBATCH --error=%J.error

# Send stdout of my program into <jobid>.output
#SBATCH --output=%J.output

# Sequantial mode
#SBATCH -n 1
#SBATCH --cpus-per-task=1 

# Clear the environment from any previously loaded modules
ml purge  > /dev/null 2>&1
ml foss/2021b
module load GCC/14.3.0
module load OpenMPI/5.0.8
module load imkl/2025.1.0
module load Armadillo/15.0.1
module load Julia/1.12.1-linux-x86_64

set -euo pipefail

export RHS=200
export RESULTS_FILE="3k"
export LAMP_N=3000
export LAMP_L3_CACHE_SIZE=50500000
export OMP_NUM_THREADS=1
export LAMP_REPS=10

start_time=$(date +%s.%N)
start_time_julia=$(date +%s.%N)
export JULIA_PROJECT="$HOME/lamp/LAMP_bench/julia"

srun --cpu-bind=cores julia --project="$JULIA_PROJECT" julia/main.jl
end_time_julia=$(date +%s.%N)

start_time_c=$(date +%s.%N)
srun --cpu-bind=cores ./c/bin/diagmm.x                        $LAMP_N
srun --cpu-bind=cores ./c/bin/gemm.x                          $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/gemm_noup.x                     $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/mc_mixed.x                      $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/solve_naive.x                   $LAMP_N $RHS
srun --cpu-bind=cores ./c/bin/solve_recommended.x             $LAMP_N $RHS
srun --cpu-bind=cores ./c/bin/solve_recommended_dia.x         $LAMP_N $RHS
srun --cpu-bind=cores ./c/bin/solve_recommended_spd.x         $LAMP_N $RHS
srun --cpu-bind=cores ./c/bin/solve_recommended_sym.x         $LAMP_N $RHS
srun --cpu-bind=cores ./c/bin/solve_recommended_tri.x         $LAMP_N $RHS
srun --cpu-bind=cores ./c/bin/subexpr_nai.x                   $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/subexpr_rec.x                   $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syr2k.x                         $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syr2k_noup.x                    $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syrk.x                          $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syrk_noup.x                     $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/transposition.x                 $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/trmm.x                          $LAMP_N $LAMP_N
end_time_c=$(date +%s.%N)

start_time_armadillo=$(date +%s.%N)
srun --cpu-bind=cores ./cpp/armadillo/bench_armadillo
end_time_armadillo=$(date +%s.%N)

end_time=$(date +%s.%N)
elapsed=$(echo "$end_time - $start_time" | bc)
elapsed_julia=$(echo "$end_time_julia - $start_time_julia" | bc)
elapsed_c=$(echo "$end_time_c - $start_time_c" | bc)
elapsed_armadillo=$(echo "$end_time_armadillo - $start_time_armadillo" | bc)
echo "Total time: ${elapsed}s"
echo "Julia tests: ${elapsed_julia}s"
echo "C tests: ${elapsed_c}s"
echo "Armadillo tests: ${elapsed_armadillo}s"