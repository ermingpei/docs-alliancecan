# Python

## Description

Python is an interpreted programming language with a design philosophy stressing the readability of code. Its syntax is simple and expressive. Python has an extensive, easy-to-use standard library.

The capabilities of Python can be extended with packages developed by third parties. In general, to simplify operations, it is left up to individual users and groups to install these third-party packages in their own directories. However, most systems offer several versions of Python as well as tools to help you install the third-party packages that you need.

The following sections discuss the Python interpreter, and how to install and use packages.

## Loading an interpreter

### Default Python version

When you log into our clusters, a default Python version will be available, but that is generally not the one that you should use, especially if you need to install any Python packages. You should try to find out which version of Python is required to run your Python programs and load the appropriate module. If you are not sure which version you need, then it is reasonable to use the latest version available.

### Loading a Python module

To discover the versions of Python available:

```bash
[name@server ~]$ module avail python
```

You can then load the version of your choice using `module load`. For example, to load Python 3.10 you can use the command:

```bash
[name@server ~]$ module load python/3.10
```

### Python version supported

In general in the Python ecosystem, the transition to more modern versions of python is accelerating, with many packages only supporting the latest few versions of Python 3.x. In our case, we provide prebuilt Python packages in our wheelhouse only for the 3 most recent Python versions available on the systems. This will result in dependencies issues when trying to install those packages with older versions of Python. See Troubleshooting.

Below is a table indicating when we stopped building wheels for each version of Python.

| Python version | Date       |
| --------------- | ---------- |
| 3.10            | 2022-02    |
| 3.9             | 2021-02    |
| 3.8             | 2020-02    |
| 3.7             | 2020-01    |
| 3.6             | 2020-01    |
| 3.5             | 2020-01    |
| 2.7             | 2020-01    |


### SciPy stack

In addition to the base Python module, the SciPy package is also available as an environment module. The `scipy-stack` module includes:

* NumPy
* SciPy
* Matplotlib
* dateutil
* pytz
* IPython
* pyzmq
* tornado
* pandas
* Sympy
* nose

If you want to use any of these Python packages, load a Python version of your choice and then:

```bash
module load scipy-stack
```

To get a complete list of the packages contained in `scipy-stack`, along with their version numbers, run:

```bash
module spider scipy-stack/2020a
```

(replacing `2020a` with whichever version you want to find out about).

## Creating and using a virtual environment

With each version of Python, we provide the tool `virtualenv`. This tool allows users to create virtual environments within which you can easily install Python packages. These environments allow one to install many versions of the same package, for example, or to compartmentalize a Python installation according to the needs of a specific project. Usually you should create your Python virtual environment(s) in your `/home` directory or in one of your `/project` directories. (See "Creating virtual environments inside of your jobs" below for a third alternative.)

**Virtual environment location:** Do not create your virtual environment under `$SCRATCH` as it may get partially deleted. Instead, create it inside your job.

To create a virtual environment, make sure you have selected a Python version with `module load python/X.Y.Z` as shown above in section Loading a Python module. If you expect to use any of the packages listed in section SciPy stack above, also run `module load scipy-stack/X.Y.Z`. Then enter the following command, where `ENV` is the name of the directory for your new environment:

```bash
[name@server ~]$ virtualenv --no-download ENV
```

Once the virtual environment has been created, it must be activated:

```bash
[name@server ~]$ source ENV/bin/activate
```

You should also upgrade `pip` in the environment:

```bash
[name@server ~]$ pip install --no-index --upgrade pip
```

To exit the virtual environment, simply enter the command `deactivate`:

```bash
(ENV) [name@server ~] deactivate
```

You can now use the same virtual environment over and over again. Each time:

1. Load the same environment modules that you loaded when you created the virtual environment, e.g., `module load python scipy-stack`.
2. Activate the environment, `source ENV/bin/activate`.

### Installing packages

