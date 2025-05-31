# MPI

## A Primer on Parallel Programming

To pull a bigger wagon it is easier to add more oxen than to find (or build) a bigger ox.
—Gropp, Lusk & Skjellum, *Using MPI*

To build a house as quickly as possible, we do not look for the fastest person to do all the work but instead we hire as many people as required and spread the work among them so that various construction tasks are performed at the same time --- "in parallel". Computational problems are conceptually similar. Since there is a limit to how fast a single machine can perform, we attempt to divide up the computational problem at hand and assign work to be completed in parallel to multiple computers. This approach is important not only in speeding up computations but also in tackling problems requiring large amounts of memory.

The most significant concept to master in designing and building parallel applications is **communication**. Complexity arises due to communication requirements. In order for multiple workers to accomplish a task in parallel, they need to be able to communicate with one another. In the context of software, we have many processes each working on part of a solution, needing values that were computed ---or are yet to be computed!--- by other processes.

There are two major models of computational parallelism: shared memory, and distributed memory.

In shared memory parallelism (commonly and casually abbreviated SMP), all processors see the same memory image, or to put it another way, all memory is globally addressable and all the processes can ultimately access it. Communication between processes on an SMP machine is implicit --- any process can ultimately read and write values to memory that can be subsequently accessed and manipulated directly by others. The challenge in writing these kinds of programs is data consistency: one should take extra care to ensure data is not modified by more than one process at a time.

**Figure 1:** A conceptual picture of a shared memory architecture

Distributed memory parallelism is equivalent to a collection of workstations linked by a dedicated network for communication: a cluster. In this model, processes each have their own private memory, and may run on physically distinct machines. When processes need to communicate, they do so by sending **messages**. A process typically invokes a function to send data and the destination process invokes a function to receive it. A major challenge in distributed memory programming is how to minimize communication overhead. Networks, even the fastest dedicated hardware interconnects, transmit data orders of magnitude slower than within a single machine. Memory access times are typically measured in ones to hundreds of nanoseconds, while network latency is typically expressed in microseconds.

**Figure 2:** A conceptual picture of a cluster architecture

The remainder of this tutorial will consider distributed memory programming on a cluster using the Message Passing Interface.


## What is MPI?

The Message Passing Interface (MPI) is, strictly speaking, a **standard** describing a set of subroutines, functions, objects, etc., with which one can write parallel programs in a distributed memory environment. Many different **implementations** of the standard have been produced, such as Open MPI, Intel MPI, MPICH, and MVAPICH. The standard describes how MPI should be called from Fortran, C, and C++ languages, but unofficial "bindings" can be found for several other languages. Note that MPI 3.0 dropped official C++ bindings but instead you can use the C bindings from C++, or **Boost MPI**. For Python we give examples using the MPI for Python package **MPI4py**.

Since MPI is an open, non-proprietary standard, an MPI program can easily be ported to many different computers. Applications that use it can run on a large number of cores at once, often with good parallel efficiency (see the [scalability page](link-to-scalability-page) for more details). Given that memory is local to each process, some aspects of debugging are simplified --- it isn't possible for one process to interfere with the memory of another, and if a program generates a segmentation fault the resulting core file can be processed by standard serial debugging tools. However, due to the need to manage communication and synchronization explicitly, MPI programs may appear more complex than programs written with tools that support implicit communication. Furthermore, in designing an MPI program one should take care to minimize communication overhead to achieve a good speed-up from the parallel computation.

In the following we will highlight a few of these issues and discuss strategies to deal with them. Suggested references are presented at the end of this tutorial and the reader is encouraged to consult them for additional information.


## MPI Programming Basics

This tutorial will present the development of an MPI code in C, C++, Fortran, and Python, but the concepts apply to any language for which MPI bindings exist. For simplicity our goal will be to parallelize the venerable "Hello, World!" program, which appears below for reference.

**C:**

```c
#include <stdio.h>
int main() {
  printf("Hello, world!\n");
  return (0);
}
```

**C++:**

```cpp
#include <iostream>
using namespace std;
int main() {
  cout << "Hello, world!" << endl;
  return 0;
}
```

**Fortran:**

