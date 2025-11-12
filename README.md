# LAMP_tests

Before running the Julia benchmarks on HPC2N, you must **initialize the local Julia environment**.  
This ensures that Julia uses the **Intel MKL** backend instead of the default OpenBLAS.

### Load the Julia module
```bash
module load Julia/1.12.1-linux-x86_64


cd ~/LAMP_bench/julia


julia --project=julia -e '
using Pkg;
Pkg.activate(".");
Pkg.add("MKL");
using MKL, LinearAlgebra;
@info "BLAS backend" BLAS.get_config();
'
```