Once you have a virtual environment loaded, you will be able to run the `pip` command. This command takes care of compiling and installing most of Python packages and their dependencies. A comprehensive index of Python packages can be found at [PyPI](https://pypi.org/).

All of `pip`'s commands are explained in detail in the [user guide](https://pip.pypa.io/en/stable/user_guide/). We will cover only the most important commands and use the Numpy package as an example.

We first load the Python interpreter:

```bash
[name@server ~]$ module load python/3.10
```

We then activate the virtual environment, previously created using the `virtualenv` command:

```bash
[name@server ~]$ source ENV/bin/activate
```

Finally, we install the latest stable version of Numpy:

```bash
(ENV) [name@server ~] pip install numpy --no-index
```

The `pip` command can install packages from a variety of sources, including PyPI and prebuilt distribution packages called Python wheels. We provide Python wheels for a number of packages. In the above example, the `--no-index` option tells `pip` to *not* install from PyPI, but instead to install only from locally available packages, i.e., our wheels.

Whenever we provide a wheel for a given package, we strongly recommend to use it by way of the `--no-index` option. Compared to using packages from PyPI, wheels that have been compiled by our staff can prevent issues with missing or conflicting dependencies, and were optimized for our clusters hardware and libraries. See Available wheels.

If you omit the `--no-index` option, `pip` will search both PyPI and local packages, and use the latest version available. If PyPI has a newer version, it will be installed instead of our wheel, possibly causing issues. If you are certain that you prefer to download a package from PyPI rather than use a wheel, you can use the `--no-binary` option, which tells `pip` to ignore prebuilt packages entirely. Note that this will also ignore wheels that are distributed through PyPI, and will always compile the package from source.

To see where the `pip` command is installing a python package from, diagnosing installation issues, you can tell it to be more verbose with the `-vvv` option. It is also worth mentioning that when installing multiple packages it is advisable to install them with one command as it helps pip resolve dependencies.

### Creating virtual environments inside of your jobs

Parallel filesystems such as the ones used on our clusters are very good at reading or writing large chunks of data, but can be bad for intensive use of small files. Launching a software and loading libraries, such as starting Python and loading a virtual environment, can be slow for this reason.

As a workaround for this kind of slowdown, and especially for single-node Python jobs, you can create your virtual environment inside of your job, using the compute node's local disk. It may seem counter-intuitive to recreate your environment for every job, but it can be faster than running from the parallel filesystem, and will give you some protection against some filesystem performance issues. This approach, of creating a node-local virtualenv, has to be done for each node in the job, since the virtualenv is only accessible on one node. Following job submission script demonstrates how to do this for a single-node job:

**File: submit_venv.sh**

```bash
#!/bin/bash
#SBATCH --account=def-someuser
#SBATCH --mem-per-cpu=1.5G      # increase as needed
#SBATCH --time=1:00:00
module load python/3.10
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip

pip install --no-index -r requirements.txt
python ...
```

where the `requirements.txt` file will have been created from a test environment. For example, if you want to create an environment for TensorFlow, you would do the following on a login node:

```bash
[name@server ~]$ module load python/3.10
[name@server ~]$ ENVDIR=/tmp/$RANDOM
[name@server ~]$ virtualenv --no-download $ENVDIR
[name@server ~]$ source $ENVDIR/bin/activate
[name@server ~]$ pip install --no-index --upgrade pip
[name@server ~]$ pip install --no-index tensorflow
[name@server ~]$ pip freeze --local > requirements.txt
[name@server ~]$ deactivate
[name@server ~]$ rm -rf $ENVDIR
```

This will yield a file called `requirements.txt`, with content such as the following:

**File: requirements.txt**

```
absl_py==1.2.0+computecanada
astunparse==1.6.3+computecanada
cachetools==5.2.0+computecanada
certifi==2022.6.15+computecanada
charset_normalizer==2.1.0+computecanada
flatbuffers==1.12+computecanada
gast==0.4.0+computecanada
google-pasta==0.2.0+computecanada
google_auth==2.9.1+computecanada
google_auth_oauthlib==0.4.6+computecanada
grpcio==1.47.0+computecanada
h5py==3.6.0+computecanada
idna==3.3+computecanada
keras==2.9.0+computecanada
Keras-Preprocessing==1.1.2+computecanada
libclang==14.0.1+computecanada
Markdown==3.4.1+computecanada
numpy==1.23.0+computecanada
oauthlib==3.2.0+computecanada
opt-einsum==3.3.0+computecanada
packaging==21.3+computecanada
protobuf==3.19.4+computecanada
pyasn1==0.4.8+computecanada
pyasn1-modules==0.2.8+computecanada
pyparsing==3.0.9+computecanada
requests==2.28.1+computecanada
requests_oauthlib==1.3.1+computecanada
rsa==4.8+computecanada
six==1.16.0+computecanada
tensorboard==2.9.1+computecanada
tensorboard-data-server==0.6.1+computecanada
tensorboard_plugin_wit==1.8.1+computecanada
tensorflow==2.9.0+computecanada
tensorflow_estimator==2.9.0+computecanada
tensorflow_io_gcs_filesystem==0.23.1+computecanada
termcolor==1.1.0+computecanada
typing_extensions==4.3.0+computecanada
urllib3==1.26.11+computecanada
Werkzeug==2.1.2+computecanada
wrapt==1.13.3+computecanada
```

This file will ensure that your environment is reproducible between jobs.

Note that the above instructions require all of the packages you need to be available in the python wheels that we provide (see "Available wheels" below). If the wheel is not available in our wheelhouse, you can pre-download it (see "Pre-downloading packages" section below). If you think that the missing wheel should be included in our wheelhouse, please contact Technical support to make a request.

#### Creating virtual environments inside of your jobs (multi-nodes)

In order to run scripts across multiple nodes, each node must have its own virtual environment activated.

1. In your submission script, create the virtual environment on each allocated node:

```bash
srun --ntasks $SLURM_NNODES --tasks-per-node=1 bash << EOF
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install --no-index -r requirements.txt
EOF
```

2. Activate the virtual environment on the main node, `source $SLURM_TMPDIR/env/bin/activate;`

3. Use `srun` to run your script `srun python myscript.py;`

#### Example (multi-nodes)

**File: submit-nnodes-venv.sh**

```bash
#!/bin/bash
#SBATCH --account=<your account>
#SBATCH --time=00:30:00
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --mem-per-cpu=2000M
module load StdEnv/2023 python/3.11 mpi4py
# create the virtual environment on each node :
srun --ntasks $SLURM_NNODES --tasks-per-node=1 bash << EOF
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install --no-index -r requirements.txt
EOF
# activate only on main node
source $SLURM_TMPDIR/env/bin/activate;
# srun exports the current env, which contains $VIRTUAL_ENV and $PATH variables
srun python myscript-mpi.py;
```

### Available wheels

Currently available wheels are listed on the [Available Python wheels](link_to_available_wheels_page) page. You can also run the command `avail_wheels` on the cluster.

By default, it will:

* only show you the latest version of a specific package (unless versions are given);
* only show you versions that are compatible with the python module (if one loaded) or virtual environment (if activated), otherwise all versions will be shown;
* only show you versions that are compatible with the CPU architecture and software environment (StdEnv) that you are currently running on.

#### Names

To list wheels containing `cdf` (case insensitive) in its name:

```bash
[name@server ~]$ avail_wheels "*cdf*"
```

```
name      version python arch
-------- --------- -------- -------
h5netcdf  0.7.4    py2,py3  generic
netCDF4   1.5.8    cp39    avx2
netCDF4   1.5.8    cp38    avx2
netCDF4   1.5.8    cp310   avx2
```

Or an exact name:

```bash
[name@server ~]$ avail_wheels numpy
```

```
name   version python arch
------ --------- -------- -------
numpy  1.23.0    cp39    generic
numpy  1.23.0    cp38    generic
numpy  1.23.0    cp310   generic
```

#### Version

To list a specific version, you can use the same format as with `pip`:

```bash
[name@server ~]$ avail_wheels numpy==1.23
```

```
name   version python arch
------ --------- -------- -------
numpy  1.23.0    cp39    generic
numpy  1.23.0    cp38    generic
numpy  1.23.0    cp310   generic
```

Or use the long option:

```bash
[name@server ~]$ avail_wheels numpy --version 1.23
```

```
name   version python arch
------ --------- -------- -------
numpy  1.23.0    cp39    generic
numpy  1.23.0    cp38    generic
numpy  1.23.0    cp310   generic
```

With the `pip` format, you can use different operators: `==`, `<`, `>`, `~=`, `<=`, `>=`, `!=`. For instance, to list inferior versions:

```bash
[name@server ~]$ avail_wheels 'numpy<1.23'
```

```
name   version python arch
------ --------- -------- -------
numpy  1.22.2    cp39    generic
numpy  1.22.2    cp38    generic
numpy  1.22.2    cp310   generic
```

And to list all available versions:

```bash
[name@server ~]$ avail_wheels "*cdf*" --all-version
```

```
name      version python arch
-------- --------- -------- -------
h5netcdf  0.7.4    py2,py3  generic
netCDF4   1.5.8    cp39    avx2
netCDF4   1.5.8    cp38    avx2
netCDF4   1.5.8    cp310   avx2
netCDF4   1.5.6    cp38    avx2
netCDF4   1.5.6    cp37    avx2
netCDF4   1.5.4    cp38    avx2
netCDF4   1.5.4    cp37    avx2
netCDF4   1.5.4    cp36    avx2
```

#### Python

You can list a specific version of Python:

```bash
[name@server ~]$ avail_wheels 'numpy<1.23' --python 3.9
```

```
name   version python arch
------ --------- -------- -------
numpy  1.22.2    cp39    generic
```

The `python` column tells us for which version the wheel is available, where `cp39` stands for `cpython 3.9`.

#### Requirements file

One can list available wheels based on a `requirements.txt` file with:

```bash
[name@server ~]$ avail_wheels -r requirements.txt
```

```
name       version python arch
--------- --------- -------- -------
packaging  21.3     py3     generic
tabulate   0.8.10   py3     generic
```

And display wheels that are not available:

```bash
[name@server ~]$ avail_wheels -r requirements.txt --not-available
```

```
name       version python arch
--------- --------- -------- -------
packaging  21.3     py3     generic
pip        tabulate 0.8.10   py3     generic
```

### Pre-downloading packages

Here is how to pre-download a package called `tensorboardX` on a login node, and install it on a compute node:

Run `pip download --no-deps tensorboardX`. This will download the package as `tensorboardX-1.9-py2.py3-none-any.whl` (or similar) in the working directory. The syntax of `pip download` is the same as `pip install`.

If the filename does not end with `none-any`, and ends with something like `linux_x86_64` or `manylinux*_x86_64`, the wheel might not function correctly. You should contact Technical support so that we compile the wheel and make it available on our systems.

Then, when installing, use the path for file `pip install tensorboardX-1.9-py2.py3-none-any.whl`.

## Parallel programming with the Python `multiprocessing` module

Doing parallel programming with Python can be an easy way to get results faster. An usual way of doing so is to use the `multiprocessing` module. Of particular interest is the `Pool` class of this module, since it allows one to control the number of processes started in parallel, and apply the same calculation to multiple data. As an example, suppose we want to calculate the cube of a list of numbers. The serial code would look like this:

### Using a loop

**File: cubes_sequential.py**

```python
def cube(x):
    return x**3
data = [1, 2, 3, 4, 5, 6]
cubes = [cube(x) for x in data]
print(cubes)
```

### Using a map

**File: cubes_sequential.py**

```python
def cube(x):
    return x**3
data = [1, 2, 3, 4, 5, 6]
cubes = list(map(cube,data))
print(cubes)
```

Using the `Pool` class, running in parallel, the above codes become:

### Using a loop

**File: cubes_parallel.py**

```python
import multiprocessing as mp

def cube(x):
    return x**3
pool = mp.Pool(processes=4)
data = [1, 2, 3, 4, 5, 6]
results = [pool.apply_async(cube, args=(x,)) for x in data]
cubes = [p.get() for p in results]
print(cubes)
```

### Using a map

**File: cubes_parallel.py**

```python
import multiprocessing as mp

def cube(x):
    return x**3
pool = mp.Pool(processes=4)
data = [1, 2, 3, 4, 5, 6]
cubes = pool.map(cube, data)
print(cubes)
```

The above examples will however be limited to using 4 processes. On a cluster, it is very important to use the cores that are allocated to your job. Launching more processes than you have cores requested will slow down your calculation and possibly overload the compute node. Launching fewer processes than you have cores will result in wasted resources and cores remaining idle. The correct number of cores to use in your code is determined by the amount of resources you requested to the scheduler. For example, if you have the same computation to perform on many tens of data or more, it would make sense to use all of the cores of a node. In this case, you can write your job submission script with the following header:

**File: submit.sh**

```bash
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
python cubes_parallel.py
```

and then, your code would become the following:

### Using a loop

**File: cubes_parallel.py**

```python
import multiprocessing as mp
import os

def cube(x):
    return x**3
ncpus = int(os.environ.get('SLURM_CPUS_PER_TASK',default=1))
pool = mp.Pool(processes=ncpus)
data = [1, 2, 3, 4, 5, 6]
results = [pool.apply_async(cube, args=(x,)) for x in data]
cubes = [p.get() for p in results]
print(cubes)
```

### Using a map

**File: cubes_parallel.py**

```python
import multiprocessing as mp
import os

def cube(x):
    return x**3
ncpus = int(os.environ.get('SLURM_CPUS_PER_TASK',default=1))
pool = mp.Pool(processes=ncpus)
data = [1, 2, 3, 4, 5, 6]
cubes = pool.map(cube, data)
print(cubes)
```

Note that in the above example, the function `cube` itself is sequential. If you are calling some external library, such as numpy, it is possible that the functions called by your code are themselves parallel. If you want to distribute processes with the technique above, you should verify whether the functions you call are themselves parallel, and if they are, you need to control how many threads they will take themselves. If, for example, they take all the cores available (32 in the above example), and you are yourself starting 32 processes, this will slow down your code and possibly overload the node as well.

Note that the `multiprocessing` module is restricted to using a single compute node, so the speedup achievable by your program is usually limited to the total number of CPU cores in that node. If you want to go beyond this limit and use multiple nodes, consider using mpi4py or PySpark. Other methods of parallelizing Python (not all of them necessarily supported on our clusters) are listed [here](link_to_parallelization_methods). Also note that you can greatly improve the performance of your Python program by ensuring it is written efficiently, so that should be done first before parallelizing. If you are not sure if your Python code is efficient, please contact technical support and have them look at your code.

## Anaconda

Please see [Anaconda](link_to_anaconda_doc).

## Jupyter

Please see [Jupyter](link_to_jupyter_doc).

## Troubleshooting

### Python script is hanging

By using the `faulthandler` module, you can edit your script to allow dumping a traceback after a timeout. See `faulthandler.dump_traceback_later()`.

You can also inspect a python process while the job is running, without modifying it beforehand, using `py-spy`:

1. Install `py-spy` in a virtualenv in your home.
2. Attach to the running job, using `srun --pty --jobid JOBID bash`.
3. Use `htop -u $USER` to find the process ID of your python script.
4. Activate the virtualenv where `py-spy` is installed.
5. Run `py-spy top --pid PID` to see live feedback about where your code is spending time.
6. Run `py-spy dump --pid PID` to get a traceback of where your code is currently at.

### Package 'X' requires a different Python: X.Y.Z not in '>=X.Y'

When installing packages, you may encounter an error similar to:

```
ERROR: Package 'X' requires a different Python: 3.6.10 not in '>=3.7'
```

The current python module loaded (3.6.10 in this case) is not supported by that package. You can update to a more recent version, such as the latest available module. Or install an older version of package 'X'.

### Package has requirement X, but you'll have Y which is incompatible

When installing packages, you may encounter an error similar to:

```
ERROR: Package has requirement X, but you'll have Y which is incompatible.
```

Upgrade `pip` to the latest version or higher than [21.3] to use the new dependency resolver:

```bash
(ENV) [name@server ~] pip install --no-index --upgrade pip
```

Then rerun your install command.

### No matching distribution found for X

When installing packages, you may encounter an error similar to:

```bash
(ENV) [name@server ~] pip install X
ERROR: Could not find a version that satisfies the requirement X (from versions: none)
ERROR: No matching distribution found for X
```

`pip` did not find a package to install that satisfies the requirements (name, version or tags). Verify that the name and version are correct. Note also that `manylinux_x_y` wheels are discarded.

You can also verify that the package is available from the wheelhouse with the `avail_wheels` command or by searching on [Available Python wheels](link_to_available_wheels_page) page.

### Installing many packages

When installing multiple packages, it is best to install them in one command when possible:

```bash
(ENV) [name@server ~] pip install --upgrade pip
(ENV) [name@server ~] pip install package1 package2 package3 package4
```

as this helps `pip` resolve dependencies issues.

### My virtual environment was working yesterday but not anymore

Packages are often updated and this leads to a non-reproducible virtual environment. Another reason might be that the virtual environment was created in `$SCRATCH` and part of it was deleted with the automatic purge of the filesystem; this would make the virtual environment nonfunctional.

To remedy that, freeze the specific packages and their versions with:

```bash
(ENV) [name@server ~] pip install --upgrade pip
(ENV) [name@server ~] pip install --no-index 'package1==X.Y' 'package2==X.Y.Z' 'package3<X.Y' 'package4>X.Y'
```

and then create a requirements file that will be used to install the required packages in your job.

### X is not a supported wheel on this platform

When installing a package, you may encounter the following error:

```
ERROR: package-3.8.1-cp311-cp311-manylinux_2_28_x86_64.whl is not a supported wheel on this platform.
```

Some packages may be incompatible or not supported on the systems. Two common cases are: trying to install a `manylinux` package or a python package built for a different Python version (e.g., installing a package built for python 3.11 when you have python 3.9). Some `manylinux` package can be made available through the wheelhouse.

### AttributeError: module ‘numpy’ has no attribute ‘X’

When installing numpy without specifying a version number, the latest available version will be installed. In Numpy v1.20, many attributes were set for deprecation and are now expired in v1.24. This may result in an error, depending on the attribute accessed. For example, `AttributeError: module ‘numpy’ has no attribute ‘bool’`. This can be solved by installing a previous version of Numpy:

```bash
pip install --no-index 'numpy<1.24'
```

### ModuleNotFoundError: No module named 'X'

When trying to import a Python module, it may not be found. Some common causes are:

* the package is not installed or is not visible to the python interpreter;
* the name of the module to import is not the same as the name of the package that provides it;
* a broken virtual environment.

To avoid such problems, do not:

* modify the `PYTHONPATH` environment variable;
* modify the `PATH` environment variable;
* load a module while a virtual environment is activated (activate your virtual environment only after loading all the required modules)

When you encounter this problem, first make sure you followed the above advice. Then:

1. make sure that the package is installed; run `pip list`;
2. double-check the module name (upper or lower case and underscores matter);
3. make sure that the module is imported at the correct level (when importing from its source directory).

In doubt, start over with a new virtual environment.

### ImportError: numpy.core.multiarray failed to import

When trying to import a Python module that depends on Numpy, one may encounter `ImportError: numpy.core.multiarray failed to import`. This is caused by an incompatible version of Numpy installed or used and you must install a compatible version. This is especially true with the release of Numpy 2.0 which breaks the ABI. In the case of a wheel that was built with version 1.x but installed version 2.x, one must installed a lower version with:

```bash
pip install --no-index 'numpy<2.0'
```

**(Remember to replace the bracketed placeholders like `[link_to_available_wheels_page]` with the actual links.)**
