# META-Farm

This page is a translated version of the page [META-Farm](https://docs.alliancecan.ca/mediawiki/index.php?title=META-Farm&oldid=174695) and the translation is 100% complete.

Other languages: [English](https://docs.alliancecan.ca/mediawiki/index.php?title=META-Farm&oldid=174695), [français](https://docs.alliancecan.ca/mediawiki/index.php?title=META-Farm/fr&oldid=174697)


## Nouveauté

La version 1.0.3 publiée en mars 2025 fonctionne sur la grappe Niagara (et sur Trillium qui remplacera Niagara). Ceci est rendu possible avec l'ajout du nouveau mode WHOLE_NODE (inactif par défaut, mais configurable dans config.h) et de quelques autres ajustements. Le mode WHOLE_NODE rassemble les cas séquentiels de calcul dans des tâches qui demandent des nœuds complets. Pour plus d'information, voir [META-Farm : Fonctions avancées et dépannage](https://docs.alliancecan.ca/mediawiki/index.php?title=META-Farm/Advanced_features_and_troubleshooting/fr&oldid=174700).


## Description

META (pour META-Farm) est une suite de scripts conçus par l’équipe SHARCNET pour automatiser l’exécution d’un grand nombre de calculs connexes. En anglais, cette pratique est parfois nommée *farming*, *serial farming* ou *task farming*. META fonctionne sur tous les systèmes nationaux de l'Alliance et peut également être utilisée sur d'autres grappes qui possèdent la même configuration et qui font usage de l’ordonnanceur Slurm.

Nous employons ici le terme *cas* (en anglais *case*) pour désigner un calcul distinct; il peut être l'exécution d'un programme en série, d'un programme parallèle ou d'un programme utilisant un GPU.
Le terme *tâche* (en anglais *job*) est employé pour désigner une invocation à l’ordonnanceur de tâches; une tâche peut regrouper plusieurs cas.

META possède les fonctionnalités suivantes :

*   deux modes de fonctionnement :
    *   le mode SIMPLE avec un cas par tâche,
    *   le mode META avec plusieurs cas par tâche.
*   équilibrage dynamique de la charge de travail en mode META,
*   capture du statut de sortie pour tous les cas individuels,
*   resoumission automatique de tous les cas qui ont échoué ou n'ont jamais été exécutés,
*   exécution automatique d’une tâche de post-traitement une fois que tous les cas ont été traités avec succès.

Quelques exigences techniques :

*   Pour chaque groupe de cas, chaque cas à traiter doit être décrit sur une ligne distincte dans un fichier `table.dat`.
*   Vous pouvez exécuter plusieurs groupes de cas indépendamment, mais chacun doit avoir son propre répertoire.
*   En mode META, le nombre de tâches (ou *métatâches*) effectivement soumises est généralement bien inférieur au nombre de cas à traiter. Chaque métatâche peut traiter plusieurs lignes du fichier `table.dat`, donc plusieurs cas. Une collection de métatâches lira les lignes de `table.dat` séquentiellement en commençant par la première ligne et utilisera le mécanisme `lockfile` pour éviter une situation de concurrence. Ceci garantit un bon équilibre dynamique de la charge de travail entre les métatâches, car celles qui traitent des cas plus courts peuvent en traiter davantage.
*   En mode META, toutes les métatâches n'ont pas besoin d'exécuter des cas. La première métatâche commencera à traiter les lignes de `table.dat` et si la deuxième tâche démarre, elle rejoint la première, et ainsi de suite. Si le temps d'exécution d'une métatâche individuelle est suffisamment long, tous les cas peuvent être traités avec une seule métatâche.


### META vs GLOST

META possède des avantages importants par rapport à d'autres approches telles que GLOST où le traitement de chaque groupe de cas est effectué dans une seule grande tâche parallèle (MPI).

*   Comme l'ordonnanceur dispose de toute la souplesse pour démarrer les métatâches individuelles quand il le souhaite, le temps en file d'attente peut être beaucoup plus court avec META qu'avec GLOST. Par exemple, dans un contexte où 1 000 cœurs CPU doivent être utilisés pendant 3 jours avec GLOST et MPI, le temps en file d'attente peut être de plusieurs semaines et il faudra donc des semaines avant d’obtenir votre tout premier résultat; avec META, certaines métatâches démarrent et produisent les premiers résultats en quelques minutes.
*   À la fin du traitement d'un groupe de cas, avec GLOST, certains rangs MPI se termineront plus tôt et resteront inactifs jusqu'à la fin du tout dernier rang MPI, le plus lent; avec META, il n'y a pas de telle perte à la fin du traitement; les métatâches individuelles sortent plus tôt si elles n'ont plus de charge de travail à traiter.
*   GLOST et d'autres outils similaires ne prennent pas en charge la resoumission automatisée des cas qui ont échoué ou qui n'ont jamais été exécutés. META possède cette fonctionnalité qui de plus est très facile à utiliser.


### Webinaire META

Voyez le [webinaire enregistré le 6 octobre 2021](https://docs.alliancecan.ca/mediawiki/index.php?title=META-Farm/fr&oldid=174697).


## Démarrage rapide

Si vous débutez avec META, suivez les étapes ci-dessous. Il est toutefois fortement recommandé de lire cette page au complet.

1.  Connectez-vous à une grappe.
2.  Chargez le module `meta-farm`.
    ```bash
    $ module load meta-farm
    ```
3.  Choisissez un nom pour le répertoire du groupe de cas, par exemple `Farm_name` et créez-le avec
    ```bash
    $ farm_init.run  Farm_name
    ```
    Cette commande créera également quelques fichiers importants dans le répertoire, dont certains devront être personnalisés.
4.  Copiez vos fichiers exécutables et vos fichiers d'entrée dans le répertoire du groupe de cas. (Vous pouvez ignorer cette étape si vous prévoyez utiliser des chemins complets partout.)
5.  Modifiez le fichier `table.dat` dans le répertoire. Il s'agit d'un fichier texte décrivant un cas (un calcul distinct) par ligne. Voyez des exemples dans les sections suivantes :
    *   [single_case.sh Exemple : fichiers d'entrée numérotés (avancé)](#single_casesh-exemple-fichiers-dentre-numrots-avanc)
    *   [single_case.sh Exemple : fichier d'entrée doit avoir le même nom (avancé)](#single_casesh-exemple-fichier-dentre-doit-avoir-le-mme-nom-avanc)
    *   [Accéder à chaque paramètre d'un cas (avancé)](#accdr-chaque-paramtre-dun-cas-avanc)
6.  Modifiez le script `single_case.sh` au besoin. Souvent, aucune modification n'est requise; voir les sections suivantes :
    *   [single_case.sh](#single_casesh)
    *   [STATUS et traitement des erreurs](#status-et-traitement-des-erreurs)
    *   [single_case.sh Exemple : fichier d'entrée doit avoir le même nom (avancé)](#single_casesh-exemple-fichier-dentre-doit-avoir-le-mme-nom-avanc)
    *   [Accéder à chaque paramètre d'un cas (avancé)](#accdr-chaque-paramtre-dun-cas-avanc)
7.  Modifiez le fichier `job_script.sh` selon vos besoins, tel que décrit dans [job_script.sh](#job_script.sh), ci-dessous. En particulier, utilisez un nom de compte de calcul valide et indiquez une durée d’exécution appropriée. Pour plus d'information sur le temps d’exécution, voir [Estimation du temps d'exécution et du nombre de métatâches](#estimation-du-temps-dexcution-et-du-nombre-de-mtatches).
8.  Dans le répertoire des cas, lancez
    ```bash
    $ submit.run -1
    ```
    pour le mode SIMPLE (un cas par tâche) ou
    ```bash
    $ submit.run N
    ```
    pour le mode META, où N est le nombre de métatâches à utiliser. La valeur de N doit être de beaucoup inférieure au nombre total de cas.
9.  Pour faire exécuter un autre groupe de cas en même temps que le premier, lancez de nouveau `farm_init.run` avec un nom de groupe différent et personnalisez les fichiers `single_case.sh` et `job_script.sh` à l’intérieur du répertoire; créez ensuite un nouveau fichier `table.dat` au même endroit. Copiez l’exécutable et tous les fichiers d’entrée nécessaires. Vous pouvez maintenant lancer la commande `submit.run` dans le deuxième répertoire de cas pour soumettre le deuxième groupe de cas.


## Liste des commandes

*   `farm_init.run` : initialise un groupe de cas; voir [Démarrage rapide](#dmarrage-rapide), ci-dessus.
*   `submit.run` : soumet le groupe de cas à l’ordonnanceur; voir [submit.run](#submitrun), ci-dessous.
*   `resubmit.run` : soumettre comme nouveau groupe de cas tous les traitements qui ont échoué ou qui n’ont jamais été exécutés; voir [Resoumettre les cas qui ont échoué](#resoumettre-les-cas-qui-ont-chou) ci-dessous.
*   `list.run` : liste toutes les tâches et leur état actuel.
*   `query.run` : fournit un sommaire de l’état du groupe de cas avec le nombre de tâches dans la queue, en cours d’exécution et terminées. Cette commande est plus pratique que `list.run` quand il y a un grand nombre de tâches. La commande fournit aussi de l’information sur la progression générale et celle de l’exécution en cours, c’est-à-dire le nombre de cas traités par rapport au nombre total de cas.
*   `kill.run` : interrompt toutes les tâches en cours et annule celles dans la file d’attente.
*   `prune.run` : annule uniquement les tâches dans la file d’attente.
*   `Status.run` (le S au début est en majuscule) : liste les états de tous les cas traités. L’option `-f`, fait afficher à la toute fin les lignes d’état non nulles, le cas échéant.
*   `clean.run` : supprime tous les fichiers dans le répertoire du groupe de cas ainsi que les sous-répertoires s’il y a lieu, à l’exception des fichiers `job_script.sh`, `single_case.sh`, `final.sh`, `resubmit_script.sh`, `config.h` et `table.dat`. Tous les fichiers dans le répertoire `/home/$USER/tmp` qui sont associés au groupe de cas sont aussi supprimés. Utilisez ce script avec beaucoup de prudence.

Toutes ces commandes (à l'exception de `farm_init.run` elle-même) doivent être exécutées dans un répertoire de groupe de cas créé par `farm_init.run`.


## Mode SIMPLE pour un petit nombre de cas

Rappelons qu'une seule exécution de votre code est un *cas* et qu’une invocation de l'ordonnanceur est une *tâche*. Si :

*   le nombre total de cas est assez bas, disons moins de 500 et que
*   chaque cas prend au moins 20 minutes,

il est raisonnable de dédier une tâche distincte à chacun des cas en utilisant le mode SIMPLE. Sinon, vous devriez utiliser le mode META pour gérer de nombreux cas par tâche; voir [Mode META pour un grand nombre de cas](#mode-meta-pour-un-grand-nombre-de-cas), ci-dessous.

Les trois scripts essentiels sont la commande `submit.run` et deux scripts personnalisables `single_case.sh` et `job_script.sh`.


### submit.run

Remarque : La présente section est valide pour les deux modes.

Un argument de cette commande doit être spécifié, soit `N` qui représente le nombre de tâches à soumettre.

```bash
$ submit.run N [-auto] [optional_sbatch_arguments]
```

Avec `N` = -1, vous demandez le mode SIMPLE (pour soumettre autant de tâches qu'il y a de lignes dans le fichier `table.dat`). Si `N` est un entier positif, vous demandez le mode META (pour soumettre une tâche avec plusieurs cas), `N` étant le nombre de métatâches demandées. Toute autre valeur de `N` est une erreur.

Si l’option `-auto` est présente, la soumission se refera automatiquement à la fin, plus d'une fois si nécessaire, jusqu'à ce que tous les cas dans `table.dat` aient été traités. Cette fonction est décrite dans [Resoumettre automatiquement les cas qui ont échoué](#resoumettre-automatiquement-les-cas-qui-ont-chou).

Si un fichier nommé `final.sh` est présent dans le répertoire du groupe de cas, `submit.run` le traitera comme un script de tâche pour le post-traitement et il sera lancé automatiquement une fois que tous les cas de `table.dat` auront été traités avec succès; voir [Exécuter automatiquement une tâche de post-traitement](#excuterautmatiquement-une-tche-de-post-traitement).

Si vous fournissez d'autres arguments, ils seront transmis à la commande `sbatch` de l’ordonnanceur pour le lancement de toutes les métatâches pour ce groupe de cas.


### single_case.sh

Remarque : La présente section est valide pour les deux modes.

Le script `single_case.sh` lit une ligne du fichier `table.dat`, l’analyse, puis utilise le contenu de la ligne pour lancer votre code pour un des cas. Vous pouvez adapter `single_case.sh` à vos besoins.

La version de `single_case.sh` fournie par `farm_init.run` traite chaque ligne de `table.dat` comme étant une commande littérale et l’exécute dans son propre répertoire `RUNyyy` où `yyy` représente le numéro du cas. Voici la partie pertinente de `single_case.sh` :

```bash
...
# ++++++++++++++++++++++  Modifiez le code selon vos besoins.  ++++++++++++++++++++++++
#  Dans cet exemple,
#  $ID est l'identifiant du cas dans la table d'origine (peut fournir une source unique pour le code, etc.),
#  $COMM est la ligne qui correspond à l'$ID du cas dans la table d'origine, sans le champ ID,
#  $METAJOB_ID est l'identifiant de la tâche pour la métatâche en cours (utile pour créer des fichiers par tâche).
mkdir -p RUN$ID
cd RUN$ID
echo "Case $ID :"
# Exécute la commande (une ligne dans table.dat).
# Peut utiliser plus qu'une commande pour l'interpréteur (séparées par le deux-points) sur une même ligne.
eval "$COMM"
# État à la sortie du code
STATUS=$?
cd ..
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
...
```

Par conséquent, si `single_case.sh` n’est pas modifié, chaque ligne de `table.dat` doit contenir une commande complète; il peut s'agir d'une commande composée, c'est-à-dire plusieurs commandes séparées par des points-virgules (;).

En règle générale, le fichier `table.dat` contiendra une liste de commandes identiques différenciées uniquement par leurs arguments, mais ce n'est pas obligatoire. Tout énoncé exécutable peut se trouver dans `table.dat` qui pourrait ressembler à ceci :

```
/home/user/bin/code1  1.0  10  2.1
 cp -f ~/input_dir/input1 .; ~/code_dir/code 
 ./code2 < IC.2
```

Si vous voulez exécuter la même commande pour chacun des cas et ne voulez pas avoir à la répéter à chacune des lignes de `table.dat`, vous pouvez modifier `single_case.sh` pour inclure la commande commune, puis modifier `table.dat` pour qu’il contienne uniquement les arguments ou/et des redirections pour chaque cas.

Dans l’exemple suivant, `single_case.sh` a été modifié. La commande `/path/to/your/code` est ajoutée, le contenu de `table.dat` sert d’arguments à la commande et l’argument `$ID` est ajouté pour le numéro de cas.


#### single_case.sh

```bash
...
# ++++++++++++++++++++++  Modifiez le code selon vos besoins.  ++++++++++++++++++++++++
# Dans cet exemple, $ID (numéro du cas) est utilisé comme source pour le traitement selon la méthode Monte-Carlo.
/path/to/your/code -par $COMM -seed $ID
STATUS=$?
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
...
```

#### table.dat

```
12 .56
21 .35
...
```

**Remarque 1** : Si votre code n’a pas besoin de lire d’arguments dans le fichier `table.dat`, il faut quand même générer ce fichier avec le nombre de lignes égal au nombre de cas à traiter. Tout ce qui importe dans le contenu de `table.dat` est le nombre total de lignes. Dans notre exemple, la commande simplifiée serait alors `/path/to/your/code -seed $ID`

**Remarque 2** : Il n’est pas nécessaire d’inclure les numéros de ligne au début de chaque ligne de `table.dat`. Si le script `submit.run` ne les trouve pas, il modifiera `table.dat` pour y ajouter les numéros de lignes.


### STATUS et traitement des erreurs

À quoi sert `STATUS` dans `single_case.sh` ? La valeur de cette variable devrait être de 0 si votre cas a été traité correctement, autrement sa valeur sera positive (plus grande que 0). Ceci est très important, car `resubmit.run` l’utilise pour identifier les cas qui ont échoué et qui doivent être traités de nouveau. Dans la version de `single_case.sh` que nous fournissons, `STATUS` est le code de sortie de votre programme. Ceci ne résout pas tous les problèmes parce que certains programmes produisent un code de sortie de 0 même si tout ne s’est pas bien déroulé. Vous pouvez changer la définition de `STATUS` en modifiant `single_case.sh`.

Par exemple, si votre code doit créer le fichier `out.dat` à la fin de chaque cas, effectuez un test pour savoir si le fichier existe et changez la valeur de `STATUS` en conséquence. Dans l’exemple suivant, la valeur de `$STATUS` sera positive si le code de sortie du programme est positif ou si `out.dat` n’existe pas ou est vide.

```bash
STATUS=$?
if test ! -s out.dat
then
STATUS=1
fi
```


### job_script.sh

Remarque : La présente section est valide pour les deux modes.

Ce fichier est le script qui sera soumis à l’ordonnanceur pour toutes les métatâches du groupe de cas. La version crée par défaut par `farm_init.run` est :

```bash
#!/bin/bash
# Indiquez les arguments sbatch pour toutes les tâches du groupe de cas.
# Doit contenir l'option pour la durée d'exécution (soit -t ou --time).
#SBATCH -t 0-00:10
#SBATCH --mem=4G
#SBATCH -A Nom_de_votre_compte
# Ne modifiez pas la ligne suivante.
task.run
```

Vous devez configurer le nom du compte (option `-A`) et la durée d’exécution (option `-t`) de la métatâche. En mode SIMPLE, indiquez une durée d’exécution un peu plus longue que celle prévue pour le cas individuel qui est de plus longue durée.

**Important** : Le script `job_script.sh` doit contenir une option pour la durée d’exécution, soit `-t` ou `--time`. Ceci ne peut pas être passé à `sbatch` comme argument optionnel pour `submit.run`.

Le problème suivant peut se produire : Une métatâche peut avoir été allouée à un nœud défectueux, ce qui fait immédiatement échouer le programme. Par exemple, votre programme pourrait nécessiter un GPU, mais celui qui vous est assigné fonctionne mal ou encore le système de fichiers `/project` n’est pas disponible. Tout problème avec un nœud devrait être signalé à l’équipe de soutien technique. Si ceci se produit, une seule métatâche incorrecte peut rapidement parcourir `table.dat` et faire échouer tout le groupe de cas. Pour prévenir ce problème, ajoutez des tests à `job_script.sh` avant la ligne `task.run`. Par exemple, la modification suivante teste la présence d’un GPU NVidia et force la fin d’une métatâche avant que des cas échouent :

```bash
nvidia-smi >/dev/null
retVal=$?
if [ $retVal -ne 0 ]
; then
exit 1
fi
task.run
```

L’utilitaire `gpu_test` fait un travail équivalent. Sur Graham, Cedar ou Béluga, copiez-le dans votre répertoire `~/bin`.

```bash
cp ~syam/bin/gpu_test ~/bin
```

Un mécanisme intégré à META tente de détecter de tels problèmes pour interrompre une métatâche qui passerait trop rapidement sur les cas. Les paramètres `N_failed_max` et `dt_failed` sont définis dans le fichier `config.h`. Le mécanisme de protection se déclenche quand les `$N_failed_max` premiers cas sont d’une durée inférieure à `$dt_failed` secondes. Les valeurs par défaut sont 5 et 5; ainsi, la métatâche s’arrête par défaut si les 5 premiers cas sont terminés en moins de 5 secondes. Si le mécanisme se déclenche parce que certains de vos cas ont une durée d’exécution inférieure à `$dt_failed`, diminuez la valeur de `dt_failed` dans `config.h`.


### Fichiers de sortie

Remarque : La présente section est valide pour les deux modes.

Une fois qu'une ou plusieurs métatâches sont en cours d'exécution, les fichiers suivants sont créés dans le répertoire du groupe de cas :

*   `OUTPUT/slurm-$JOBID.out`, un fichier par métatâche contenant la sortie standard,
*   `STATUSES/status.$JOBID`, un fichier par métatâche contenant l'état de chaque cas traité.

Dans les deux cas, `$JOBID` est l’identifiant de la tâche pour la métatâche correspondante.

Le répertoire `MISC` est également créé dans le répertoire racine du groupe de cas.

De plus, chaque fois que `submit.run` est exécuté, un sous-répertoire unique est créé dans `/home/$USER/tmp`. Dans ce sous-répertoire, certains petits fichiers de travail seront créés, tels que les fichiers utilisés par `lockfile` pour protéger certaines opérations critiques à l'intérieur des tâches. Les noms de ces sous-répertoires contiennent `$NODE.$PID` où `$NODE` est le nom du nœud actuel qui est généralement un nœud de connexion et `$PID`, l’identifiant unique du processus pour le script.

Ce sous-répertoire peut être supprimé une fois que le traitement complet du groupe de cas est terminé. Si vous lancez `clean.run`, le sous-répertoire sera automatiquement supprimé, mais prenez garde parce que cette commande supprime aussi tous les résultats obtenus.


### Resoumettre les cas qui ont échoué

Remarque : La présente section est valide pour les deux modes.

La commande `resubmit.run` utilise les mêmes arguments que `submit.run`.

```bash
$ resubmit.run N [-auto] [optional_sbatch_arguments]
```

La commande `resubmit.run` :

*   analyse tous les fichiers `status.*` (voir [Fichiers de sortie](#fichiers-de-sortie), ci-dessus);
*   détermine les cas qui ont échoué et ceux qui n'ont jamais été exécutés pour une raison quelconque, par exemple, à cause de la limite de temps d'exécution des métatâches;
*   crée ou recrée un fichier secondaire `table.dat_` qui répertorie uniquement les cas qui doivent encore être exécutés;
*   lance un nouveau groupe de cas pour ces cas.

Vous ne pouvez pas exécuter `resubmit.run` tant que toutes les tâches de l'exécution d'origine ne sont pas terminées ou annulées.

Si certains cas échouent ou ne s'exécutent toujours pas, vous pouvez soumettre le groupe de cas à nouveau, autant de fois que nécessaire. Bien sûr, si certains cas échouent à plusieurs reprises, il doit y avoir un problème avec le programme que vous exécutez ou avec son entrée. Dans ce cas, vous pouvez utiliser la commande `Status.run` (le S est en majuscule) qui affiche l’état de tous les cas traités. Avec l'option `-f`, `Status.run` triera le résultat en fonction de l’état de la sortie en affichant les cas avec un état différent de zéro dans le bas pour mieux les repérer.

De la même manière que pour `submit.run`, si l’option `-auto` est présente, le groupe de cas sera automatiquement soumis de nouveau à la fin, plus d'une fois si nécessaire (voir [Resoumettre automatiquement les cas qui ont échoué](#resoumettre-automatiquement-les-cas-qui-ont-chou)).


## Mode META pour un grand nombre de cas

Le mode SIMPLE (un cas par tâche) fonctionne bien lorsque le nombre de cas est assez petit (<500). Lorsque le nombre de cas est largement supérieur à 500, les problèmes suivants peuvent survenir :

*   Chaque grappe a une limite quant au nombre de tâches que vous pouvez avoir en même temps; pour Graham par exemple, la limite est de 1000.
*   Avec un très grand nombre de cas, chaque traitement de cas est généralement court. Si un cas s'exécute pendant <20 min, les cycles CPU peuvent être gaspillés par de l’ordonnancement non nécessaire.

Le mode META est la solution à ces problèmes. Au lieu de soumettre une tâche distincte pour chaque cas, un plus petit nombre de métatâches sont soumises, chacune traitant plusieurs cas. Pour activer le mode META, le premier argument de `submit.run` doit être le nombre souhaité de métatâches, qui doit être un nombre assez petit, soit beaucoup plus petit que le nombre de cas à traiter, par exemple :

```bash
$ submit.run 32
```

Étant donné que chaque cas peut prendre un temps de traitement différent, le mode META utilise un schéma d'équilibrage dynamique de la charge de travail. Voici comment le mode META est implémenté :

*   Chaque tâche exécute le même script `task.run`. À l'intérieur de ce script, il y a une boucle `while` pour les cas. Chaque itération de la boucle doit passer par une zone critique (c'est-à-dire qu'une seule tâche à la fois peut effectuer certaines opérations), où elle obtient le cas suivant à traiter dans `table.dat`. Ensuite, le script `single_case.sh` (voir [single_case.sh](#single_casesh)) est exécuté une fois pour ce nouveau cas, ce qui appelle ensuite votre code.

Cette approche crée un équilibrage dynamique de la charge de travail réalisé par toutes les métatâches actives d’un même groupe de cas. L'algorithme est illustré par le schéma ci-dessous :

[This animation from the META webinar](https://docs.alliancecan.ca/mediawiki/index.php?title=META-Farm/fr&oldid=174697) illustrates its operation.

L'équilibrage dynamique de la charge de travail a pour résultat que toutes les métatâches se terminent à peu près au même moment, quelle que soit la différence des durées d'exécution pour les cas individuels, quelle que soit la vitesse des processeurs des différents nœuds et quel que soit le moment où chacune des métatâches démarre. De plus, toutes les métatâches n'ont pas besoin de commencer à s'exécuter pour que tous les cas soient traités. Enfin, si une métatâche est interrompue en plein calcul (par exemple si un nœud tombe en panne), c’est au plus un cas qui sera perdu. Ceci peut facilement être repris avec `resubmit.run` (voir [Resoumettre les cas qui ont échoué](#resoumettre-les-cas-qui-ont-chou)).

En résumé, toutes les métatâches demandées ne s'exécuteront pas nécessairement; cela dépend de la disponibilité de la grappe. Mais comme décrit ci-dessus, vous obtiendrez éventuellement tous vos résultats en mode META, quel que soit le nombre de métatâches exécutées, même si vous devrez peut-être utiliser `resubmit.run` pour terminer un groupe de cas en particulier.


## Estimation du temps d'exécution et du nombre de métatâches

Comment peut-on déterminer le nombre optimal de métatâches et le temps d'exécution à utiliser dans `job_script.sh` ?

Vous devez d'abord déterminer le temps d'exécution moyen pour un cas individuel (une seule ligne dans `table.dat`). Pour ce faire, en supposant que votre programme ne soit pas parallèle, allouez un seul cœur CPU avec `salloc`, puis exécutez `single_case.sh` pour quelques cas différents. Mesurez la durée d'exécution totale et divisez-la par le nombre de cas que vous avez exécutés pour obtenir une estimation de la durée d'exécution moyenne des cas. Cela peut être fait avec une boucle `for`.

```bash
$ N=10; time for (( i=1; i<= $N; i++ )); do ./single_case.sh table.dat $i; done
```

Divisez le temps réel obtenu par `$N` pour obtenir une estimation du temps moyen d’exécution que nous appellerons ici `dt_case`.

Estimez le temps CPU total nécessaire pour traiter le tout en multipliant `dt_case` par le nombre de cas, c'est-à-dire le nombre de lignes dans `table.dat`. Si c'est en secondes CPU, diviser cela par 3600 vous donne le nombre total d'heures CPU. Multipliez cela par quelque chose comme 1,1 ou 1,3 pour avoir une certaine marge de sécurité.

Vous pouvez maintenant faire un choix judicieux pour le temps d'exécution des métatâches et cela déterminera également le nombre de métatâches nécessaires pour traiter le groupe de cas en entier.

La durée d'exécution que vous choisissez doit être nettement supérieure à la durée d'exécution moyenne d'un cas individuel, idéalement par un facteur de 100 ou plus. Il doit certainement être supérieur à la durée d'exécution la plus longue que vous prévoyez pour un cas individuel. En revanche, il ne doit pas être trop grand, soit pas plus de 3 jours. Plus la durée d'exécution d'une tâche est longue, plus elle restera longtemps en file d’attente. Sur les grappes à usage général de l’Alliance, un bon choix serait 12 ou 24 heures en raison des [politiques d’ordonnancement des tâches](https://docs.alliancecan.ca/mediawiki/index.php?title=META-Farm/fr&oldid=174697). Une fois le temps d'exécution choisi, divisez le nombre total d'heures CPU par le temps d'exécution que vous avez choisi (en heures) pour obtenir le nombre requis de métatâches. Arrondissez ce nombre à l'entier supérieur.

Avec ces choix, le temps dans la file d'attente devrait être acceptable, et le débit et l'efficacité devraient être assez élevés.

Prenons un exemple précis. Supposons que vous exécutez la boucle `for` ci-dessus sur un processeur dédié obtenu avec `salloc` et que le résultat indique que le temps réel était de 15m50s, soit 950 secondes. Divisez cela par le nombre de cas servant d’échantillons soit 10, pour trouver que le temps moyen pour un cas individuel est de 95 secondes. Supposons également que le nombre total de cas que vous devez traiter (le nombre de lignes dans `table.dat`) est de 1000. Le temps CPU total nécessaire pour calculer tous vos cas est alors de 95 x 1 000 = 95000 secondes CPU, soit 26,4 heures CPU.

Par mesure de sécurité, multipliez cela par un facteur de 1,2 pour obtenir 31,7 heures CPU. Une durée d'exécution de 3 heures pour vos métatâches fonctionnerait ici et devrait conduire à une période acceptable dans la file d'attente. Modifiez la valeur de `#SBATCH -t` dans `job_script.sh` pour qu'elle soit `3:00:00`. Estimez maintenant le nombre de métatâches dont vous aurez besoin pour traiter tous les cas.

N = 31,7 heures de base / 3 heures = 10,6

ce qui, arrondi au nombre entier suivant, est 11. Ensuite, vous pouvez lancer le groupe de cas en exécutant une fois `submit.run 11`.

Si le nombre de métatâches dans l'analyse est supérieur à 1000, vous disposez d'un groupe de cas de taille particulièrement grande. Le nombre maximum de tâches pouvant être soumis sur Graham et Béluga étant de 1000, vous ne pourrez donc pas exécuter tout le groupe de cas avec une seule soumission. La solution de contournement consiste à utiliser la séquence de commandes suivante. N'oubliez pas que chaque commande ne peut être exécutée qu'après la fin de l'exécution du groupe précédent.

```bash
$ submit.run 1000
$ resubmit.run 1000
$ resubmit.run 1000
...
```

Si cela semble plutôt fastidieux, envisagez plutôt d'utiliser la fonctionnalité avancée pour [resoumettre automatiquement les cas qui ont échoué](#resoumettre-automatiquement-les-cas-qui-ont-chou).


## Quelques précautions

Commencez toujours par un petit test pour vous assurer que tout fonctionne avant de soumettre un grand groupe de cas. Vous pouvez tester des cas individuels en réservant un nœud interactif avec `salloc`, en passant au répertoire du groupe de cas et en exécutant des commandes telles que `./single_case.sh table.dat 1`, `./single_case.sh table.dat 2`, etc.

Si vous avez plus de 10,000 cas, vous devez déployer des efforts supplémentaires pour vous assurer que tout fonctionne aussi efficacement que possible. En particulier, minimisez le nombre de fichiers et/ou de répertoires créés lors de l'exécution. Si possible, faites que votre code poursuive ses écritures à la suite des fichiers existants (un par métatâche; *ne mélangez pas les résultats de différentes métatâches dans un seul fichier de sortie*) plutôt que de créer un fichier séparé pour chaque cas. Évitez de créer un sous-répertoire distinct pour chaque cas. Oui, la création de sous-répertoires séparés pour chaque cas est la configuration par défaut de META, mais ce comportement par défaut a été choisi pour la sécurité et non pour l'efficacité.

L'exemple suivant est optimisé pour un très grand nombre de cas. Il suppose, pour l'exemple :

*   que votre code accepte le nom du fichier de sortie via une option en ligne de commande `-o`,
*   que l'application ouvre le fichier de sortie en mode ajout (`append`), c'est-à-dire que plusieurs exécutions continueront à s'ajouter