# Quantum Transpiler

Classical transpilation describes the translation of code written in one programming language to code written in another language. It is a process similar to compilation.

In quantum computing, transpilation aims to ensure that a quantum circuit uses only the native gates of the quantum machine on which it will be executed. Transpilation also ensures that operations involving multiple qubits are assigned to qubits that are physically connected on the quantum chip.

## Transpilation Steps

### Measurement Decomposition

Measurements are made in a given basis, such as X, Y, or Z bases, among others. Most quantum computers measure in the Z base (computing base). If another base is required, rotations must be added at the end of the circuit to adjust the measurement base.

### Intermediate Decomposition

A first decomposition of the operations is necessary to run the circuit on a quantum machine to limit the number of different operations used by the circuit. For example, operations with more than two qubits must be decomposed into operations with two or one qubits.

### Placement

The idea is to establish an association between the wires of the user-created quantum circuit and the physical qubits of the machine. This step can be reduced to a subgraph isomorphism problem.

### Routing

Despite the placement step, some two-qubit operations may not be properly assigned to physical couplers available on the machine. In this case, `swap` operations are used to virtually bring the qubits together and allow them to connect. However, these swap operations are very expensive, making optimal initial placement essential to minimize their use.

Routing to join 2 distant qubits. A CNOT gate between qubits 0 and 2 is converted into 2 SWAP gates and 1 CNOT gate on neighboring qubits.

### Optimization

Qubits accumulate errors and lose their coherence over time. To limit this, the optimization process reduces the number of operations applied to each qubit using different classical algorithms. For example, it removes trivial and inverse operations; combines rotations on the same axis; and more generally replaces sections of circuits with equivalent circuits that generate fewer errors.

### Native Gate Decomposition

Every quantum computer has a finite set of basic operations (native gates) from which all other operations can be composed. For example, MonarQ has a set of 13 native gates. Transpilation thus decomposes all non-native circuit operations into native operations.

## Using the Calcul Québec Transpiler with MonarQ

Calcul Québec has developed a transpiler that allows you to send circuits to MonarQ transparently, using the transpilation steps described above. This transpiler is integrated into a PennyLane device and is therefore designed to be specifically used with PennyLane. For details, see [this documentation page](link_to_documentation_page).
