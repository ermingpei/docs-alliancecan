# CephFS

Le système de fichiers CephFS peut être partagé par plusieurs hôtes d'instances OpenStack. Pour profiter de ce service, faites une demande à `nuage@tech.alliancecan.ca`.

La procédure est plutôt technique et nécessite des compétences Linux de base pour créer et modifier des fichiers, définir des permissions et créer des points de montage. Si vous avez besoin d’assistance, écrivez à `nuage@tech.alliancecan.ca`.

## Procédure

**REMARQUE:** Plusieurs chaînes de caractères de l’interface OpenStack ne sont pas traduites en français.

### Demander l’accès aux points de partage (`shares`)

Si vous ne disposez pas déjà d’un quota pour ce service, écrivez à `nuage@tech.alliancecan.ca` et indiquez:

*   le nom du projet OpenStack
*   la capacité du quota requis (en Go)
*   le nombre de points de partage requis

### Configuration OpenStack: Créer un point de partage CephFS

Créez un point de partage. Dans `Project --> Share --> Shares`, cliquez sur `+Create Share`.

*   `Share Name` = entrez un nom significatif pour votre projet (par exemple `project-name-shareName`)
*   `Share Protocol` = CephFS
*   `Taille` = taille requise pour le point de partage
*   `Share Type` = cephfs
*   `Zone de disponibilité` = nova

Ne sélectionnez pas `Make visible for all`, autrement le point de partage sera accessible par tous les utilisateurs dans tous les projets. Cliquez sur le bouton `Create`.

### Configurer CephFS avec l'interface Horizon

Créez une règle pour générer une clé. Dans `Project --> Share --> Shares --> colonne Actions`, sélectionnez `Manage Rules` du menu déroulant. Cliquez sur le bouton `+Add Rule` à droite de la page.

*   `Access Type` = cephx
*   `Access Level` = sélectionnez `read-write` ou `read-only` (vous pouvez créer plusieurs règles à plusieurs niveaux)
*   `Access To` = entrez un nom significatif pour la clé; ce nom est important parce qu'il sera utilisé dans la configuration du client CephFS (ici le nom est `MyCephFS-RW`).

### Configuration correcte de CephFS

Prenez note des détails dont vous aurez besoin. Dans `Project --> Share --> Shares`, cliquez sur le nom du point de partage. Dans `Share Overview`, notez `Path`. Sous `Access Rules`, notez `Access Key` (les clés d’accès sont composées de 40 caractères et se terminent par le symbole `=`). Si vous ne voyez pas de clé d’accès, vous n’avez probablement pas spécifié que la règle d’accès était de type `cephx`.


### Attacher le réseau CephFS à votre instance

#### Sur Arbutus

