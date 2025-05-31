# Cedar

**Other languages:** [English](https://docs.alliancecan.ca/mediawiki/index.php?title=Cedar/en&oldid=153233) | français

**Availability:** Compute RAC2017 allocations started June 30, 2017

**Login node:** cedar.alliancecan.ca

**Globus endpoint:** computecanada#cedar-globus

**System Status Page:** https://status.alliancecan.ca/

Cedar is a heterogeneous cluster suitable for a variety of workloads; it is located at Simon Fraser University. It is named for the Western Red Cedar, B.C.’s official tree, which is of great spiritual significance to the region's First Nations people.

Cedar is sold and supported by Scalar Decisions, Inc. The node manufacturer is Dell, the high-performance temporary storage /scratch filesystem is from DDN, and the interconnect is from Intel. It is entirely liquid-cooled, using rear-door heat exchangers.

**NOTE:** Globus version 4 endpoints are no longer supported. The endpoint `computecanada#cedar-dtn` has been retired. Please use version 5 endpoint `computecanada#cedar-globus`.


## Getting started with Cedar

* How to run jobs
* Transferring data


## Contents

1. Storage
2. High-performance interconnect
3. Node characteristics
    * Choosing a node type
4. Submitting and running jobs policy
5. Performance


## Storage

### Home space

* 526TB total volume
* Location of `/home` directories.
* Each `/home` directory has a small fixed quota.
* Not allocated via RAS or RAC. Larger requests go to the `/project` space.
* Has daily backup

### Scratch space

* 5.4PB total volume
* Parallel high-performance filesystem
* For active or temporary (scratch) storage.
* Not allocated.
* Large fixed quota per user.
* Inactive data will be purged.

### Project space

* 23PB total volume
* External persistent storage
* Not designed for parallel I/O workloads. Use `/scratch` space instead.
* Large adjustable quota per project.
* Has daily backup.

The `/scratch` storage space is a Lustre filesystem based on DDN model ES14K technology. It includes 640 8TB NL-SAS disk drives, and dual redundant metadata controllers with SSD-based storage.


## High-performance interconnect

Intel OmniPath (version 1) interconnect (100Gbit/s bandwidth). A low-latency high-performance fabric connecting all nodes and temporary storage.

By design, Cedar supports multiple simultaneous parallel jobs of up to 1024 Broadwell cores (32 nodes) or 1536 Skylake cores (32 nodes) or 1536 Cascade Lake cores (32 nodes) in a fully non-blocking manner. For larger jobs the interconnect has a 2:1 blocking factor, i.e., even for jobs running on several thousand cores, Cedar provides a high-performance interconnect.


## Node characteristics

Cedar has 100,400 CPU cores for computation, and 1352 GPU devices. Turbo Boost is deactivated for all Cedar nodes.

| nodes | cores | available memory | CPU                                         | storage     | GPU                                      |
|-------|-------|--------------------|---------------------------------------------|-------------|------------------------------------------|
| 256   | 32    | 125G or 128000M     | 2 x Intel E5-2683 v4 Broadwell @ 2.1GHz      | 2 x 480G SSD | -                                          |
| 256   | 32    | 250G or 257000M     | 2 x Intel E5-2683 v4 Broadwell @ 2.1GHz      | 2 x 480G SSD | -                                          |
| 40    | 32    | 502G or 515000M     | 2 x Intel E5-2683 v4 Broadwell @ 2.1GHz      | 2 x 480G SSD | -                                          |
| 16    | 32    | 1510G or 1547000M    | 2 x Intel E5-2683 v4 Broadwell @ 2.1GHz      | 2 x 480G SSD | -                                          |
| 6     | 32    | 4000G or 4096000M    | 2 x AMD EPYC 7302 @ 3.0GHz                   | 2 x 480G SSD | -                                          |
| 2     | 40    | 6000G or 6144000M    | 4 x Intel Gold 5215 Cascade Lake @ 2.5GHz    | 2 x 480G SSD | -                                          |
| 96    | 24    | 125G or 128000M     | 2 x Intel E5-2650 v4 Broadwell @ 2.2GHz      | 1 x 800G SSD | 4 x NVIDIA P100 Pascal (12G HBM2 memory) |
| 32    | 24    | 250G or 257000M     | 2 x Intel E5-2650 v4 Broadwell @ 2.2GHz      | 1 x 800G SSD | 4 x NVIDIA P100 Pascal (16G HBM2 memory) |
| 192   | 32    | 187G or 192000M     | 2 x Intel Silver 4216 Cascade Lake @ 2.1GHz | 1 x 480G SSD | 4 x NVIDIA V100 Volta (32G HBM2 memory)  |
| 608   | 48    | 187G or 192000M     | 2 x Intel Platinum 8160F Skylake @ 2.1GHz   | 2 x 480G SSD | -                                          |
| 768   | 48    | 187G or 192000M     | 2 x Intel Platinum 8260 Cascade Lake @ 2.4GHz | 2 x 480G SSD | -                                          |


Note that the amount of available memory is fewer than the round number suggested by the hardware configuration. For instance, base nodes do have 128 GiB of RAM, but some of it is permanently occupied by the kernel and OS. To avoid wasting time by swapping/paging, the scheduler will never allocate jobs whose memory requirements exceed the amount of available memory shown above.

All nodes have local (on-node) temporary storage. Compute nodes (except GPU nodes) have two 480GB SSD drives, for a total raw capacity of 960GB. GPU nodes have either an 800GB or a 480GB SSD drive. Use node-local storage through the job-specific directory created by the scheduler, `$SLURM_TMPDIR`. See *Using node-local storage*.


### Choosing a node type

A number of 48-core nodes are reserved for jobs that require whole nodes. There are no 32-core nodes set aside for whole node processing.

Jobs that request less than 48 cores per node can end up sharing nodes with other jobs.

Most applications will run on either Broadwell or Skylake or Cascade Lake nodes, and performance differences are expected to be small compared to job waiting times. Therefore we recommend that you do not select a specific node type for your jobs. If it is necessary, use `--constraint=cascade`, `--constraint=skylake` or `--constraint=broadwell`. If the requirement is for any AVX512 node, use `--constraint=[skylake|cascade]`.


## Submitting and running jobs policy

As of April 17, 2019, jobs can no longer run in the `/home` filesystem. The policy was put in place to reduce the load on this filesystem and improve the responsiveness for interactive work. If you get the message "Submitting jobs from directories residing in /home is not permitted", transfer the files either to your `/project` or `/scratch` directory and submit the job from there.


## Performance

Theoretical peak double precision performance of Cedar is 6547 teraflops for CPUs, plus 7434 for GPUs, yielding almost 14 petaflops of theoretical peak double precision performance.

Cedar's network topology is made up of islands with a 2:1 blocking factor between islands. Within an island the interconnect (Omni-Path fabric) is fully non-blocking.

Most islands contain 32 nodes:

* 16 islands with 32 Broadwell nodes, each with 32 cores, i.e., 1024 cores per island;
* 43 islands with 32 Skylake or Cascade Lake nodes, each with 48 cores, i.e., 1536 cores per island;
* 4 islands with 32 P100 GPU nodes;
* 6 islands with 32 V100 GPU nodes;
* 2 islands each with 32 big memory nodes; of these 64 nodes, 40 are of 0.5TB, 16 are of 1.5TB, 6 are of 4TB and 2 are of 6TB.

Retrieved from "[https://docs.alliancecan.ca/mediawiki/index.php?title=Cedar/en&oldid=153233](https://docs.alliancecan.ca/mediawiki/index.php?title=Cedar/en&oldid=153233)"
