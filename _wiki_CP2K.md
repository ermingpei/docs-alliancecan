# CP2K

CP2K is a quantum chemistry and solid state physics software package that can perform atomistic simulations of solid state, liquid, molecular, periodic, material, crystal, and biological systems.

## Versions

The latest version installed is CP2K 8.2. You can load the module compiled with GCC using:

```bash
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3 cp2k/8.2
```

You can also choose to use the version compiled with the Intel compiler, but it seems less stable as it sometimes crashes for unknown reasons:

```bash
module load StdEnv/2020 intel/2020.1.217 openmpi/4.0.3 cp2k/8.2
```

## Example Job

This example uses the static calculation example from the [CP2K website](https://www.cp2k.org/).

First, log into one of our clusters and download the needed files with the following commands:

```bash
wget https://www.cp2k.org/_media/static_calculation.tgz
tar xvfz static_calculation.tgz
cd static_calculation/sample_output_no_smearing
```

Then, in that directory, create the following job submission script (change `def-someuser` to your account name):

**File: `mpi_job.sh`**

```bash
#!/bin/bash
#SBATCH --account=def-someuser
#SBATCH --ntasks=4               # number of MPI processes
#SBATCH --mem-per-cpu=4G      # memory; default unit is megabytes
#SBATCH --time=0-00:15           # time (DD-HH:MM)
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3 cp2k/8.2
srun cp2k.popt -o Si_bulk8.out Si_bulk8.inp
```

To submit this job, execute:

```bash
sbatch mpi_job.sh
```

To see if the job completed, run:

```bash
sq
```

If your job is no longer listed, it has completed. The output of CP2K will be located in `Si_bulk8.out`. There will also be an output file named `slurm-*.out`, which should be empty if the calculation completed without error.


## Threaded/MPI Jobs

The installation of CP2K version 8.2 and later includes both the MPI executable `cp2k.popt` and the OpenMP/MPI executable `cp2k.psmp`, which may give better performance for some calculations. Our tests show a 10% performance increase for the `QS/H2O-512.inp` benchmark when using 2 threads per MPI process, compared to running the MPI-only executable `cp2k.popt` (both runs used the same number of CPU cores in total).

Below is an example OpenMP/MPI job submission file for the Beluga cluster.  For other clusters, adjust the number of tasks to match the available cores. Performance changes when using threads are highly problem-dependent; `cp2k.psmp` may be slower in some cases. Benchmark your code to choose the right option.

**File: `openmp_mpi_job.sh`**

```bash
#!/bin/bash
#SBATCH --account=def-someuser
#SBATCH --nodes=2
#SBATCH --ntasks=40               # number of MPI processes
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=3G      # memory; default unit is megabytes
#SBATCH --time=0-00:59           # time (DD-HH:MM)
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3 cp2k/8.2
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
srun --cpus-per-task=$OMP_NUM_THREADS cp2k.psmp -o H2O-512.out H2O-512.inp
```
