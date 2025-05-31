# Cloud Resources

## Hardware

### Arbutus Cloud

Address: arbutus.cloud.alliancecan.ca

| Node count | CPU                     | Memory (GB) | Local (ephemeral) storage             | Interconnect | GPU       | Total CPUs | Total vCPUs |
|------------|--------------------------|-------------|-----------------------------------------|---------------|------------|------------|-------------|
| 156        | 2 x Gold 6248            | 384         | 2 x 1.92TB SSD in RAID0                | 1 x 25GbE     | N/A        | 6,240      | 12,480     |
| 8          | 2 x Gold 6248            | 1024        | 2 x 1.92TB SSD in RAID1                | 1 x 25GbE     | N/A        | 320        | 6,400      |
| 26         | 2 x Gold 6248            | 384         | 2 x 1.6TB SSD in RAID0                 | 1 x 25GbE     | 4 x V100 32GB | 1,040      | 2,080      |
| 32         | 2 x Gold 6130            | 256         | 6 x 900GB 10k SAS in RAID10            | 1 x 10GbE     | N/A        | 1,024      | 2,048      |
| 4          | 2 x Gold 6130            | 768         | 6 x 900GB 10k SAS in RAID10            | 2 x 10GbE     | N/A        | 128        | 2,560      |
| 8          | 2 x Gold 6130            | 256         | 4 x 1.92TB SSD in RAID5                | 1 x 10GbE     | N/A        | 256        | 512        |
| 240        | 2 x E5-2680 v4           | 256         | 4 x 900GB 10k SAS in RAID5                | 1 x 10GbE     | N/A        | 6,720      | 13,440     |
| 8          | 2 x E5-2680 v4           | 512         | 4 x 900GB 10k SAS in RAID5                | 2 x 10GbE     | N/A        | 224        | 4,480      |
| 2          | 2 x E5-2680 v4           | 128         | 4 x 900GB 10k SAS in RAID5                | 1 x 10GbE     | 2 x Tesla K80 | 56         | 112        |

Location: University of Victoria

Total CPUs: 16,008 (484 nodes)
Total vCPUs: 44,112
Total GPUs: 108 (28 nodes)
Total RAM: 157,184 GB
5.3 PB of Volume and Snapshot Ceph storage.
12 PB of Object/Shared Filesystem Ceph storage.


### Cedar Cloud

Address: cedar.cloud.alliancecan.ca

| Node count | CPU                     | Memory (GB) | Local (ephemeral) storage       | Interconnect | GPU       | Total CPUs | Total vCPUs |
|------------|--------------------------|-------------|------------------------------------|---------------|------------|------------|-------------|
| 28         | 2 x E5-2683 v4           | 256         | 2 x 480GB SSD in RAID1             | 1 x 10GbE     | N/A        | 896        | 1,792      |
| 4          | 2 x E5-2683 v4           | 256         | 2 x 480GB SSD in RAID1             | 1 x 10GbE     | N/A        | 128        | 256        |

Location: Simon Fraser University

Total CPUs: 1,024
Total vCPUs: 2,048
Total RAM: 7,680 GB
500 TB of persistent Ceph storage.


### Graham Cloud

Address: graham.cloud.alliancecan.ca

| Node count | CPU                         | Memory (GB) | Local (ephemeral) storage       | Interconnect | GPU       | Total CPUs | Total vCPUs |
|------------|-----------------------------|-------------|------------------------------------|---------------|------------|------------|-------------|
| 6          | 2 x E5-2683 v4               | 256         | 2x 500GB SSD in RAID0              | 1 x 10GbE     | N/A        | 192        | 384        |
| 2          | 2 x E5-2683 v4               | 512         | 2x 500GB SSD in RAID0              | 1 x 10GbE     | N/A        | 64         | 128        |
| 8          | 2 x E5-2637 v4               | 128         | 2x 500GB SSD in RAID0              | 1 x 10GbE     | N/A        | 256        | 512        |
| 8          | 2 x Xeon(R) Gold 6130 CPU    | 256         | 2x 500GB SSD in RAID0              | 1 x 10GbE     | N/A        | 256        | 512        |
| 3          | 2 x E5-2640 v4               | 256         | 2x 500GB SSD in RAID0              | 1 x 10GbE     | N/A        | 120        | 240        |
| 12         | 2 x Xeon(R) Gold 6248 CPU    | 768         | 2x 1TB SSD in RAID0               | 1 x 10GbE     | N/A        | 480        | 960        |

Location: University of Waterloo

Total CPUs: 1,368
Total vCPUs:  (This value is missing from the source)
Total RAM: 15,616 GB
84 TB of persistent Ceph storage.


### Béluga Cloud

Address: beluga.cloud.alliancecan.ca

| Node count | CPU                         | Memory (GB) | Local (ephemeral) storage       | Interconnect | GPU       | Total CPUs | Total vCPUs |
|------------|-----------------------------|-------------|------------------------------------|---------------|------------|------------|-------------|
| 96         | 2 x Intel Xeon Gold 5218     | 256         | N/A, ephemeral storage in ceph     | 1 x 25GbE     | N/A        | 3,072      | 6,144      |
| 16         | 2 x Intel Xeon Gold 5218     | 768         | N/A, ephemeral storage in ceph     | 1 x 25GbE     | N/A        | 512        | 1,024      |

Location: École de Technologie Supérieure

Total CPUs: 3,584
Total vCPUs: 7,168
Total RAM: 36,864 GiB
200 TiB of replicated persistent SSD Ceph storage.
1.7 PiB of erasure coded persistent HDD Ceph storage.


## Software

Alliance cloud OpenStack platform versions as of March 11, 2021

*   Arbutus: Ussuri
*   Cedar: Train
*   Graham: Ussuri
*   Béluga: Victoria

See the [OpenStack releases](link-to-openstack-releases-page) for a list of all OpenStack versions.


## Images

Images are provided by Alliance staff on the Alliance Clouds for common Linux distributions (Alma, Debian, Fedora, Rocky, and Ubuntu). New images for these distributions will be added periodically as new releases and updates become available. As releases have an end of life (EOL) after which support and updates are no longer provided, we encourage you to migrate systems and platforms to newer releases in order to continue receiving patches and security updates. Older images for Linux distributions past their EOL will be removed. This does not prevent you from continuing to run a VM with an EOL Linux distribution (though you shouldn't) but does mean that those images will no longer be available when creating new VMs.

For more details about using images see [working with images](link-to-working-with-images-page).

**(Note:  Please replace `link-to-openstack-releases-page` and `link-to-working-with-images-page` with the actual links.)**
