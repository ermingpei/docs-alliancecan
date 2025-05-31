# DL_POLY

## Généralités

DL_POLY est un logiciel classique de simulation en mécanique moléculaire. Sa conception permet de l’utiliser avec un ordinateur à processeur unique ou avec un ordinateur parallèle haute performance. DL_POLY_4 permet des opérations I/O entièrement parallèles et une alternative NetCDF (avec dépendance à une bibliothèque HDF5) aux fichiers de trajectoire ASCII par défaut.

Voir cette liste de diffusion

## Licence

DL_POLY est maintenant open source et il n'est pas nécessaire de vous enregistrer. Le nouveau module `dl_poly4/5.1.0` est installé sous `StdEnv/2023` et disponible à tous. Cependant, si vous voulez utiliser une version antérieure (`dl_poly4/4.10.0` et/ou `dl_poly4/4.08`), écrivez au soutien technique et demandez de vous ajouter à un groupe POSIX qui contrôle l'accès à DL_POLY4. Il n'est pas nécessaire de vous enregistrer sur le site web de DL_POLY.

## Modules

Pour connaître les versions disponibles, lancez `module spider dl_poly4`. La commande `module` est décrite dans la page Utiliser des modules.

Chargez la version 5.x avec :

```bash
module load StdEnv/2023 intel/2023.2.1 openmpi/4.1.5 dl_poly4/5.1.0
```

Pour charger la version précédente 4.10.0, utilisez :

```bash
module load StdEnv/2023 intel/2020.1.217 openmpi/4.0.3 dl_poly4/4.10.0
```

Prenez note que cette version doit être ajoutée à un groupe POSIX, comme décrit ci-dessus dans Licence.

L’interface graphique Java n’est pas offerte.

## Scripts et exemples

Les fichiers d’entrée CONTROL et FIELD proviennent de l’exemple TEST01 téléchargée à partir de [DL_POLY examples](link_to_examples_needed).

Pour lancer une simulation, il faut au moins les trois fichiers suivants :

* **CONFIG**: boîte de simulation (coordonnées atomiques)
* **FIELD**: paramètres de champs de force
* **CONTROL**: paramètres de simulation (pas, nombre d’étapes, ensemble de simulation, etc.)


### CONTROL

```
SODIUM CHLORIDE WITH (27000 IONS)

restart scale
temperature           500.0
equilibration steps   20
steps                 20
timestep              0.001

cutoff                12.0
rvdw                  12.0
ewald precision       1d-6  

ensemble nvt berendsen 0.01

print every           2
stats every           2
collect
job time              100
close time            10

finish
```

### FIELD

```
SODIUM CHLORIDE WITH EWALD SUM (27000 IONS)
units internal
molecular types 1
SODIUM CHLORIDE
nummols 27
atoms 1000
Na+          22.9898         1.0  500
Cl-           35.453        -1.0  500
finish
vdw    3 
Na+     Na+     bhm      2544.35      3.1545      2.3400   1.0117e+4   4.8177e+3
Na+     Cl-     bhm      2035.48      3.1545      2.7550   6.7448e+4   8.3708e+4
Cl-     Cl-     bhm      1526.61      3.1545      3.1700   6.9857e+5   1.4032e+6
close
```

### Tâche séquencielle

```bash
File: run_serial_dlp.sh
#!/bin/bash
#SBATCH --account=def-someuser
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2500M      # memory; default unit is megabytes.
#SBATCH --time=0-00:30           # time (DD-HH:MM).
# Load the module:
module load StdEnv/2023
module load intel/2023.2.1
module load openmpi/4.1.5
module load dl_poly4/5.1.0
echo "Starting run at: `date`"
dlp_exec=DLPOLY.Z
${dlp_exec}
echo "Program finished with exit code $? at: `date`"
```

### Tâche MPI

```bash
File: run_mpi_dlp.sh
#!/bin/bash
#SBATCH --account=def-someuser
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=2500M      # memory; default unit is megabytes.
#SBATCH --time=0-00:30           # time (DD-HH:MM).
# Load the module:
module load StdEnv/2023
module load intel/2023.2.1
module load openmpi/4.1.5
module load dl_poly4/5.1.0
echo "Starting run at: `date`"
dlp_exec=DLPOLY.Z

srun ${dlp_exec}
echo "Program finished with exit code $? at: `date`"
```

## Logiciels connexes

* VMD
* LAMMPS


**(Retrieved from "https://docs.alliancecan.ca/mediawiki/index.php?title=DL_POLY/fr&oldid=173389")**