Le réseau CephFS est déjà disponible pour vos instances et donc vous n'avez rien à faire. Allez à [Configuration d'une instance: installer et configurer un client CephFS](#configuration-dune-instance-installer-et-configurer-un-client-cephfs) ci-dessous.

#### Sur SD4H/Juno

Vous devez attacher le réseau CephFS à l'instance.

##### Sur le web

Pour chaque instance, sélectionnez `Instance --> Action --> Attach interface --> CephFS-Network`. Ne cochez pas la case `Fixed IP Address`.

##### Avec le client OpenStack

Faites afficher la liste des serveurs et sélectionnez l'identifiant de celui que vous voulez attacher à CephFS:

```bash
openstack server list
```

Sélectionnez l'identifiant de l'instance que vous voulez attacher, choisissez la première et lancez:

```bash
openstack server add network 1b2a3c21-c1b4-42b8-9016-d96fc8406e04 CephFS-Network
openstack server list
```

Nous remarquons que le réseau CephFS est attaché à la première instance.

### Configuration d'une instance: installer et configurer un client CephFS

#### Paquets requis pour la famille Red Hat (RHEL, CentOS, Fedora, Rocky, Alma)

Vérifiez quelles versions sont disponibles sur [https://download.ceph.com/](https://download.ceph.com/) et trouvez les répertoires `rpm-*` récents. Depuis juillet 2024, `quincy` est la plus récente version stable. Les distributions compatibles sont listées dans [https://download.ceph.com/rpm-quincy/](https://download.ceph.com/rpm-quincy/).

Nous montrons ici des exemples de configurations pour Enterprise Linux 8 et Enterprise Linux 9.

##### Installation des dépôts de paquets donnant accès aux paquets d'un client Ceph

###### Enterprise Linux 8 - el8

```
File: /etc/yum.repos.d/ceph.repo
[Ceph]
name = Ceph packages for $basearch
baseurl = http://download.ceph.com/rpm-quincy/el8/$basearch
enabled = 1
gpgcheck = 1
type = rpm-md
gpgkey = https://download.ceph.com/keys/release.asc
[Ceph-noarch]
name = Ceph noarch packages
baseurl = http://download.ceph.com/rpm-quincy/el8/noarch
enabled = 1
gpgcheck = 1
type = rpm-md
gpgkey = https://download.ceph.com/keys/release.asc
[ceph-source]
name = Ceph source packages
baseurl = http://download.ceph.com/rpm-quincy/el8/SRPMS
enabled = 1
gpgcheck = 1
type = rpm-md
gpgkey = https://download.ceph.com/keys/release.asc
```

###### Enterprise Linux 9 - el9

```
File: /etc/yum.repos.d/ceph.repo
[Ceph]
name = Ceph packages for $basearch
baseurl = http://download.ceph.com/rpm-quincy/el9/$basearch
enabled = 1
gpgcheck = 1
type = rpm-md
gpgkey = https://download.ceph.com/keys/release.asc
[Ceph-noarch]
name = Ceph noarch packages
baseurl = http://download.ceph.com/rpm-quincy/el9/noarch
enabled = 1
gpgcheck = 1
type = rpm-md
gpgkey = https://download.ceph.com/keys/release.asc
[ceph-source]
name = Ceph source packages
baseurl = http://download.ceph.com/rpm-quincy/el9/SRPMS
enabled = 1
gpgcheck = 1
type = rpm-md
gpgkey = https://download.ceph.com/keys/release.asc
```

Le répertoire epel doit être présent.

```bash
sudo dnf install epel-release
```

Vous pouvez maintenant installer ceph lib, cephfs client et autres dépendances.

```bash
sudo dnf install -y libcephfs2 python3-cephfs ceph-common python3-ceph-argparse
```

#### Paquets requis pour la famille Debian (Debian, Ubuntu, Mint, etc.)

Pour avoir le dépôt de paquets, trouvez le `{codename}` pour votre distribution avec `lsb_release -sc`

```bash
sudo apt-add-repository 'deb https://download.ceph.com/debian-quincy/ {codename} main'
```

Vous pouvez maintenant installer ceph lib, cephfs client et les autres dépendances.

```bash
sudo apt-get install -y libcephfs2 python3-cephfs ceph-common python3-ceph-argparse
```

#### Configurer le client ceph

Quand le client est installé, créez le fichier `ceph.conf`. La valeur de `mon host` est différente selon le nuage.

##### Arbutus

```
File: /etc/ceph/ceph.conf
[global]
admin socket = /var/run/ceph/$cluster-$name-$pid.asok
client reconnect stale = true
debug client = 0/2
fuse big writes = true
mon host = 10.30.201.3:6789,10.30.202.3:6789,10.30.203.3:6789
[client]
quota = true
```

##### SD4H/Juno

```
File: /etc/ceph/ceph.conf
[global]
admin socket = /var/run/ceph/$cluster-$name-$pid.asok
client reconnect stale = true
debug client = 0/2
fuse big writes = true
mon host = 10.65.0.10:6789,10.65.0.12:6789,10.65.0.11:6789
[client]
quota = true
```

Les informations sur le moniteur se trouvent dans le champ `Path` des détails du partage qui sera utilisé pour monter le volume. Si la valeur de la page Web est différente de ce qui est montré ici, cela signifie que la page wiki n'est pas à jour.

Entrez le nom du client et le secret dans le fichier `ceph.keyring`.

```
File: /etc/ceph/ceph.keyring
[client.MyCephFS-RW]
key = <access Key>
```

Encore une fois, la clé d'accès et le nom du client (ici `MyCephFS-RW`) se trouvent sous les règles d'accès sur la page Web de votre projet. Cliquez sur `Project --> Share --> Shares`, puis cliquez sur le nom du point de partage. Récupérez les informations de connexion dans la page `Share` pour votre connexion. Ouvrez les détails en cliquant sur le nom du point de partage dans la page `Shares`. Copiez le chemin d'accès complet du point de partage pour monter le système de fichiers.

### Monter le système de fichiers

Créez un répertoire pour le point de montage quelque part dans votre hôte (ici `/cephfs`)

```bash
mkdir /cephfs
```

Vous pouvez utiliser le pilote ceph pour monter votre périphérique CephFS de façon permanente en ajoutant ce qui suit dans le fstab de l'instance.

##### Arbutus

```
File: /etc/fstab
:/volumes/_nogroup/f6cb8f06-f0a4-4b88-b261-f8bd6b03582c /cephfs/ ceph name=MyCephFS-RW 0  2
```

##### SD4H/Juno

```
File: /etc/fstab
:/volumes/_nogroup/f6cb8f06-f0a4-4b88-b261-f8bd6b03582c /cephfs/ ceph name=MyCephFS-RW,mds_namespace=cephfs_4_2,x-systemd.device-timeout=30,x-systemd.mount-timeout=30,noatime,_netdev,rw 0  2
```

**Remarque:** le caractère `:` non standard devant le chemin d'accès au périphérique n'est pas une erreur de frappe. Les options de montage sont différentes selon les systèmes. L'option `namespace` est requise pour SD4H/Juno, tandis que les autres options sont des ajustements de performance.

Vous pouvez aussi faire le montage directement en ligne de commande.

##### Arbutus

```bash
sudo mount -t ceph :/volumes/_nogroup/f6cb8f06-f0a4-4b88-b261-f8bd6b03582c /cephfs/ -o name=MyCephFS-RW
```

##### SD4H/Juno

```bash
sudo mount -t ceph :/volumes/_nogroup/f6cb8f06-f0a4-4b88-b261-f8bd6b03582c /cephfs/ -o name=MyCephFS-RW,mds_namespace=cephfs_4_2,x-systemd.device-timeout=30,x-systemd.mount-timeout=30,noatime,_netdev,rw
```

CephFS peut aussi être monté directement dans votre espace de travail via ceph-fuse. Installez la bibliothèque ceph-fuse.

```bash
sudo dnf install ceph-fuse
```

Pour que le montage soit disponible dans votre espace utilisateur, retirez le code de commentaire `user_allow_other` dans le fichier `fuse.conf`.

```
File: /etc/fstab
# mount_max = 1000
user_allow_other
```

Vous pouvez maintenant monter cephFS dans votre espace `/home`.

```bash
mkdir ~/my_cephfs
ceph-fuse my_cephfs/ --id=MyCephFS-RW --conf=~/ceph.conf --keyring=~/ceph.keyring --client-mountpoint=/volumes/_nogroup/f6cb8f06-f0a4-4b88-b261-f8bd6b03582c
```

Notez que le nom du client est ici le `--id`. Le contenu de `ceph.conf` et de `ceph.keyring` est exactement le même que pour le montage du noyau ceph.

## Remarques

Un point de partage particulier peut disposer de plusieurs clés utilisateur. Cela permet un accès plus précis au système de fichiers, par exemple si vous avez besoin que certains hôtes accèdent au système de fichiers uniquement en lecture seule. Si vous disposez de plusieurs clés pour un point de partage, vous pouvez ajouter les clés supplémentaires à votre hôte et modifier la procédure de montage ci-dessus. Ce service n'est pas disponible pour les hôtes extérieurs à la grappe OpenStack.


