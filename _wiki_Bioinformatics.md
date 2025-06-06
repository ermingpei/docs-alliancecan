# Bioinformatics

## General

Bioinformatics is the application of computational methods to address biological and biomedical research questions, often involving large-scale data generated by next-generation sequencing (NGS), proteomics, metabolomics, and other high-throughput experimental technologies. Common bioinformatics workflows on HPC systems include genome and transcriptome assembly, variant calling, gene expression quantification, epigenomic profiling, and multi-omics integration.

While bioinformatics intersects with fields like computational biology and systems biology, its reliance on specialized tools and large datasets makes it particularly well-suited for high-performance computing environments. The Alliance supports a wide range of bioinformatics applications and workflows through pre-installed modules, containerized environments, and workflow management systems.

A dedicated Bioinformatics National Team is available to assist with tool selection, pipeline development, and optimization. For a curated list of supported bioinformatics software, refer to the Bioinformatics Software Catalog (see below).


## Software

See [Available software](link-to-available-software) for a list of bioinformatics applications on our systems.  You can sort on `Type`, where bioinformatics software is categorized as `bio`.

Much bioinformatics software can be installed via Conda. We do not support the use of Conda directly on Alliance systems for reasons you can read at [Anaconda](link-to-anaconda-explanation). However, you can build a Conda environment inside an Apptainer container. Check [here](link-to-apptainer-details) for more details.

Much bioinformatics software is available as Python packages. Python packages which have been customized for use on our systems are listed at [Available Python wheels](link-to-python-wheels). Packages not found there may be obtained from the internet in the usual fashion. See [Python](link-to-python-guidance) for guidance on both these things.


## Data

Several bioinformatics databases are available on our clusters, including the NCBI BLAST non-redundant database, the AlphaFold Genetic database, and the Kraken2 standard database, among others. Users can access these databases via the following directory:

`/cvmfs/bio.data.computecanada.ca`

Additional datasets and databases may be found in the following locations:

* `/cvmfs/ref.mugqic` (supported by C3G, see below)
* `/cvmfs/ref.galaxy`
* `/cvmfs/public.data.computecanada.ca`
* `/datashare` (Graham Reference Dataset Repository, [external documentation](link-to-external-documentation))

Please note that not all datasets are available on every cluster, and support may vary across systems. Nevertheless, we will do our best to assist and provide support where possible.


## External Support

The Canadian Centre for Computational Genomics (C3G), is a bioinformatics core facility affiliated with McGill University. It collaborates with the Alliance to offer bespoke bioinformatics services and supports the bioinformatics community as members of the Alliance's Bioinformatics National Team. C3G maintains two CVMFS repositories:

* `soft.mugqic`: contains many open-source bioinformatics tools installed as modules
* `ref.mugqic`: contains reference genomes and their indices and annotations for many common model organisms.

For requests or questions about `mugqic` repositories, contact C3G at [1](link-to-c3g-contact) or via their website [computationalgenomics.ca](https://computationalgenomics.ca).


**(Note:  Please replace bracketed placeholders like `[link-to-available-software]` with actual links.)**
