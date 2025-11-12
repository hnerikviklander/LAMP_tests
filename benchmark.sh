#!/usr/bin/env bash
set -euo pipefail

########################################
# Environment setup
########################################
export RESULTS_FILE="n_6k"
export LAMP_N=6000
export RHS=200
export LAMP_L3_CACHE_SIZE="${LAMP_L3_CACHE_SIZE:-7500000}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
export LAMP_REPS="${LAMP_REPS:-10}"

echo "Running all tests..."
echo "RESULTS_FILE=$RESULTS_FILE"
echo "LAMP_N=$LAMP_N"
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"
echo


OUTPUT_DIR="results"
mkdir -p "$OUTPUT_DIR"

start_time=$(date +%s.%N)

TESTS=(
  "c/bin/diagmm.x                       $LAMP_N"
  "c/bin/gemm.x                          $LAMP_N $LAMP_N $LAMP_N"
  "c/bin/gemm_noup.x                     $LAMP_N $LAMP_N $LAMP_N"
  "c/bin/mc_mixed.x                      $LAMP_N $LAMP_N $LAMP_N"
  "c/bin/solve_naive.x                   $LAMP_N $RHS"
  "c/bin/solve_recommended.x             $LAMP_N $RHS"
  "c/bin/solve_recommended_dia.x         $LAMP_N $RHS"
  "c/bin/solve_recommended_spd.x         $LAMP_N $RHS"
  "c/bin/solve_recommended_sym.x         $LAMP_N $RHS"
  "c/bin/solve_recommended_tri.x         $LAMP_N $RHS"
  "c/bin/subexpr_nai.x                   $LAMP_N $LAMP_N"
  "c/bin/subexpr_rec.x                   $LAMP_N $LAMP_N"
  "c/bin/syr2k.x                         $LAMP_N $LAMP_N"
  "c/bin/syr2k_noup.x                    $LAMP_N $LAMP_N"
  "c/bin/syrk.x                          $LAMP_N $LAMP_N"
  "c/bin/syrk_noup.x                     $LAMP_N $LAMP_N"
  "c/bin/transposition.x                 $LAMP_N $LAMP_N $LAMP_N"
  "c/bin/trmm.x                          $LAMP_N $LAMP_N"
)

for CMD in "${TESTS[@]}"; do
  echo "----------------------------------------"
  echo "Running: $CMD"
  eval "$CMD" || { echo "Test failed: $CMD"; exit 1; }
done

echo "========================================"
echo "Running C++ Armadillo benchmark..."
echo "========================================"

if [[ -x "cpp/armadillo/bench_armadillo" ]]; then
  ./cpp/armadillo/bench_armadillo || { echo "bench_armadillo failed"; exit 1; }
else
  echo "  C++ executable cpp/armadillo/bnch_armadillo not found or not executable"
fi

echo "========================================"
echo "Running Julia benchmark..."
echo "========================================"

if command -v julia &> /dev/null; then
  julia julia/main.jl || { echo "Julia benchmark failed"; exit 1; }
else
  echo "  Julia not found in PATH — skipping Julia benchmark."
fi
end_time=$(date +%s.%N)
elapsed=$(echo "$end_time - $start_time" | bc)
echo "Total time: ${elapsed}s"