```fortran
program hello
  print *, 'Hello, world!'
end program hello
```

**Python:**

```python
print('Hello, world!')
```

Compiling and running the program looks something like this:

```bash
[~]$ vi hello.c
[~]$ cc -Wall hello.c -o hello
[~]$ ./hello
Hello, world!
```


### SPMD Programming

Parallel programs written using MPI make use of an execution model called Single Program, Multiple Data, or SPMD. The SPMD model involves running a number of **copies** of a single program. In MPI, each copy or "process" is assigned a unique number, referred to as the **rank** of the process, and each process can obtain its rank when it runs. When a process should behave differently, we usually use an "if" statement based on the rank of the process to execute the appropriate set of instructions.

**Figure 3:** SPMD model illustrating conditional branching to control divergent behaviour


### Framework

Each MPI program must include the relevant header file or use the relevant module (`mpi.h` for C/C++, `mpif.h`, `use mpi`, or `use mpi_f08` for Fortran, where `mpif.h` is strongly discouraged and `mpi_f08` recommended for new Fortran 2008 code), and be compiled and linked against the desired MPI implementation. Most MPI implementations provide a handy script, often called a **compiler wrapper**, that handles all set-up issues with respect to `include` and `lib` directories, linking flags, etc. Our examples will all use these compiler wrappers:

*   C language wrapper: `mpicc`
*   Fortran: `mpifort` (recommended) or `mpif90`
*   C++: `mpiCC` or `mpicxx`

The copies of an MPI program, once they start running, must coordinate with one another somehow. This cooperation starts when each one calls an initialization function before it uses any other MPI features. The prototype for this function appears below:

**C:**

```c
int MPI_Init(int *argc, char **argv[]);
```

**Boost (C++):**

```cpp
boost::mpi::environment(int &, char **&, bool = true);
```

**Fortran:**

```fortran
MPI_INIT(IERR)
INTEGER :: IERR
```

**Fortran 2008:**

```fortran
MPI_Init(ierr)
INTEGER, OPTIONAL, INTENT(OUT) :: ierr
```

**Python (mpi4py):**

```python
# importing automatically initializes MPI with mpi4py
MPI.Init()
```

The arguments to the C `MPI_Init` are pointers to the `argc` and `argv` variables that represent the command-line arguments to the program. Like all C MPI functions, the return value represents the error status of the function. Fortran MPI subroutines return the error status in an additional argument, `IERR`, which is optional if you `use mpi_f08`.

Similarly, we must call a function `MPI_Finalize` to do any clean-up that might be required before our program exits. The prototype for this function appears below:

**C:**

```c
int MPI_Finalize(void);
```

**Boost (C++):**

```cpp
//Nothing needed
```

**Fortran:**

```fortran
MPI_FINALIZE(IERR)
INTEGER :: IERR
```

**Fortran 2008:**

```fortran
MPI_Finalize(ierr)
INTEGER, OPTIONAL, INTENT(OUT) :: ierr
```

**Python (mpi4py):**

```python
# mpi4py installs a termination hook so there is no need to explicitly call MPI.Finalize.
MPI.Finalize()
```

As a rule of thumb, it is a good idea to call `MPI_Init` as the first statement of our program, and `MPI_Finalize` as its last statement.

Let's now modify our "Hello, world!" program accordingly.

**C:**

```c
#include <stdio.h>
#include <mpi.h>
int main(int argc, char *argv[]) {
  MPI_Init(&argc, &argv);
  printf("Hello, world!\n");
  MPI_Finalize();
  return (0);
}
```

**Boost (C++):**

```cpp
#include <iostream>
#include <boost/mpi.hpp>
using namespace std;
using namespace boost;
int main(int argc, char *argv[]) {
  mpi::environment env(argc, argv);
  cout << "Hello, world!" << endl;
  return 0;
}
```

**Fortran:**

```fortran
program phello0
  use mpi
  implicit none
  integer :: ierror
  call MPI_INIT(ierror)
  print *, 'Hello, world!'
  call MPI_FINALIZE(ierror)
end program phello0
```

**Fortran 2008:**

