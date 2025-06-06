# Support technique

## Demandes d'assistance

Avant de nous contacter, vérifiez d'abord la page sur [l'état des grappes](link-to-cluster-status-page) ainsi que celle sur [les problèmes connus](link-to-known-issues-page) pour savoir si votre problème a déjà été rapporté à notre équipe technique. Consultez aussi notre site wiki qui offre souvent des solutions pratiques. Si vous avez toujours besoin de nous contacter, utilisez les adresses de courriel listées ci-dessous.

Assurez-vous que l'adresse courriel que vous utilisez est enregistrée sous votre [compte](link-to-account-page). De cette façon, notre système de billets d'assistance peut automatiquement vous reconnaître.

Énoncez précisément et clairement votre problème ou votre question (voir [l'exemple d'une requête de soutien technique](#exemple-dune-requête-de-soutien-technique)).

Dans la ligne d'objet de votre message, évitez les énoncés vagues comme "J'ai un problème" ou "Ça ne fonctionne pas"; le temps de résolution sera plus long car nous devrons vous contacter pour avoir toute l'information. Assurez-vous d'inclure tous les [renseignements à fournir avec votre requête](#renseignements-à-fournir-avec-une-requête).

Dans la ligne d'objet de votre message, indiquez le nom de la grappe et une courte description du problème, par exemple "Erreurs pour la tâche 123456 sur la grappe Cedar"; nous pourrons ainsi cerner plus rapidement le problème.

Si vous nous contactez à partir d'une adresse de courriel que nous connaissons, notre système de requêtes d'assistance vous identifiera immédiatement comme utilisateur. Assurez-vous de fournir toutes les adresses de courriel que vous utilisez dans le profil de votre compte d'utilisateur dans notre base de données.

Créez une nouvelle requête pour chaque problème qui n'est pas relié à une requête antérieure.


## Adresses de courriel

Veuillez choisir l'adresse qui correspond le mieux à votre besoin :

*   `comptes@tech.alliancecan.ca` -- pour des questions sur les comptes
*   `renouvellements@tech.alliancecan.ca` -- pour des questions sur le renouvellement des comptes
*   `globus@tech.alliancecan.ca` -- pour des questions sur les services de transfert de fichiers Globus
*   `nuage@tech.alliancecan.ca` -- pour des questions sur comment utiliser nos ressources infonuagiques
*   `allocations@tech.alliancecan.ca` -- pour des questions sur le Concours pour l’allocation de ressources (CAR)
*   `support@tech.alliancecan.ca` -- pour toute autre question


## Renseignements à fournir avec une requête

Afin de nous aider à mieux vous servir, veuillez inclure les renseignements suivants dans votre demande :

*   le nom de la grappe
*   le numéro de la tâche
*   le script de soumission de la tâche : donnez le chemin complet pour le script; copiez-collez le script dans votre message; ou envoyer le script en pièce jointe
*   tous les fichiers de sortie contenant des erreurs : donnez le chemin complet pour le ou les fichiers; copiez-collez le ou les fichiers dans votre message; ou envoyer le ou les fichiers en pièce jointe
*   les commandes actives au moment où le problème est survenu
*   le nom et la version du logiciel que vous vouliez utiliser
*   la date et l'heure auxquelles le problème est survenu

Évitez de joindre des captures d'écran ou autres fichiers de graphiques si ce n'est pas nécessaire; la version en texte brut est habituellement plus utile (commandes, scripts, etc.); pour plus d'information, voir [Copier-Coller](link-to-copy-paste-guide).

Énoncez clairement vos attentes dans votre courriel en mentionnant si nous devons accéder à vos données, copier ou modifier vos fichiers, examiner et possiblement modifier votre compte, etc. Par exemple, plutôt que de joindre des fichiers à votre courriel, vous pouvez nous indiquer où ils se trouvent dans votre compte et nous accorder la permission d'y accéder (si nous avons déjà accès à vos fichiers via CCDB, il n'est pas nécessaire de nous accorder à nouveau la permission d'accès).


## Points importants

*   N'envoyez jamais un mot de passe.
*   Les fichiers joints ne doivent pas dépasser 40 Mo au total.


## <a name="exemple-dune-requête-de-soutien-technique"></a>Exemple d'une requête de soutien technique

Dest.: `support@tech.alliancecan.ca`

Objet: Erreurs pour la tâche 123456 sur la grappe Cedar

Bonjour,

Mon nom est Alice, identifiant `asmith`. Ce matin à 10h HAE, j'ai soumis la tâche 123456 sur la grappe Cedar. Le script pour la tâche se trouve dans `<tt>chemin pour le script</tt>`. Le script n'a pas été modifié depuis que j'ai soumis cette tâche; comme il n'est pas très long, je l'ai copié ci-dessous :

```bash
#!/bin/bash
#SBATCH --account=def-asmith-ab
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=00:05:00
{ time mpiexec -n 1 ./sample1 ; } 2>out.time
```

J'avais chargé les modules suivants :

```
[asmith@cedar5]$ module list
Currently Loaded Modules:
1) nixpkgs/16.09 (S) 5) intel/2016.4 (t)
2) icc/.2016.4.258 (H) 6) imkl/11.3.4.258 (math)
3) gcccore/.5.4.0 (H) 7) openmpi/2.1.1 (m)
4) ifort/.2016.4.258 (H) 8) StdEnv/2016.4 (S)
```

La tâche a été exécutée rapidement et les fichiers `exemple-123456.out` et `exemple-123456.err` ont été générés. Il n'y avait pas de contenu dans le fichier `exemple-123456.out`, mais il y avait un message dans `exemple-123456.err`

```
[asmith@cedar5 scheduling]$ cat myjob-123456.err
slurmstepd: error: *** JOB 123456 ON cdr692 CANCELLED AT 2018-09-06T15:19:16 DUE TO TIME LIMIT ***
```

Comment puis-je résoudre ce problème?


## Permettre l'accès à votre compte

Vous avez peut-être consenti à nous accorder l'accès à vos fichiers par l'entente disponible dans la base de données CCDB ([Mon compte->Ententes](link-to-ccdb-agreements)). Si ce n'est pas le cas, veuillez spécifier dans votre requête que vous nous en accordez l'accès. Ainsi, vous pouvez indiquer où se trouvent les fichiers plutôt que de les attacher à votre courriel.

Remember to replace the bracketed placeholders like `[link-to-cluster-status-page]` with the actual links.
