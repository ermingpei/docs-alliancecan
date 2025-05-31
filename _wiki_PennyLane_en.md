# PennyLane

PennyLane is an open-source software platform for differentiable quantum computing launched in 2018 by Xanadu, a quantum technology company based in Toronto, Canada.  It allows quantum circuits to be designed and run on a variety of quantum simulators and hardware. PennyLane is designed to facilitate the simulation, optimization, and training of hybrid quantum algorithms, which combine classical and quantum processing. The first version was published as an open-source project on GitHub.

## Contents

* [Features](#features)
* [Unified quantum interface](#unified-quantum-interface)
    * [Integration with machine learning libraries](#integration-with-machine-learning-libraries)
    * [Quantum circuit optimization](#quantum-circuit-optimization)
    * [Visualization tools](#visualization-tools)
    * [Community and development](#community-and-development)
* [Using PennyLane with MonarQ](#using-pennylane-with-monarq)
* [Creating a virtual environment](#creating-a-virtual-environment)
* [Running PennyLane on a cluster](#running-pennylane-on-a-cluster)
* [Use case: Bell states](#use-case-bell-states)
* [References](#references)


## Features

PennyLane offers several features to facilitate research and development in differentiable quantum computing.

## Unified quantum interface

PennyLane provides a unified quantum interface that allows you to design quantum circuits and run them on different quantum simulators and hardware. PennyLane supports several popular quantum simulators, such as Qiskit, CirQ, Strawberry Fields, and QuTip. PennyLane also supports several quantum hardware, including Xanadu, IBM, Rigetti, and IonQ quantum devices.

Calcul Québec has developed a [PennyLane-CalculQuebec plugin](link-to-plugin-documentation-needed) that uses the PennyLane interface to design and run quantum circuits on MonarQ.

### Integration with machine learning libraries

PennyLane seamlessly integrates with popular machine learning libraries such as TensorFlow and PyTorch, allowing you to use machine learning tools to build hybrid quantum machine learning models and optimize quantum circuits.

### Quantum circuit optimization

Using differentiable optimization techniques and combining classical and quantum differentiation methods, PennyLane optimizes quantum circuit parameters to solve a variety of problems.

### Visualization tools

PennyLane provides visualization tools to help understand how quantum circuits work.

### Community and development

PennyLane is an open-source project with an active community of developers and users. The project is constantly updated with new features and improvements, and anyone can contribute to the development of the platform.


## Using PennyLane with MonarQ

MonarQ is designed to be programmed with Snowflurry, a Julia-based software library developed by Anyon Systems. However, with the PennyLane-CalculQuebec plugin, PennyLane circuits can be created using Snowflurry in the background. This allows circuits to be run on MonarQ while still benefiting from the features and development environment offered by PennyLane. See the [PennyLane-CalculQuebec documentation](link-to-plugin-documentation-needed) for installation and usage guides.

A quantum transpiler is also available to optimize PennyLane circuits on MonarQ.


## Creating a virtual environment

Let’s create a virtual environment to use PennyLane.

```bash
name@server ~]$ module load python/3.11
name@server ~]$ virtualenv --no-download --clear ~/ENV && source ~/ENV/bin/activate
name@server ~]$ pip install --no-index --upgrade pip
name@server ~]$ python -c "import pennylane"
```

You can also put the last three commands in a `pennylane-reqs.txt` file and call the file inside a session with the commands:

```bash
name@server ~]$ module load python/3.11
name@server ~]$ pip install --no-index -r pennylane-reqs.txt
```

## Running PennyLane on a cluster

**File:** `script.sh`

```bash
#!/bin/bash
#SBATCH --account=def-someuser # use the name of your account
#SBATCH --time=00:15:00        # change if needed
#SBATCH --cpus-per-task=1      # change if needed
#SBATCH --mem-per-cpu=1G       # change if needed

# Load modules dependencies.
module load StdEnv/2023 gcc python/3.11

# Generate the virtual environment in $SLURM_TMPDIR.
virtualenv --no-download ${SLURM_TMPDIR}/env
source ${SLURM_TMPDIR}/env/bin/activate

# Install Pennylane and its dependencies.
pip install --no-index --upgrade pip
pip install --no-index --requirement ~/pennylane_requirements.txt

# Modify your PennyLane program.
python pennylane_example.py
```

You can now [submit the job to the scheduler](link-to-scheduler-documentation-needed).


## Use case: Bell states

Let's start by creating the virtual environment, as described above. We will then generate the first Bell state using PennyLane.

```python
import pennylane as qml

# Define the quantum circuit to generate the first Bell state.
def bell_circuit():
    qml.Hadamard(wires=0)
    qml.CNOT(wires=[0, 1])

# Define the quantum circuit simulator.
dev = qml.device('default.qubit', wires=2)

# Define the quantum circuit as a QNode function.
@qml.qnode(dev)
def generate_bell_state():
    bell_circuit()
    return qml.state()

# Generate and display the first Bell state.
bell_state_0 = generate_bell_state()
print("First Bell State :", bell_state_0)
# Premier état de Bell :[0.70710678+0.j 0.        +0.j 0.        +0.j 0.70710678+0.j]
```

## References

* [PennyLane official website](link-to-pennylane-website-needed)
* [PennyLane documentation on GitHub](link-to-pennylane-github-needed)
* [PennyLane-CalculQuebec](link-to-plugin-documentation-needed)


**(Note:  Please replace the bracketed `link-to-…-needed` placeholders with the actual links.)**
