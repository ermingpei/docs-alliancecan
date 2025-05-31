# Clés SSH

Cette page est une version traduite de la page [SSH Keys](https://docs.alliancecan.ca/mediawiki/index.php?title=SSH_Keys&oldid=160846) et la traduction est complète à 100 %.

Autres langues : [English](https://docs.alliancecan.ca/mediawiki/index.php?title=SSH_Keys&oldid=160846), français

## Qu'est-ce qu'une clé SSH ?

SSH utilise la cryptographie à clé publique (CP) ou cryptographie asymétrique pour sécuriser les connexions. Dans ce mode de chiffrement, une clé reste secrète (clé privée) et l'autre clé peut être divulguée (clé publique).  Tous peuvent utiliser la clé publique pour encoder un message, mais seul le propriétaire de la clé privée peut le décoder.

La clé publique permet aussi de valider l'identité d'un utilisateur.  Exemple : Robert veut communiquer avec Alice qui dit posséder une clé privée, mais il veut s'assurer qu'Alice est bien celle qui le prétend. Robert peut utiliser la clé publique d'Alice pour lui envoyer un message codé. Si Alice peut prouver à Robert que son message est compris, on peut conclure qu'Alice est effectivement propriétaire de la clé privée.

Les systèmes à CP sont au cœur des protocoles SSL et TLS qui protègent la plupart des communications sur internet, dont les sites HTTPS.

La CP a plusieurs usages sur nos grappes :

* Quand vous vous connectez à une grappe, votre client SSH utilise habituellement la clé publique de cette grappe pour vérifier que la connexion se fait au bon serveur.
* Une session cryptée peut être établie pour prévenir l'interception des messages échangés.
* Le serveur distant peut utiliser votre clé publique pour vérifier votre identité et ainsi vous permettre de vous connecter.

Nous vous recommandons fortement d'utiliser l'authentification par CP, qui est habituellement plus sécuritaire qu'un mot de passe.


## Générer une clé SSH

Ceci exige du travail de configuration de votre part, mais une fois en place, vous y gagnerez en sécurité et en praticabilité. Vous devez générer une paire de clés et installer la clé publique sur tous les systèmes auxquels vous voulez vous connecter.

Vous devriez créer une paire de clés sur votre propre ordinateur ou sur un ordinateur que vous croyez sécuritaire. Comme c'est le cas pour les mots de passe, la clé privée de cette paire ne devrait pas être partagée ou copiée sur un autre ordinateur.

Quand une paire de clés est générée, vous devez entrer une phrase de passe ; ceci est une chaîne de caractères qui sert à chiffrer votre clé privée. Choisissez une phrase de passe robuste, dont vous vous souviendrez facilement ; nous recommandons un minimum de 15 caractères. La phrase de passe offre une protection si la clé privée est volée.

La procédure pour générer une paire de clés SSH varie selon votre système d'exploitation. Pour les clients Windows PuTTY ou MobaXterm, voyez [Générer des clés sous Windows](TODO: Lien vers la page). Pour les environnements Linux (Linux, Mac, Windows Subsystem for Linux ou Cygwin), voyez [Utiliser des clés SSH sous Linux](TODO: Lien vers la page).

De plus, si vous utilisez un nuage, OpenStack offre une méthode pour créer des paires de clés ; voyez [Paires de clés SSH](TODO: Lien vers la page).


## Installer une clé

### Via CCDB

Pour installer la clé, le système cible (la destination) doit connaître la partie publique de votre clé. En date de mars 2021, nous avons ajouté un moyen simple pour faire cela.

Les étapes à suivre sont :

**ÉTAPE 1**

- Connectez-vous à CCDB avec [https://ccdb.computecanada.ca/ssh_authorized_keys](https://ccdb.computecanada.ca/ssh_authorized_keys) ou par le menu suivant dans CCDB

**ÉTAPE 2**

- Copiez votre clé publique SSH

Comme la clé publique est en format texte, vous pouvez la voir sous Windows en ouvrant le fichier avec Notepad et sous Linux/macOS en entrant `cat .ssh/id_rsa.pub` en ligne de commande.

Dans les deux cas, vous devriez obtenir une longue suite de caractères comme :

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3qeojDkUShnPTq9pI3cCZe+jgD6RKA/6CPsJIWZ8MqbX6wkk6
hHgKqKd2/9d7cj8e03Cfv4JLoD++P9fUPE3UyYrP/uVi4zytp5rmIZI4Qo1LvD1Obs0e78y0Dp7pfG1EHTYdn0p8
zHa0lNLOrZMmzDP0UMVdf4WKuv3Th2K/35yQ7DVIei6X/33Dcmsqd8bTXq7aFlw2y4sa/CHs314G6WYuJ9cTXtsW
Dlc9oWJuOVqILJLeGQpl3BVEM9aKcYksqLMV1UlZF8bHbry0PKCnrJrNMzVulWfnmSOZ+lPcV32OsDRkFaKsdxPy
+PxywieC86mxy1v216jeOdHnhLfOJc/VYDqf4egxReSCb3WOucHBB5J1jtDt47GuamKs+F2T7obqCb0J6oTyzgVF
RIZryxwvh5fQF5jk3LsBGsbhe9GYwDAk54GV6I0rWnXp56mJZjO4JCRQGbwLAJVxH4a7UrBmba2pRcZxEZmbIcBB
Sjb9KPECtaxiY/aty39077DCmcLCmzeOgBdh0zIkdBYu+OJ65MFKMxzoJWPDbZIcbSRGHEVhDnBZMNj1OiJS+E2D
A+F0tPH7J+xox1vUoXGAI0cNv+s/nlVRuOZoZjhk6s7tLXeVcToc+Y9Wqx8fdL7D4FegWwB9lsVhpfC4NaA9R8Ao
OfJUwHSNqUc6SfIt7w== user@machine
```

Prenez note que vous devez générer votre propre paire de clés (publique et privée) ; vous ne pouvez pas copier et utiliser l'exemple ci-dessus. Si le format est différent (par exemple, si la clé est générée avec PuTTY), vous pouvez ouvrir PuTTYgen ou MobaxTerm SSH Key Generator et, sous *File*, sélectionner *Load private key*, puis copier le contenu sous *Public key for pasting into OpenSSH authorized_keys* comme illustré ici.

Voici l'exemple avec une clé publique en format PEM qui doit être convertie avant de passer à l'étape 3 :

```
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEAxFm+Fbs+szeV2Vg2T5ufg8az0jD9DD/A0iNLKef2/0gPULn1ebFQ
SvQwts5ZGcza9t6l7fSKObz8FiAwXn+mdmXrxx3fQIepWa2FeCNbTkiKTTpNmERw
H0v3RR3DpJd8cpg5jdJbINlqDUPdqXxZDPIyZuHbEYUiSrb1v5zscVdgVqhJYi9O
OiEj7dPOLp1ko6s7TSgY8ejGnbmUL/gl+/dfhMNKdhLXMXWByucF1577rfAz3qPn
4JMWrG5TCH7Jj8NpIxFhkV9Qjy40Ml81yDqMlbuE9CUZzVhATe8MdIvcXUQej8yl
ddmNnAXmfTDwUd5cJ/VSMaKeq6Gjd/XDmwIDAQAB
-----END RSA PUBLIC KEY-----
```

**ÉTAPE 3**

- Téléversez votre clé publique SSH dans le formulaire de CCDB

Vous pouvez ensuite coller la partie publique de votre clé dans le formulaire de CCDB. Il est préférable d'entrer une description de cette clé pour vous aider à la reconnaître.

Après avoir cliqué sur *Ajouter la clé*, les informations suivantes seront affichées.

Une fois que votre clé est enregistrée dans CCDB, elle peut être utilisée pour vous connecter à toutes nos grappes. Cependant, nos nuages OpenStack n'ont pas accès aux clés enregistrées dans CCDB.

Les modifications aux clés publiques sont souvent propagées aux grappes en quelques minutes ; par contre, dans certains cas, il y a une attente d'environ 30 minutes.

**Remarque:** Les clés publiques au format RFC4716 et PKCS8 ressemblent à celles en format PEM, mais présentent des différences dans l'en-tête et le bas de page.


### Par le fichier authorized_keys

**AVERTISSEMENT:** Le soutien pour cette méthode pourrait être cessé.

Le fait d'enregistrer votre clé publique dans CCDB la rend disponible sur toutes nos grappes, ce qui est pratique et souvent souhaitable. Cependant, dans certains cas, vous pourriez vouloir installer une clé sur juste une grappe particulière. Pour ce faire, ajoutez la clé dans un fichier de votre répertoire `/home` sur cette grappe. Par exemple, pour une clé qui fonctionne uniquement sur Cedar, copiez votre clé publique dans le fichier `~/.ssh/authorized_keys` sur Cedar.

Ceci vous permettra de vous connecter aux nœuds de connexion de Cedar avec la CP.

Sur nos grappes (et toute autre grappe avec OpenSSH), la commande `ssh-copy-id` est la façon la plus pratique de procéder :

```bash
ssh-copy-id -i computecanada-key username@cedar.computecanada.ca
```

Le mécanisme `authorized_keys` est standard et utilisé presque partout sur internet, mais il est quelque peu fragile. En particulier, SSH est très sensible aux permissions pour le fichier `authorized_keys`, ainsi que pour votre répertoire `/home` et sous-répertoire `.ssh`.

Pour plus d'information, voyez [Utiliser des clés SSH sous Linux](TODO: Lien vers la page).


## Agent d'authentification

Il est important que votre clé privée soit protégée par l'emploi d'une phrase de passe, mais il est peu pratique d'avoir à entrer la phrase de passe à chaque fois que vous utilisez votre clé. Plutôt que de laisser votre clé non chiffrée, nous vous recommandons fortement d'employer un agent SSH. Vous entrez votre phrase de passe au lancement de l'agent et ce dernier fournit la clé privée pour vos nouvelles connexions. Ainsi, vous évitez de conserver une clé privée non chiffrée dans un espace de stockage permanent où elle peut facilement être copiée ou volée.


## Options pour générer une clé

**Attention:** Cette opération devrait être effectuée sur votre propre ordinateur et non sur un ordinateur partagé comme une grappe.

Quand une clé est générée, les valeurs par défaut conviennent habituellement, mais certaines options sont à considérer. Dans les exemples suivants, nous utilisons `ssh-keygen` tel que décrit dans [Utiliser des clés SSH sous Linux](TODO: Lien vers la page), mais les options s'appliquent également avec une interface graphique tel que décrit dans [Générer des clés SSH sous Windows](TODO: Lien vers la page).

* Pour ajouter un commentaire servant à différencier une clé d'une autre :

```bash
ssh-keygen -C 'Alliance systems'
```

* Pour sélectionner le fichier de la clé :

```bash
ssh-keygen -f alliance-key
```

Ceci produit le fichier `alliance-key` qui contient la partie privée de la clé et le fichier `alliance-key.pub` qui contient la partie publique. Dans ce cas, vous devrez peut-être utiliser l'option `-i` pour indiquer le nom de la clé quand vous connecterez ; la commande serait `ssh -i alliance-key user@host`.

* Pour utiliser un type de clé différent du type RSA par défaut :

```bash
ssh-keygen -t ed25519
```

* Pour renforcer certains types de clés tels RSA avec une clé plus longue :

```bash
ssh-keygen -t rsa-sha2-512 -b 4096
```


## Définir des contraintes

Dans la syntaxe pour la clé publique, vous pouvez définir des contraintes qui limitent ce que la clé peut faire. Par défaut, une clé sans contrainte peut tout faire.

Par exemple, la clé publique :

```
restrict,command="squeue --me" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhczaUoV6SzR2VEf9Rp4/P9xHVU8S72CKHrwKU+Yntx
```

ne peut effectuer qu'une seule opération (savoir si vous avez des tâches dans Slurm). Un exemple intéressant est :

```
restrict,command="/usr/libexec/openssh/sftp-server" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhczaUoV6SzR2VEf9Rp4/P9xHVU8S72CKHrwKU+Yntx
```

qui permet d'utiliser la clé seulement pour SFTP (ce qui est la façon dont `sshfs` fonctionne).

Une contrainte peut aussi limiter les hôtes pouvant se connecter avec la clé :

```
restrict,from="d24-141-114-17.home.cgocable.net" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhczaUoV6SzR2VEf9Rp4/P9xHVU8S72CKHrwKU+Yntx
```

Le fait de limiter les hôtes est un excellent moyen de minimiser le risque que la clé soit compromise. Le terme `restrict` désactive l'allocation pty qui crée un comportement insolite. Pour définir un seul hôte pour une session interactive et permettre une allocation pty :

```
restrict,from="d24-141-114-17.home.cgocable.net",pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhczaUoV6SzR2VEf9Rp4/P9xHVU8S72CKHrwKU+Yntx
```

Il existe plusieurs de ces contraintes qui sont décrites dans la page `sshd man` (`man sshd` sous Linux).


## Meilleures pratiques

* Les clés doivent être uniques à un compte particulier et ne jamais être utilisées par plus d'une personne.
* Si vous devez partager un ordinateur avec d'autres personnes, enregistrez votre clé privée dans un endroit sûr auquel vous seul avez accès ; autrement, enregistrez la clé privée sur une clé USB.
* Chiffrez toujours votre clé privée avec une phrase de passe ; nous recommandons un minimum de 15 caractères.
* Ne partagez votre clé privée avec personne.
* Ne copiez jamais votre clé privée sur un ordinateur distant ; elle ne devrait jamais quitter votre poste de travail.
* Si vous avez plusieurs ordinateurs personnels, vous pouvez créer des paires de clés SSH dédiées pour chacun.
* Si vous avez plusieurs paires de clés SSH, vous pourriez donner un nom aux clés, par exemple `Laptop_RSA4096`.
* Si vous donnez un nom à une clé, vous devez utiliser l'option `-i` pour spécifier la clé quand vous vous connectez ; la commande serait `ssh -i Laptop_RSA4096 username@host`.
* Utilisez `ssh-agent` pour travailler avec vos clés plus facilement.
* Si vous utilisez `agent-forwarding`, utilisez aussi `ssh-askpass`.
* Définissez des contraintes pour votre clé publique pour en limiter la portée.

Voyez aussi ces courtes vidéos sur comment configurer les clés SSH :

* [Faster and more secure SSH](TODO: Lien vers la vidéo)
* [Using SSH Keys on Windows](TODO: Lien vers la vidéo)
* [Using SSH Keys on Mac](TODO: Lien vers la vidéo)
* [Using SSH Keys on Linux](TODO: Lien vers la vidéo)


## Clés SSH révoquées

Il y a plusieurs raisons pour lesquelles une clé SSH est révoquée, par exemple si nous constatons qu'une clé est utilisée par plus d'une personne ou s'il est possible que la clé privée soit compromise. Ceci peut se produire dû à plusieurs causes dont une gestion déficiente des clés, un vol ou une brèche de sécurité. Il y a alors un risque important à la sécurité, car une personne malveillante peut utiliser la clé compromise pour avoir accès aux systèmes et à des données sensibles. Dans le but de limiter ce risque, l'Alliance a établi une liste de révocation.

Il s'agit d'un registre des clés SSH qui ne sont plus fiables ou sont autrement considérées comme étant non valides. Aucune des clés SSH dans cette liste ne peut être utilisée pour avoir accès aux services de l'Alliance.

Si vous croyez qu'une de vos clés SSH a été révoquée, il est très important d'agir au plus tôt.

* Remplacez la clé révoquée par une nouvelle clé qui vous permettra de vous connecter aux services de l'Alliance en toute sécurité.
* Supprimez la clé révoquée de tous les services (de l'Alliance et autres) pour empêcher les accès non autorisés ou les brèches de sécurité.

Si vous pensez qu'une de vos clés SSH se trouve par erreur dans notre liste de révocation ou si vous avez des questions à ce sujet, écrivez au soutien technique. La sécurité de notre infrastructure est de la plus haute importance et la vigilance de tous est essentielle à l'intégrité de la recherche numérique et de la collaboration.
