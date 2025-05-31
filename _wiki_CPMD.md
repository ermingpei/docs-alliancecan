# CPMD

CPMD is a plane wave/pseudo-potential DFT code for ab initio molecular dynamics simulations.

## License Limitations

In the past, access to CPMD required registration and confirmation with the developers, but registration on their website is no longer needed. However, the modules installed on our clusters are still protected by a POSIX group.

Before you can start using CPMD on our clusters, send us a support request and ask to be added to the POSIX group that will allow you to access the software.

## Module

You can access CPMD by loading a module:

```bash
module load StdEnv/2020
module load intel/2020.1.217 openmpi/4.0.3 cpmd/4.3
```

## Local Installation of CPMD

It has recently been our experience that a response from CPMD admins can unfortunately take weeks or even months. If you are a registered CPMD user, you have access to the CPMD source files and can therefore build the software yourself in your `/home` directory using our software environment called EasyBuild, with the exact same recipe that we would use for a central installation.

Below are instructions on how to build CPMD 4.3 under your account on the cluster of your choice:

1. Create a local directory:

```bash
$ mkdir -p ~/.local/easybuild/sources/c/CPMD
```

2. Place all the CPMD source tarballs and patches into that directory.  The following files should be present:

```bash
$ ls -al ~/.local/easybuild/sources/c/CPMD
cpmd2cube.tar.gz
cpmd2xyz-scripts.tar.gz
cpmd-v4.3.tar.gz
fourier.tar.gz
patch.to.4612
patch.to.4615
patch.to.4616
patch.to.4621
patch.to.4624
patch.to.4627
```

3. Then run the EasyBuild command:

```bash
$ eb CPMD-4.3-iomkl-2020a.eb --rebuild
```

The `--rebuild` option forces EasyBuild to ignore CPMD 4.3 installed in a central location and proceed instead with the installation in your `/home` directory.

4. Once the software is installed, log out and log back in.

Now, when you type `module load cpmd`, the software installed in your `/home` directory will get picked up.

```bash
$ module load StdEnv/2020
$ module load intel/2020.1.217 openmpi/4.0.3 cpmd/4.3
$ which cpmd.x
~/.local/easybuild/software/2020/avx2/MPI/intel2020/openmpi4/cpmd/4.3/bin/cpmd.x
```

You can use it now as usual in your submission script.


## Example of a Job Script

To run a job, you will need to set an input file and access to the pseudo-potentials.

If the input file and the pseudo-potentials are in the same directory, the command to run the program in parallel is:

```bash
srun cpmd.x <input files> > <output file>
```

(as in script 1)

It is also possible to put the pseudo-potentials in another directory with:

```bash
srun cpmd.x <input files> <path to pseudo potentials location> > <output file>
```

(as in script 2)


### INPUT

#### File: `1-h2-wave.inp`

```
&INFO
isolated hydrogen molecule.
single point calculation.
&END

&CPMD
 OPTIMIZE WAVEFUNCTION
 CONVERGENCE ORBITALS
  1.0d-7
 CENTER MOLECULE ON
 PRINT FORCES ON
&END  

&SYSTEM
 SYMMETRY
  1
 ANGSTROM
 CELL
  8.00 1.0 1.0  0.0  0.0  0.0
 CUTOFF
  70.0
&END 

&DFT
 FUNCTIONAL LDA
&END  

&ATOMS
*H_MT_LDA.psp
 LMAX=S
  2
 4.371   4.000   4.000
 3.629   4.000   4.000
&END
```

#### File: `run-cpmd.sh` (Script 1)

```bash
#!/bin/bash
#SBATCH --account=def-someacct
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=2500M
#SBATCH --time=0-1:00
# Load the modules:
module load StdEnv/2020
module load intel/2020.1.217 openmpi/4.0.3 cpmd/4.3
echo "Starting run at: `date`"
CPMD_INPUT="1-h2-wave.inp"
CPMD_OUTPUT="1-h2-wave_output.txt"
srun cpmd.x ${CPMD_INPUT} > ${CPMD_OUTPUT}
echo "Program finished with exit code $? at: `date`"
```

#### File: `run-cpmd.sh` (Script 2)

```bash
#!/bin/bash
#SBATCH --account=def-someacct
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=2500M
#SBATCH --time=0-1:00
# Load the modules:
module load StdEnv/2020
module load intel/2020.1.217 openmpi/4.0.3 cpmd/4.3
echo "Starting run at: `date`"
CPMD_INPUT="1-h2-wave.inp"
CPMD_OUTPUT="1-h2-wave_output.txt"
PP_PATH=<path to the location of pseudo-potentials>

srun cpmd.x ${CPMD_INPUT} ${PP_PATH} > ${CPMD_OUTPUT}
echo "Program finished with exit code $? at: `date`"
```

## Related Link

[CPMD home page](link_to_cpmd_homepage)


