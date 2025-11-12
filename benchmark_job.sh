#!/bin/bash
#SBATCH -A hpc2n2025-035
#SBATCH --time=00:2:00
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

set -euo pipefail

export RESULTS_FILE="lamp_result_test_run_1"
export LAMP_N="${LAMP_N:-1000}"
export LAMP_L3_CACHE_SIZE="${LAMP_L3_CACHE_SIZE:-7500000}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export LAMP_REPS="${LAMP_REPS:-10}"



srun --cpu-bind=cores ./c/bin/diagmm.x                        $LAMP_N
srun --cpu-bind=cores ./c/bin/gemm.x                          $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/gemm_noup.x                     $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/mc_mixed.x                      $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/solve_naive.x                   $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/solve_recommended.x             $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/solve_recommended_dia.x         $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/solve_recommended_spd.x         $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/solve_recommended_sym.x         $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/subexpr_nai.x                   $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/subexpr_rec.x                   $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syr2k.x                         $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syr2k_noup.x                    $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syrk.x                          $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/syrk_noup.x                     $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/transposition.x                 $LAMP_N $LAMP_N $LAMP_N
srun --cpu-bind=cores ./c/bin/trmm.x                          $LAMP_N $LAMP_N


srun --cpu-bind=cores ./cpp/armadillo/bench_armadillo 

srun --cpu-bind=cores julia julia/main.jl