```fortran
program phello0
  use mpi_f08
  implicit none
  call MPI_Init()
  print *, 'Hello, world!'
  call MPI_Finalize()
end program phello0
```

**Python (mpi4py):**

```python
from mpi4py import MPI
print('Hello, world!')
```


### Rank and Size

We could now run this program under control of MPI, but each process would only output the original string which isn't very interesting. Let's instead have each process output its rank and how many processes are running in total. This information is obtained at run-time by the use of the following functions:

**C:**

```c
int MPI_Comm_size(MPI_Comm comm, int *nproc);
int MPI_Comm_rank(MPI_Comm comm, int *myrank);
```

**Boost (C++):**

```cpp
int mpi::communicator::size();
int mpi::communicator::rank();
```

**Fortran:**

```fortran
MPI_COMM_SIZE(COMM, NPROC, IERR)
INTEGER :: COMM, NPROC, IERR
MPI_COMM_RANK(COMM, RANK, IERR)
INTEGER :: COMM, RANK, IERR
```

**Fortran 2008:**

```fortran
MPI_Comm_size(comm, size, ierr)
TYPE(MPI_Comm), INTENT(IN) :: comm
INTEGER, INTENT(OUT) :: size
INTEGER, OPTIONAL, INTENT(OUT) :: ierr
MPI_Comm_rank(comm, rank, ierr)
TYPE(MPI_Comm), INTENT(IN) :: comm
INTEGER, INTENT(OUT) :: rank
INTEGER, OPTIONAL, INTENT(OUT) :: ierr
```

**Python (mpi4py):**

```python
MPI.Intracomm.Get_rank(self)
MPI.Intracomm.Get_size(self)
```

`MPI_Comm_size` reports the number of processes running as part of this job by assigning it to the result parameter `nproc`. Similarly, `MPI_Comm_rank` reports the rank of the calling process to the result parameter `myrank`. Ranks in MPI start from 0 rather than 1, so given N processes we expect the ranks to be 0..(N-1). The `comm` argument is a **communicator**, which is a set of processes capable of sending messages to one another. For the purpose of this tutorial we will always pass in the predefined value `MPI_COMM_WORLD`, which is simply all the MPI processes started with the job. It is possible to define and use your own communicators, but that is beyond the scope of this tutorial and the reader is referred to the provided references for additional detail.

Let us incorporate these functions into our program, and have each process output its rank and size information. Note that since all processes are still performing identical operations, there are no conditional blocks required in the code.

**C:**

```c
#include <stdio.h>
#include <mpi.h>
int main(int argc, char *argv[]) {
  int rank, size;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  printf("Hello, world! from process %d of %d\n", rank, size);
  MPI_Finalize();
  return (0);
}
```

**Boost (C++):**

```cpp
#include <iostream>
#include <boost/mpi.hpp>
using namespace std;
using namespace boost;
int main(int argc, char *argv[]) {
  mpi::environment env(argc, argv);
  mpi::communicator world;
  cout << "Hello, world! from process " << world.rank() << " of " << world.size() << endl;
  return 0;
}
```

**Fortran:**

```fortran
program phello1
  use mpi
  implicit none
  integer :: rank, size, ierror
  call MPI_INIT(ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierror)
  print *, 'Hello from process ', rank, ' of ', size
  call MPI_FINALIZE(ierror)
end program phello1
```

**Fortran 2008:**

```fortran
program phello1
  use mpi_f08
  implicit none
  integer :: rank, size
  call MPI_Init()
  call MPI_Comm_size(MPI_COMM_WORLD, size)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank)
  print *, 'Hello from process ', rank, ' of ', size
  call MPI_Finalize(ierror)
end program phello1
```

**Python (mpi4py):**

```python
from mpi4py import MPI
comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()
print('Hello from process %d of %d' % (rank, size))
```

Compile and run this program using 2, 4 and 8 processes. Note that each running process produces output based on the values of its local variables. The stdout of all running processes is simply concatenated together. As you run the program using more processes, you may see that the output from the different processes does not appear in order or rank: You should make no assumptions about the order of output from different processes.

