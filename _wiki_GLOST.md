# GLOST: Greedy Launcher Of Small Tasks

## Other languages:

* English
* français


## 1 Introduction

GLOST, the Greedy Launcher Of Small Tasks, is a tool for running many sequential jobs of short or variable duration, or for doing parameter sweeps. It works like `GNU parallel` or job arrays but with a simpler syntax.

GLOST uses a wrapper called `glost_launch` and MPI commands (`srun`, `mpiexec`, and `mpirun`). Jobs are grouped into one text file, `list_glost_tasks.txt`, which is used as an argument for `glost_launch`.

GLOST can be used in the following situations:

* Large number of serial jobs with comparative runtime
* Large number of short serial jobs
* Serial jobs with different parameters (parameter sweep)

The idea behind using GLOST consists of bundling serial jobs and running them as an MPI job. It can use multiple cores (one or more nodes). This will considerably reduce the number of jobs on the queue and, therefore, reduce the stress on the scheduler.

As an alternative, you may also want to consider the META software package developed by our staff, which has some important advantages over GLOST. In particular, with META the queue wait time may be significantly shorter than with GLOST, and META overheads are smaller (fewer wasted CPU cycles). In addition, META has a convenient mechanism for re-submitting all the computations that never ran or failed. Finally, unlike GLOST, META can be used for all kinds of jobs; serial, multi-threaded, MPI, GPU, or hybrid.

**Note:** Please read this document until the end and if you think that your workflow can fit within this framework, contact Technical support to help you change your workflow.


## 2 Advantage of using GLOST

GLOST is used to bundle a set of serial jobs into one single or more MPI jobs depending on the duration of the jobs and their number.

Submitting a large number of serial jobs at once can slow down the scheduler, leading in most cases to a slow response and frequent timeouts from `sbatch` or `squeue` requests. The idea is to put all the serial tasks into a single file, for example `list_glost_tasks.txt`, and submit an MPI job using the `glost_launch` wrapper. This will considerably reduce the number of jobs on the queue, leading to fewer requests to the scheduler compared to the situation if the jobs are submitted separately. Using GLOST to submit serial jobs reduces the stress experienced by the Slurm scheduler when a large number of jobs are submitted at the same time without any delay.

Using GLOST, the user will submit and handle a few MPI jobs rather than hundreds or thousands of serial jobs.


## 3 Modules

GLOST uses OpenMPI to run a set of serial tasks as an MPI job. For each OpenMPI version, a corresponding module of Glost is installed. To use it, make sure to load OpenMPI and Glost modules. For more information, please refer to the page [using modules](link_to_using_modules_page). To see the current installed modules on our systems, use `module spider glost`. Before submitting a job, make sure that you can load GLOST along with the other modules that are required to run your application.

```bash
$ module spider glost/0.3.1

--------------------------------------------------------------------------------------------------------------------------------------
glost:
glost/0.3.1
--------------------------------------------------------------------------------------------------------------------------------------
Description:
This is GLOST, the Greedy Launcher Of Small Tasks.
Properties:
Tools for development / Outils de développement
You will need to load all module(s) on any one of the lines below before the "glost/0.3.1" module is available to load.
StdEnv/2023 gcc/12.3 openmpi/4.1.5
StdEnv/2023 intel/2023.2.1 openmpi/4.1.5
Help:
Description
===========
This is GLOST, the Greedy Launcher Of Small Tasks.
More information
================
- Homepage: https://github.com/cea-hpc/glost
```

If there is already an OpenMPI module in your environment, like the default environment, adding `module load glost` to your list of modules needed for your application is sufficient to activate GLOST. Use `module list` to make sure that the GLOST module is loaded along with other modules before submitting your job.


## 4 How to use GLOST?

### 4.1 GLOST syntax

The general syntax of GLOST can take one of the following forms:

```bash
srun glost_launch list_glost_tasks.txt

mpiexec glost_launch list_glost_tasks.txt
mpirun glost_launch list_glost_tasks.txt
```

### 4.2 Number of cores versus number of jobs

