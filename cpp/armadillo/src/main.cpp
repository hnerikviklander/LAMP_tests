#include <iostream>
#include <string>
#include <charconv> 
#include <cstdlib>
#include <filesystem>

#include "../include/benchmarks.h"

using std::string;

static inline string make_output_filename(const char* base_env, const string& suffix, const string& directory)
{

  const char* env_filename = std::getenv(base_env);
  string filename;

  if (env_filename && *env_filename) {
      filename = env_filename;
      // Insert suffix before extension if there is one
      size_t dot = filename.find_last_of('.');
      if (dot != string::npos)
          filename.insert(dot, suffix);
      else
          filename += suffix;
  } else {
      filename = string("default") + suffix + ".txt";
  }

  return directory + "/" + filename;
}


int main(int argc, char* argv[])
{
  const int n = std::atoi(std::getenv("LAMP_N"));
  const int cache_size = std::atoi(std::getenv("LAMP_L3_CACHE_SIZE"));
  const int reps = std::atoi(std::getenv("LAMP_REPS"));

  const string output_dir = "results";

  string file_name         = make_output_filename("RESULTS_FILE", "_armadillo", output_dir);
  string file_timings_name = make_output_filename("RESULTS_FILE", "_armadillo_timings", output_dir);

  string name = "Armadillo";

  std::cout << "Output file: " << file_name << "\n";
  std::cout << "Timing file: " << file_timings_name << "\n";

  Benchmarker b(name, file_name, file_timings_name, cache_size, reps, ';');

  bench_gemm(b, n);
  bench_syrk(b, n);
  bench_syr2k(b, n);
  bench_add_scal(b, n);

  bench_matrix_chain(b, n);
  bench_subexpression(b, n);
  bench_partial_operand(b, n);
  bench_loop_translation(b, n);
  bench_diagonal_elements(b, n);
  bench_properties_solve(b, n);
  bench_composed_operations(b, n);
  bench_transposition(b, n);
  bench_index_problems(b, n);
  bench_partitioned_matrices(b, n);

  return 0;
}