```bash
[~]$ vi phello1.c
[~]$ mpicc -Wall phello1.c -o phello1
[~]$ mpirun -np 4 ./phello1
Hello, world! from process 0 of 4
Hello, world! from process 2 of 4
Hello, world! from process 1 of 4
Hello, world! from process 3 of 4
```

If you are using the Boost version, you should compile with:

```bash
[~]$ mpic++ --std=c++11 phello1.cpp -lboost_mpi-mt -lboost_serialization-mt -o phello1
```

If you are using the Python version, you don't need to compile but can run with:

```bash
[~]$ mpirun -np 4 python phello1.py
```


### Communication

While we now have a parallel version of our "Hello, World!" program, it isn't very interesting as there is no communication between the processes. Let's fix this by having the processes send messages to one another.

We'll have each process send the string "hello" to the one with the next higher rank number. Rank *i* will send its message to rank *i+1*, and we'll have the last process, rank *N-1*, send its message back to process 0 (a nice communication ring!). A short way to express this is process *i* sends to process *(i+1)%N*, where there are *N* processes and % is the modulus operator.

MPI provides a large number of functions for sending and receiving data of almost any composition in a variety of communication patterns (one-to-one, one-to-many, many-to-one, and many-to-many). But the simplest functions to understand are the ones that send a sequence of one or more instances of an atomic data type from one process to another, `MPI_Send` and `MPI_Recv`.

A process sends data by calling the `MPI_Send` function. Referring to the following function prototypes, `MPI_Send` can be summarized as sending `count` contiguous instances of `datatype` to the process with the specified `rank`, and the data is in the buffer pointed to by `message`.

`Tag` is a programmer-specified identifier that becomes associated with the message, and can be used, for example, to organize the communication streams (e.g. to distinguish two distinct streams of interleaved data). Our examples do not require this, so we will pass in the value 0 for the `tag`.

`Comm` is the communicator described above, and we will continue to use `MPI_COMM_WORLD`.

**C:**

```c
int MPI_Send(void *message, /* reference to data to be sent */
             int count,      /* number of items in message */
             MPI_Datatype datatype, /* type of item in message */
             int dest,       /* rank of process to receive message */
             int tag,        /* programmer specified identifier */
             MPI_Comm comm  /* communicator */
            );
```

**Boost (C++):**

```cpp
template <typename T>
void mpi::communicator::send(int dest, /* rank of process to receive message */
                             int tag,  /* programmer specified identified */
                             const T& value /* message */
                            ) const;
```

**Fortran:**

```fortran
MPI_SEND(MESSAGE, COUNT, DATATYPE, DEST, TAG, COMM, IERR)
<type> MESSAGE(*)
INTEGER :: COUNT, DATATYPE, DEST, TAG, COMM, IERR
```

**Fortran 2008:**

```fortran
MPI_Send(message, count, datatype, dest, tag, comm, ierr)
TYPE(*), DIMENSION(..) , INTENT(IN) :: message
INTEGER, INTENT(IN) :: count, dest, tag
TYPE(MPI_Datatype), INTENT(IN) :: datatype
TYPE(MPI_Comm), INTENT(IN) :: comm
INTEGER, OPTIONAL, INTENT(OUT) :: ierr
```

**Python (mpi4py):**

```python
# For general Python objects (pickled)
MPI.Intracomm.send(self, obj, int dest, int tag=0)
# For numpy arrays (fast)
MPI.Intracomm.Send(self, buf, int dest, int tag=0)
```

Note that the `datatype` argument, specifying the type of data contained in the `message` buffer, is a variable. This is intended to provide a layer of compatibility between processes that could be running on architectures for which the native format for these types differs. It is possible to register new data types, but for this tutorial we will only use the predefined types provided by MPI. There is a predefined MPI type for each atomic data type in the source language (for C: `MPI_CHAR`, `MPI_FLOAT`, `MPI_SHORT`, `MPI_INT`, etc. and for Fortran: `MPI_CHARACTER`, `MPI_INTEGER`, `MPI_REAL`, etc.). You can find a full list of these types in the references provided below.

`MPI_Recv` works in much the same way as `MPI_Send`. Referring to the function prototypes below, `message` is now a pointer to an allocated buffer of sufficient size to store `count` instances of `datatype`, to be received from process `rank`.