GLOST uses a cyclic distribution to distribute the serial jobs among the available cores for the job. The GLOST wrapper picks the first lines from the list of jobs and assigns one processor to each job (or line from the list) and when one or more processors are done with the first tasks, GLOST will assign them the following lines on the list until the end of the list or until the job runs out of time. Therefore, the number of cores may not necessarily match the number of requested jobs in the list. However, in order to optimize the use of resources, one may need to make sure that the serial jobs have similar runtime and they can be distributed evenly among the cores asked for. Different situations can be treated:

* If you have a large number of very short serial jobs to run (hundreds or thousands of jobs with a very short time, few minutes for example), you submit one or more GLOST jobs that will run a set of serial jobs using few cores. The jobs can be scheduled for short time and by node to take advantage of the back-filling and the scheduler.
* If you have tens to hundreds of relatively short runtime jobs (an hour or so), you can bundle them into one or more GLOST jobs.
* If you have many long serial jobs with similar runtimes, they can also be used as a GLOST job.


### 4.3 Estimation of the wall time for GLOST job

Before running a GLOST job, try to estimate the runtime for your serial jobs. It can be used to estimate the wall time for your GLOST job.

Let us suppose you want to run a GLOST job where you have a list of  `Njobs` of similar jobs where each job takes `t0` as a runtime using 1 processor. The total runtime for all these jobs will be:

`t0*Njobs`

Now, if you are going to use `Ncores` to run your GLOST job, the time required for this job will be:

`wt = t0*Njobs/Ncores`

**Note:** An MPI job is often designed so that MPI processes need to exchange information. Designs like this can spend a large fraction of time on communication and so wind up doing less computation. Many, small, dependent communications can reduce the efficiency of the code. In contrast, GLOST uses MPI but only to start entirely serial jobs, which means that communication overhead is relatively infrequent. You could write the same program yourself, using MPI directly, but GLOST provides nearly the same efficiency, without the effort of writing MPI.


### 4.4 Choosing the memory

GLOST uses MPI to run serial jobs and the memory per core should be the same as the memory required for the serial job if it runs separately. Use `--mem-per-cpu` instead of `--mem` in your Slurm script.


### 4.5 Create the list of tasks

Before submitting a job using GLOST, create a text file, `list_glost_tasks.txt`, that contains all the commands needed to run the serial jobs: one job per line. Ideally, one has to choose jobs with similar runtime in order to optimize the use of resources asked for. The GLOST job can run all the tasks in one or multiple directories. If you run all the jobs in one directory, make sure that the output from the different jobs do not overlap or use the same temporary or output files. To do so, standard output may be redirected to a file with a variable indicating the argument or the option used to run the corresponding jobs. In case the jobs use similar temporary or output files, you may need to create a directory for each task: one directory for each argument or option that corresponds to a particular job.

**Note:** One job may contain one command or multiple commands executed one after another. The commands should be separated by `&&`.


Here is an example of the file `list_glost_example.txt` with 8 jobs:

**File: `run_glost_test.sh`**

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --time=00-02:00
#SBATCH --mem-per-cpu=4000M
# Load GLOST module:
module load intel/2023.2.1 openmpi/4.1.5 glost/0.3.1
echo "Starting run at: `date`"
# Run GLOST with the argument: list_glost_example.txt
srun glost_launch list_glost_example.txt
echo "Program glost_launch finished with exit code $? at: `date`"
```

**File: `list_glost_example.txt`**

```
job01 and/or other commands related to job01
job02 and/or other commands related to job02
job03 and/or other commands related to job03
job04 and/or other commands related to job04
job05 and/or other commands related to job05
job06 and/or other commands related to job06
job07 and/or other commands related to job07
job08 and/or other commands related to job08
```

**Note:** The above example cannot be executed. The commands are not defined. It shows only:

* A simple syntax for a list of jobs, `list_glost_tasks.txt`, that will serve as an argument for the `glost_launch` wrapper;
* A typical script to submit the job.

Both the list of jobs and the script should be adapted to your workflow.


### 4.6 List of jobs to run in one directory

GLOST can be used to run a set or a list of serial jobs in one directory. To avoid the overlap of the results, one has to make sure that the different jobs will not use the same temporary or output file. This can be achieved by adding arguments to differentiate the different jobs. In the following example, we have a list of 10 tasks. Each task may contain one or more commands. In this example, each job runs three commands one after another:

1.  **First command:** Fix a variable `nargument`. This could be a parameter or a variable to pass to the program, for example.
2.  **Second command:** Run the program. For testing, we have used the command `sleep 360`. This should be replaced by the command line to run your application. For example: `./my_first_prog < first_input_file.txt > first_output_file.txt`
3.  **Third command:** If needed, add one or more commands that will be executed just after the previous ones. All the commands should be separated by `&&`. For testing, we have used the command: `echo ${nargument}.`hostname` > log_${nargument}.txt`. For this command, we print out the argument and the `hostname` to a file `log_${nargument}.txt`. Similarly to the second command, this line should be replaced by another command line to run an application just after the previous one if needed. For example: `./my_second_prog < second_input_file.txt > second_output_file.txt`.


**File: `run_glost_test.sh`**

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --time=00-02:00
#SBATCH --mem-per-cpu=4000M
# Load GLOST module along with the modules required to run your application:
module load intel/2023.2.1 openmpi/4.1.5 glost/0.3.1
echo "Starting run at: `date`"
# Run GLOST with the argument: list_glost_tasks.txt
srun glost_launch list_glost_tasks.txt
echo "Program glost_launch finished with exit code $? at: `date`"
```

