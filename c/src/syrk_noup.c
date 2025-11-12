#include <float.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <timer.h>
#include "mkl.h"
#include "result_writer.h"

int main(int argc, char* argv[])
{
  int n, k;
  double one = 1.0;
  double zero = 0.0;
  double *A, *C;
  double dtime, dtime_save = DBL_MAX, cs_time = DBL_MAX;

  if (argc < 3) {
    printf("pass me 2 arguments: n, k\n");
    return (-1);
  } else {
    n = atof(argv[1]);
    k = atof(argv[2]);
  }
  srand48((unsigned)time((time_t*)NULL));

  A = (double*)mkl_malloc(n * k * sizeof(double), 64);
  C = (double*)mkl_malloc(n * n * sizeof(double), 64);

  for (int i = 0; i < n * k; i++) A[i] = drand48();

  for (int it = 0; it < LAMP_REPS; it++) {

    for (int i = 0; i < n * n; i++) C[i] = 0.0;


    cs_time = cache_scrub();

    dtime = cclock();
    dsyrk("L", "N", &n, &k, &one, A, &n, &zero, C, &n);
    dtime_save = clock_min_diff(dtime_save, dtime);

  }
  mkl_free(A);
  mkl_free(C);

  printf("syrk_explicit_noup;%d;%d;%d;%e;%e\n", 0, k, n, dtime_save, cs_time);
  write_result(__FILE__, dtime_save);
  return (0);
}