`MPI_Recv` takes one additional argument, `status`, which should, in C, be a reference to an allocated `MPI_Status` structure, and, in Fortran, be an array of `MPI_STATUS_SIZE` integers or, for `mpi_f08`, a derived `TYPE(MPI_Status)` variable. Upon return it will contain some information about the received message. Although we will not make use of it in this tutorial, the argument must be present.

**C:**

```c
int MPI_Recv(void *message, /* reference to buffer for received data */
             int count,      /* number of items to be received */
             MPI_Datatype datatype, /* type of item to be received */
             int source,     /* rank of process from which to receive */
             int tag,        /* programmer specified identifier */
             MPI_Comm comm,  /* communicator */
             MPI_Status *status /* stores info. about received message */
            );
```

**Boost (C++):**

```cpp
template <typename T>
status mpi::communicator::recv(int source, /* rank of process from which to receive */
                               int tag,  /* programmer specified identified */
                               const T& value /* message */
                              ) const;
```

**Fortran:**

```fortran
MPI_RECV(MESSAGE, COUNT, DATATYPE, SOURCE, TAG, COMM, STATUS, IERR)
<type> :: MESSAGE(*)
INTEGER :: COUNT, DATATYPE, SOURCE, TAG, COMM, STATUS(MPI_STATUS_SIZE), IERR
```

**Fortran 2008:**

```fortran
MPI_Recv(message, count, datatype, source, tag, comm, status, ierr)
TYPE(*), DIMENSION(..) :: message
INTEGER, INTENT(IN) :: count, source, tag
TYPE(MPI_Datatype), INTENT(IN) :: datatype
TYPE(MPI_Comm), INTENT(IN) :: comm
TYPE(MPI_Status) :: status
INTEGER, OPTIONAL, INTENT(OUT) :: ierr
```

**Python (mpi4py):**

```python
# For general Python objects (pickled)
MPI.Intracomm.recv(self, buf=None, int source=ANY_SOURCE, int tag=ANY_TAG, Status status=None)
# For numpy arrays (fast)
MPI.Intracomm.Recv(self, buf, int source=ANY_SOURCE, int tag=ANY_TAG, Status status=None)
```

With this simple use of `MPI_Send` and `MPI_Recv`, the sending process must know the rank of the receiving process, and the receiving process must know the rank of the sending process. In our example the following arithmetic is useful:

`(rank + 1) % size` is the process to send to, and

`(rank + size - 1) % size` is the process to receive from.

We can now make the required modifications to our parallel "Hello, world!" program as shown below.

**C:**

```c
#include <stdio.h>
#include <mpi.h>
#define BUFMAX 81
int main(int argc, char *argv[]) {
  char outbuf[BUFMAX], inbuf[BUFMAX];
  int rank, size;
  int sendto, recvfrom;
  MPI_Status status;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  sprintf(outbuf, "Hello, world! from process %d of %d", rank, size);
  sendto = (rank + 1) % size;
  recvfrom = (rank + size - 1) % size;
  MPI_Send(outbuf, BUFMAX, MPI_CHAR, sendto, 0, MPI_COMM_WORLD);
  MPI_Recv(inbuf, BUFMAX, MPI_CHAR, recvfrom, 0, MPI_COMM_WORLD, &status);
  printf("[P_%d] process %d said: \"%s\"]\n", rank, recvfrom, inbuf);
  MPI_Finalize();
  return (0);
}
```

**Boost (C++):**

```cpp
#include <iostream>
#include <string>
#include <boost/mpi.hpp>
using namespace std;
using namespace boost;
int main(int argc, char *argv[]) {
  mpi::environment env(argc, argv);
  mpi::communicator world;
  int rank = world.rank();
  int size = world.size();
  string outmessage = "Hello, world! from process " + to_string(rank) + " of " + to_string(size);
  string inmessage;
  int sendto = (rank + 1) % size;
  int recvfrom = (rank + size - 1) % size;
  cout << outmessage << endl;
  world.send(sendto, 0, outmessage);
  world.recv(recvfrom, 0, inmessage);
  cout << "[P_" << rank << "] process " << recvfrom << " said: \"" << inmessage << "\"" << endl;
  return 0;
}
```