**File: `list_glost_tasks.txt`**

```
nargument=20 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=21 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=22 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=23 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=24 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=25 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=26 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=27 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=28 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
nargument=29 && sleep 360 && echo ${nargument}.`hostname` > log_${nargument}.txt
```

**Note:** In the above example, we have used 2 cores and a list of 10 jobs. GLOST will assign the first two jobs (two first lines) to the available processors, and whenever one and/or both of them are done with the first set of jobs, they will continue with the following jobs until the end of the list.


### 4.7 List of jobs to run in separate directories

Similarly to the previous case, GLOST can be used to run multiple serial jobs where each one is executed in a dedicated directory. This could be useful to run a program that uses files (temporary, input and/or output) with the same names in order to avoid the crash of the jobs or an overlap of the results from the different jobs. To do so, one has to make sure to create the input files and a directory for each job before running GLOST. It can be also achieved if included within the line commands as shown in the following example:


**File: `run_glost_test.sh`**

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --time=00-03:00
#SBATCH --mem-per-cpu=4000M
# Load GLOST module along with the modules required to run your application:
module load intel/2023.2.1 openmpi/4.1.5 glost/0.3.1
echo "Starting run at: `date`"
# Run GLOST with the argument: list_glost_tasks.txt
srun glost_launch list_glost_tasks.txt
echo "Program glost_launch finished with exit code $? at: `date`"
```

**File: `list_glost_tasks.txt`**

```
nargument=20 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=21 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=22 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=23 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=24 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=25 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=26 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=27 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=28 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=29 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=30 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
nargument=31 && mkdir -p RUN_${nargument} && cd RUN_${nargument} && sleep 360 && echo ${nargument}.`hostname` > log_run.txt
```


### 4.8 Restarting a GLOST job

If you underestimated the wall time for your GLOST job, it may require restarting to complete the list of jobs that were inserted in the list of glost tasks. In this case, make sure to identify the jobs that are already done in order to not run them again. Once identified, remove the corresponding lines from the list of tasks or create a new list of jobs that contain the remaining jobs from the previous GLOST job and resubmit your script using the new list as an argument for the `glost_launch` wrapper.


### 4.9 More examples

If you are an advanced user and familiar with scripting, you may have a look at the examples by making a copy of the original scripts and adapting them to your workflow.

After loading the GLOST module, the examples can be copied to your local directory by running the command:

```bash
cp -r $EBROOTGLOST/examples Glost_Examples
```

The copy of the examples will be saved under the directory: `Glost_Examples`


## 5 Related links

* [META-Farm](link_to_metafarm)
* [GNU Parallel](link_to_gnu_parallel)
* [Job arrays](link_to_job_arrays)
* [MPI jobs](link_to_mpi_jobs)
* [Running jobs](link_to_running_jobs)


**(Remember to replace the bracketed placeholders with actual links.)**
