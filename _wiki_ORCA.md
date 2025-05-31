# ORCA

## Introduction

ORCA is a flexible, efficient, and easy-to-use general-purpose tool for quantum chemistry with specific emphasis on spectroscopic properties of open-shell molecules. It features a wide variety of standard quantum chemical methods ranging from semiempirical methods to DFT to single- and multireference correlated *ab initio* methods. It can also treat environmental and relativistic effects.

## Licensing

If you wish to use prebuilt ORCA executables:

You have to register at [https://orcaforum.kofo.mpg.de/](https://orcaforum.kofo.mpg.de/).

You will receive a first email to verify the email address and activate the account. Follow the instructions in that email.

Once the registration is complete, you will get a second email stating that the "registration for ORCA download and usage has been completed". Contact us requesting access to ORCA with a copy of the second email.

## ORCA versions

### ORCA 6

A module `orca/6.0.1` is available under the environment `StdEnv/2023`. To load this module, use:

```bash
module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 orca/6.0.1
```

There is another module `orca/6.0.0`. However, ORCA users should use the latest version `orca/6.0.1` as it addresses some bugs of the first release `6.0.0`.

**Note:** This version of ORCA includes xtb 6.7.1.

### ORCA 5

Versions 5.0.1 through 5.0.3 have some bugs that were fixed in version 5.0.4, most notably a bug involving D4 dispersion gradients. We therefore recommend that you use the version 5.0.4 instead of any earlier 5.0.x version. Versions 5.0.1, 5.0.2, and 5.0.3 are in our software stack but might be removed in the future.

To load version 5.0.4, use

```bash
module load StdEnv/2020  gcc/10.3.0  openmpi/4.1.1 orca/5.0.4
```

### ORCA 4

To load version 4.2.1, use

```bash
module load StdEnv/2020  gcc/9.3.0  openmpi/4.0.3 orca/4.2.1
```

or

```bash
module load nixpkgs/16.09  gcc/7.3.0  openmpi/3.1.4 orca/4.2.1
```

## Setting ORCA input files

In addition to the different keywords required to run a given simulation, you should make sure to set two additional parameters:

*   number of CPUs
*   `maxcore`

## Using the software

To see which versions of ORCA are currently available, type `module spider orca`. For detailed information about a specific version, including the other modules that must be loaded first, use the module's full name. For example, `module spider orca/4.0.1.2`.

See [Using modules](link-to-using-modules-page) for general guidance.

### Job submission

For a general discussion about submitting jobs, see [Running jobs](link-to-running-jobs-page).

**NOTE:** If you run into MPI errors with some of the ORCA executables, you can try to define the following variables:

```bash
export OMPI_MCA_mtl='^mxm'
export OMPI_MCA_pml='^yalla'
```

The following is a job script to run ORCA using MPI. Note that, unlike most MPI programs, ORCA is not started with a parallel launch command such as `mpirun` or `srun`, but requires the full path to the program, which is given by `$EBROOTORCA`.

**File:** `run_orca.sh`

```bash
#!/bin/bash
#SBATCH --account=def-youPIs
#SBATCH --ntasks=8                 # cpus, the nprocs defined in the input file
#SBATCH --mem-per-cpu=3G           # memory per cpu
#SBATCH --time=00-03:00            # time (DD-HH:MM)
#SBATCH --output=benzene.log       # output .log file
module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3
module load orca/4.2.1
$EBROOTORCA/orca benzene.inp
```

**Example of the input file, benzene.inp:**

**File:** `benzene.inp`

```
# Benzene RHF Opt Calculation
%pal nprocs 8 end
! RHF TightSCF PModel
! opt

* xyz 0 1
     C    0.000000000000     1.398696930758     0.000000000000
     C    0.000000000000    -1.398696930758     0.000000000000
     C    1.211265339156     0.699329968382     0.000000000000
     C    1.211265339156    -0.699329968382     0.000000000000
     C   -1.211265339156     0.699329968382     0.000000000000
     C   -1.211265339156    -0.699329968382     0.000000000000
     H    0.000000000000     2.491406946734     0.000000000000
     H    0.000000000000    -2.491406946734     0.000000000000
     H    2.157597486829     1.245660462400     0.000000000000
     H    2.157597486829    -1.245660462400     0.000000000000
     H   -2.157597486829     1.245660462400     0.000000000000
     H   -2.157597486829    -1.245660462400     0.000000000000
*
```

### Notes

To make sure that the program runs efficiently and makes use of all the resources or the cores asked for in your job script, please add this line `%pal nprocs <ncores> end` to your input file as shown in the above example. Replace `<ncores>` by the number of cores you used in your script.

If you want to restart a calculation, delete the file `*.hostnames` (e.g., `benzene.hostnames` in the above example) before you submit the followup job. If you do not, the job is likely to fail with the error message "All nodes which are allocated for this job are already filled."

### (Sep. 6 2019) Temporary fix to OpenMPI version inconsistency issue

For some types of calculations (DLPNO-STEOM-CCSD in particular), you could receive unknown openmpi-related fatal errors. This could be due to using an older version of openmpi (i.e., 3.1.2 as suggested by 'module' for both orca/4.1.0 and 4.2.0) than recommended officially (3.1.3 for orca/4.1.0 and 3.1.4 for orca/4.2.0). To temporarily fix this issue, one can build a custom version of openmpi.

The following two commands prepare a custom openmpi/3.1.4 for orca/4.2.0:

```bash
module load gcc/7.3.0
eb OpenMPI-3.1.2-GCC-7.3.0.eb --try-software-version=3.1.4
```

When the building is finished, you can load the custom openmpi using module

```bash
module load openmpi/3.1.4
```

At this step, one can manually install orca/4.2.0 binaries from the official forum under the home directory after finishing the registration on the official orca forum and being granted access to the orca program on our clusters.

**Additional notes from the contributor:** This is a *temporary* fix prior to the official upgrade of openmpi on our clusters. Please remember to delete the manually installed orca binaries once the official openmpi version is up to date. The compiling command does not seem to apply to openmpi/2.1.x.

## Using NBO with ORCA

To run NBO with ORCA, one needs to have access to NBO. On our clusters, NBO is not available as a separate module. However, it is possible to access it via the Gaussian modules which are installed on Cedar and Graham. Users interested in using NBO with ORCA should have access to ORCA and Gaussian. To get access to Gaussian, you can follow the steps discussed on this [page](link-to-gaussian-access-page).

### Script example

The name of the input file (in this next example `orca_input.inp`) should contain the keyword `NBO`.

**File:** `run_orca-nbo.sh`

```bash
#!/bin/bash
#SBATCH --account=def-youPIs
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=4000
#SBATCH --time=0-3:00:00
# Load the modules:
module load StdEnv/2020 gcc/10.3.0 openmpi/4.1.1 orca/5.0.4
module load gaussian/g16.c01
export GENEXE=`which gennbo.i4.exe`
export NBOEXE=`which nbo7.i4.exe`
$EBROOTORCA/orca orca_input.inp > orca_output.out
```

## Related links

*   [ORCA tutorials](link-to-orca-tutorials)
*   [ORCA Forum](https://orcaforum.kofo.mpg.de/)


**(Remember to replace the bracketed placeholders like `[link-to-using-modules-page]` with the actual links.)**