**Fortran:**

```fortran
program phello2
  implicit none
  use mpi
  integer, parameter :: BUFMAX = 81
  character(len=BUFMAX) :: outbuf, inbuf, tmp
  integer :: rank, num_procs, ierr
  integer :: sendto, recvfrom
  integer :: status(MPI_STATUS_SIZE)
  call MPI_INIT(ierr)
  call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, num_procs, ierr)
  outbuf = 'Hello, world! from process '
  write(tmp,'(i2)') rank
  outbuf = outbuf(1:len_trim(outbuf)) // tmp(1:len_trim(tmp))
  write(tmp,'(i2)') num_procs
  outbuf = outbuf(1:len_trim(outbuf)) // ' of ' // tmp(1:len_trim(tmp))
  sendto = mod((rank + 1), num_procs)
  recvfrom = mod((rank + num_procs - 1), num_procs)
  call MPI_SEND(outbuf, BUFMAX, MPI_CHARACTER, sendto, 0, MPI_COMM_WORLD, ierr)
  call MPI_RECV(inbuf, BUFMAX, MPI_CHARACTER, recvfrom, 0, MPI_COMM_WORLD, status, ierr)
  print *, 'Process', rank, ': Process', recvfrom, ' said:', inbuf
  call MPI_FINALIZE(ierr)
end program phello2
```

**Fortran 2008:**

```fortran
program phello2
  implicit none
  use mpi_f08
  integer, parameter :: BUFMAX = 81
  character(len=BUFMAX) :: outbuf, inbuf, tmp
  integer :: rank, num_procs
  integer :: sendto, recvfrom
  type(MPI_Status) :: status
  call MPI_Init()
  call MPI_Comm_rank(MPI_COMM_WORLD, rank)
  call MPI_Comm_size(MPI_COMM_WORLD, num_procs)
  outbuf = 'Hello, world! from process '
  write(tmp,'(i2)') rank
  outbuf = outbuf(1:len_trim(outbuf)) // tmp(1:len_trim(tmp))
  write(tmp,'(i2)') num_procs
  outbuf = outbuf(1:len_trim(outbuf)) // ' of ' // tmp(1:len_trim(tmp))
  sendto = mod((rank + 1), num_procs)
  recvfrom = mod((rank + num_procs - 1), num_procs)
  call MPI_Send(outbuf, BUFMAX, MPI_CHARACTER, sendto, 0, MPI_COMM_WORLD)
  call MPI_Recv(inbuf, BUFMAX, MPI_CHARACTER, recvfrom, 0, MPI_COMM_WORLD, status)
  print *, 'Process', rank, ': Process', recvfrom, ' said:', inbuf
  call MPI_Finalize()
end program phello2
```

**Python (mpi4py):**

```python
from mpi4py import MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
outbuf = "Hello, world! from process %d of %d" % (rank, size)
sendto = (rank + 1) % size;
recvfrom = (rank + size - 1) % size;
comm.send(outbuf, dest=sendto, tag=0)
inbuf = comm.recv(source=recvfrom, tag=0)
print('[P_%d] process %d said: "%s"]' % (rank, recvfrom, inbuf))
```

Compile this program and run it using 2, 4, and 8 processes. While it certainly seems to be working as intended, there is a hidden problem here. The MPI standard does not **guarantee** that `MPI_Send` returns before the message has been delivered. Most implementations **buffer** the data from `MPI_Send` and return without waiting for it to be delivered. But if it were not buffered, the code we've written would deadlock: Each process would call `MPI_Send` and then wait for its neighbour process to call `MPI_Recv`. Since the neighbour would also be waiting at the `MPI_Send` stage, they would all wait forever. Clearly there *is* buffering in the libraries on our systems since the code did not deadlock, but it is poor design to rely on this. The code could fail if used on a system in which there is no buffering provided by the library. Even where buffering is provided, the call might still block if the buffer fills up.

```bash
[~]$ mpicc -Wall phello2.c -o phello2
[~]$ mpirun -np 4 ./phello2
[P_0] process 3 said: "Hello, world! from process 3 of 4"]
[P_1] process 0 said: "Hello, world! from process 0 of 4"]
[P_2] process 1 said: "Hello, world! from process 1 of 4"]
[P_3] process 2 said: "Hello, world! from process 2 of 4"]
```


### Safe MPI

The MPI standard defines `MPI_Send` and `MPI_Recv` to be **blocking calls**. This means `MPI_Send` will not return until it is safe for the calling module to modify the contents of the provided message buffer. Similarly, `MPI_Recv` will not return until the entire contents of the message are available in the message buffer the caller provides.

It should be obvious that whether or not the MPI library provides buffering does not affect receive operations. As soon as the data is received, it will be placed directly in the message buffer provided by the caller and `MPI_Recv` will return; until then the call will be blocked.

`MPI_Send` on the other hand need not block if the library provides an internal buffer. Once the message is copied out of the original data location, it is safe for the user to modify that location, so the call can return. This is why our parallel "Hello, world!" program doesn't deadlock as we have implemented it, even though all processes call `MPI_Send` first. Since the buffering is not required by the MPI standard and the correctness of our program relies on it, we refer to such a program as **unsafe** MPI.

A **safe** MPI program is one that does not rely on a buffered implementation in order to function correctly. The following pseudo-code fragments illustrate this concept:


#### Deadlock

```
...
if (rank == 0) {
  MPI_Recv(from 1);
  MPI_Send(to 1);
} else if (rank == 1) {
  MPI_Recv(from 0);
  MPI_Send(to 0);
}
...
```

Receives are executed on both processes before the matching send; regardless of buffering, the processes in this MPI application will block on the receive calls and deadlock.


#### Unsafe

```
...
if (rank == 0) {
  MPI_Send(to 1);
  MPI_Recv(from 1);
} else if (rank == 1) {
  MPI_Send(to 0);
  MPI_Recv(from 0);
}
...
```

This is essentially what our parallel "Hello, world!" program was doing, and it *may* work if buffering is provided by the library. If the library is unbuffered, or if messages are simply large enough to fill the buffer, this code will block on the sends, and deadlock. To fix that we will need to do the following instead:


#### Safe

```
...
if (rank == 0) {
  MPI_Send(to 1);
  MPI_Recv(from 1);
} else if (rank == 1) {
  MPI_Recv(from 0);
  MPI_Send(to 0);
}
...
```

Even in the absence of buffering, the send here is paired with a corresponding receive between processes. While a process may block for a time until the corresponding call is made, it cannot deadlock.

How do we rewrite our "Hello, World!" program to make it safe? A common solution to this kind of problem is to adopt an odd-even pairing and perform the communication in two steps. Since in our example communication is a rotation of data one rank to the right, we should end up with a safe program if all even ranked processes execute a send followed by a receive, while all odd ranked processes execute a receive followed by a send. The reader can easily verify that the sends and receives are properly paired avoiding any possibility of deadlock.

**C:**

```c
#include <stdio.h>
#include <mpi.h>
#define BUFMAX 81
int main(int argc, char *argv[]) {
  char outbuf[BUFMAX], inbuf[BUFMAX];
  int rank, size;
  int sendto, recvfrom;
  MPI_Status status;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  sprintf(outbuf, "Hello, world! from process %d of %d", rank, size);
  sendto = (rank + 1) % size;
  recvfrom = ((rank + size) - 1) % size;
  if (!(rank % 2)) {
    MPI_Send(outbuf, BUFMAX, MPI_CHAR, sendto, 0, MPI_COMM_WORLD);
    MPI_Recv(inbuf, BUFMAX, MPI_CHAR, recvfrom, 0, MPI_COMM_WORLD, &status);
  } else {
    MPI_Recv(inbuf, BUFMAX, MPI_CHAR, recvfrom, 0, MPI_COMM_WORLD, &status);
    MPI_Send(outbuf, BUFMAX, MPI_CHAR, sendto, 0, MPI_COMM_WORLD);
  }
  printf("[P_%d] process %d said: \"%s\"]\n", rank, recvfrom, inbuf);
  MPI_Finalize();
  return (0);
