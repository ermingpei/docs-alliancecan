# CMake

(pour *cross-platform make*) est un outil de compilation libre multiplateforme et multilangage. Alors que *Autotools* est l'outil traditionnel sous Linux (utilisé entre autres pour tous les projets GNU), plusieurs projets sont passés à CMake au cours des dernières années, et ce pour différentes raisons, entre autres KDE et MySQL. Ceux qui ont éprouvé certaines difficultés à construire leur propre projet avec Autotools trouveront probablement CMake beaucoup plus facile d'utilisation. Selon KDE, les principales raisons pour lesquelles ils sont passés de Autotools à CMake sont que la compilation est beaucoup plus rapide et que les fichiers de construction sont beaucoup plus faciles à écrire.

## Principe de base

CMake fonctionne de la même manière que Autotools et requiert l'exécution d'un script `configure`, suivi d'un `build` avec `make`. Cependant, plutôt qu'appeler `./configure`, on appelle `cmake directory`. Par exemple, si on est dans le répertoire où l'on veut construire l'application, on exécute :

```bash
name@server ~]$ cmake .
```

Ainsi, pour configurer, construire et installer une application ou une bibliothèque, la façon la plus simple est avec :

```bash
name@server ~]$ cmake . && make && make install
```

## Options utiles pour travailler avec les grappes

Nos grappes sont configurées de telle sorte qu'à la compilation d'un nouveau paquet logiciel, l'information est automatiquement ajoutée au binaire résultant afin qu'il puisse trouver les bibliothèques desquelles il dépend; le mécanisme utilisé est `RUNPATH` (ou `RPATH`). Certains paquets qui utilisent CMake font de même avec une fonctionnalité offerte par CMake. Des conflits sont parfois créés quand les deux sont utilisés en même temps; pour éviter ceci, ajouter l'option `-DCMAKE_SKIP_INSTALL_RPATH=ON` en ligne de commande. Aussi, les bibliothèques de nos grappes sont installées dans des endroits non standards et il est difficile pour CMake de les trouver; il peut être utile d'ajouter sur la ligne de commande l'option `-DCMAKE_SYSTEM_PREFIX_PATH=$EBROOTGENTOO`

Parfois, même cela n'est pas suffisant et vous pourriez devoir ajouter des options plus spécifiques aux bibliothèques utilisées par votre paquet logiciel, par exemple :

```bash
-DCURL_LIBRARY=$EBROOTGENTOO/lib/libcurl.so -DCURL_INCLUDE_DIR=$EBROOTGENTOO/include
-DPYTHON_EXECUTABLE=$EBROOTPYTHON/bin/python
-DPNG_PNG_INCLUDE_DIR=$EBROOTGENTOO/include -DPNG_LIBRARY=$EBROOTGENTOO/lib/libpng.so
-DJPEG_INCLUDE_DIR=$EBROOTGENTOO/include -DJPEG_LIBRARY=$EBROOTGENTOO/lib/libjpeg.so
-DOPENGL_INCLUDE_DIR=$EBROOTGENTOO/include -DOPENGL_gl_LIBRARY=$EBROOTGENTOO/lib/libGL.so -DOPENGL_glu_LIBRARY=$EBROOTGENTOO/lib/libGLU.so
-DZLIB_ROOT=$EBROOTGENTOO
```

## Personnalisation de la configuration

Tout comme avec Autotools, il est possible de personnaliser la configuration de l'application ou de la bibliothèque. Cela peut se faire par différentes options de la ligne de commande, mais aussi via une interface texte avec la commande `ccmake`.

### Commande `ccmake`

La commande `ccmake` est appelée de la même façon que la commande `cmake`, en indiquant le répertoire à construire. S'il s'agit du répertoire courant, la commande est :

```bash
name@server ~]$ ccmake .
```

Il faut appeler `ccmake` après avoir appelé `cmake` : en général, la commande est :

```bash
name@server ~]$ cmake . && ccmake .
```

`ccmake` affiche d'abord la liste des options définies par le projet. Le résultat est une liste relativement courte semblable à ceci :

```
name@server ~]$ cmake . && ccmake .
Page 1 of 1
ARPACK_LIBRARIES                         ARPACK_LIBRARIES-NOTFOUND
CMAKE_BUILD_TYPE
CMAKE_INSTALL_PREFIX                     /usr/local
CMAKE_OSX_ARCHITECTURES
CMAKE_OSX_DEPLOYMENT_TARGET
CMAKE_OSX_SYSROOT                        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk
GSL_CONFIG                               /opt/local/bin/gsl-config
GSL_CONFIG_PREFER_PATH                   /bin ;; /bin ;
GSL_EXE_LINKER_FLAGS                    -Wl,-rpath,/opt/local/lib
NON_TEMPLATES_DISABLED                   ON
NO_SQUACK_WARNINGS                       ON
PRECOMPILED_TEMPLATES                    ON
USE_GSL_OMP                              OFF
USE_OMP                                  OFF
Press [enter] to edit option
CMake Version 2.8.8
Press [c] to configure
Press [h] for help
Press [q] to quit without generating
Press [t] to toggle advanced mode (Currently Off)
```

Comme indiqué au bas de cette liste, vous pouvez éditer une valeur en appuyant sur la touche `Enter`. Si vous modifiez une valeur, appuyez sur la touche `c` pour tester la configuration avec cette nouvelle valeur. Si la configuration réussit, vous aurez alors l'option `g`, pour générer le `Makefile` avec la nouvelle configuration, ou vous pouvez quitter avec la touche `q`. Le mode avancé est activé avec la touche `t`, ce qui produit une liste beaucoup plus longue de variables qui permettra de configurer l'application avec précision. Voici un exemple de liste d'options :

```
File : ccmake_output.txt
ARPACK_LIBRARIES                         ARPACK_LIBRARIES-NOTFOUND
BLAS_Accelerate_LIBRARY                  /System/Library/Frameworks/Accelerate.framework
BLAS_acml_LIBRARY                        BLAS_acml_LIBRARY-NOTFOUND
BLAS_acml_mp_LIBRARY                     BLAS_acml_mp_LIBRARY-NOTFOUND
BLAS_complib.sgimath_LIBRARY            BLAS_complib.sgimath_LIBRARY-NOTFOUND
BLAS_cxml_LIBRARY                        BLAS_cxml_LIBRARY-NOTFOUND
BLAS_dxml_LIBRARY                        BLAS_dxml_LIBRARY-NOTFOUND
BLAS_essl_LIBRARY                        BLAS_essl_LIBRARY-NOTFOUND
BLAS_f77blas_LIBRARY                     BLAS_f77blas_LIBRARY-NOTFOUND
BLAS_goto2_LIBRARY                       BLAS_goto2_LIBRARY-NOTFOUND
BLAS_scsl_LIBRARY                        BLAS_scsl_LIBRARY-NOTFOUND
BLAS_sgemm_LIBRARY                       BLAS_sgemm_LIBRARY-NOTFOUND
BLAS_sunperf_LIBRARY                     BLAS_sunperf_LIBRARY-NOTFOUND
CMAKE_AR                                 /opt/local/bin/ar
CMAKE_BUILD_TYPE
CMAKE_COLOR_MAKEFILE                     ON
CMAKE_CXX_COMPILER                       /opt/local/bin/c++
CMAKE_CXX_FLAGS
CMAKE_CXX_FLAGS_DEBUG                    -g
CMAKE_CXX_FLAGS_MINSIZEREL               -Os -DNDEBUG
CMAKE_CXX_FLAGS_RELEASE                  -O3 -DNDEBUG
CMAKE_CXX_FLAGS_RELWITHDEBINFO           -O2 -g
CMAKE_C_COMPILER                         /opt/local/bin/gcc
CMAKE_C_FLAGS
CMAKE_C_FLAGS_DEBUG                      -g
CMAKE_C_FLAGS_MINSIZEREL                 -Os -DNDEBUG
CMAKE_C_FLAGS_RELEASE                    -O3 -DNDEBUG
CMAKE_C_FLAGS_RELWITHDEBINFO             -O2 -g
CMAKE_EXE_LINKER_FLAGS
CMAKE_EXE_LINKER_FLAGS_DEBUG
CMAKE_EXE_LINKER_FLAGS_MINSIZE
CMAKE_EXE_LINKER_FLAGS_RELEASE
CMAKE_EXE_LINKER_FLAGS_RELWITH
CMAKE_EXPORT_COMPILE_COMMANDS            OFF
CMAKE_INSTALL_NAME_TOOL                  /opt/local/bin/install_name_tool
CMAKE_INSTALL_PREFIX                     /usr/local
CMAKE_LINKER                              /opt/local/bin/ld
CMAKE_MAKE_PROGRAM                       /Applications/Xcode.app/Contents/Developer/usr/bin/make
CMAKE_MODULE_LINKER_FLAGS
CMAKE_MODULE_LINKER_FLAGS_DEBU
CMAKE_MODULE_LINKER_FLAGS_MINS
CMAKE_MODULE_LINKER_FLAGS_RELE
CMAKE_MODULE_LINKER_FLAGS_RELW
CMAKE_NM                                 /opt/local/bin/nm
CMAKE_OBJCOPY                            CMAKE_OBJCOPY-NOTFOUND
CMAKE_OBJDUMP                            CMAKE_OBJDUMP-NOTFOUND
CMAKE_OSX_ARCHITECTURES
CMAKE_OSX_DEPLOYMENT_TARGET
CMAKE_OSX_SYSROOT                        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk
CMAKE_RANLIB                             /opt/local/bin/ranlib
CMAKE_SHARED_LINKER_FLAGS
CMAKE_SHARED_LINKER_FLAGS_DEBU
CMAKE_SHARED_LINKER_FLAGS_MINS
CMAKE_SHARED_LINKER_FLAGS_RELE
CMAKE_SHARED_LINKER_FLAGS_RELW
CMAKE_SKIP_INSTALL_RPATH                 OFF
CMAKE_SKIP_RPATH                         OFF
CMAKE_STRIP                              /opt/local/bin/strip
CMAKE_USE_RELATIVE_PATHS                 OFF
CMAKE_VERBOSE_MAKEFILE                    OFF
CMAKE_XCODE_SELECT                       /usr/bin/xcode-select
DOXYGEN_DOT_EXECUTABLE                   /usr/local/bin/dot
DOXYGEN_DOT_PATH                         /usr/local/bin
DOXYGEN_EXECUTABLE                       /Applications/Doxygen.app/Contents/Resources/doxygen
GSL_CONFIG                               /opt/local/bin/gsl-config
GSL_CONFIG_PREFER_PATH                   /bin ;; /bin ;
GSL_EXE_LINKER_FLAGS                    -Wl,-rpath,/opt/local/lib
GSL_INCLUDE_DIR                          /opt/local/include
GTEST_INCLUDE_DIR                        /opt/local/include
GTEST_LIBRARY                            /opt/local/lib/libgtest.dylib
GTEST_LIBRARY_DEBUG                      GTEST_LIBRARY_DEBUG-NOTFOUND
GTEST_MAIN_LIBRARY                       /opt/local/lib/libgtest_main.dylib
GTEST_MAIN_LIBRARY_DEBUG                 GTEST_MAIN_LIBRARY_DEBUG-NOTFOUND
LAPACK_Accelerate_LIBRARY                /System/Library/Frameworks/Accelerate.framework
LAPACK_goto2_LIBRARY                     LAPACK_goto2_LIBRARY-NOTFOUND
NON_TEMPLATES_DISABLED                   ON
NO_SQUACK_WARNINGS                       ON
PRECOMPILED_TEMPLATES                    ON
USE_GSL_OMP                              OFF
USE_OMP                                  OFF
```

Remarquez que `ccmake` en mode avancé affiche aussi bien les bibliothèques trouvées que celles qui n'ont pas été trouvées. Si vous voulez utiliser une certaine version de `BLAS` par exemple, vous saurez immédiatement si c'est celle que CMake a trouvée et, le cas échéant, pourrez la modifier.

`ccmake` affiche aussi la liste des options passées aux compilateurs et à l’éditeur de liens, et ce, en fonction du type de construction.

### Options en ligne de commande

Les options affichées par `ccmake` peuvent toutes être modifiées en ligne de commande, avec la syntaxe :

```bash
name@server ~]$ cmake . -DVARIABLE=VALEUR
```

Par exemple, pour spécifier l'emplacement d'installation :

```bash
name@server ~]$ cmake . -DCMAKE_INSTALL_PREFIX=/home/user/mon_repertoire
```

Pour configurer la compilation, vous voudrez possiblement changer les valeurs suivantes :

| Option                | Description                     |
|------------------------|---------------------------------|
| `CMAKE_C_COMPILER`     | Change le compilateur C         |
| `CMAKE_CXX_COMPILER`    | Change le compilateur C++        |
| `CMAKE_LINKER`         | Change l'éditeur de liens        |
| `CMAKE_C_FLAGS`        | Change les options passées au compilateur C |
| `CMAKE_CXX_FLAGS`       | Change les options passées au compilateur C++ |
| `CMAKE_SHARED_LINKER_FLAGS` | Change les options passées à l'éditeur de liens |


La liste complète des options est disponible sur la [page officielle de CMake](https://cmake.org/).

Si vous ne voulez pas vous aventurer dans ces options spécifiques, CMake propose une option plus simple avec `CMAKE_BUILD_TYPE`, qui définit le type de compilation à utiliser. Les valeurs possibles sont :

| Option        | Description                                      |
|----------------|--------------------------------------------------|
| `-`            | aucune valeur                                    |
| `Debug`        | active les options de débogage, désactive les options d'optimisation |
| `Release`      | désactive les options de débogage, active les optimisations typiques |
| `MinSizeRel`   | désactive les options de débogage, active les options d'optimisation en minimisant la taille du binaire |
| `RelWithDebInfo` | active les options de débogage et les optimisations typiques |

Ces différents types de compilation définissent des options de compilateurs qui varient selon le compilateur utilisé; vous n'avez donc pas à vérifier quelles options doivent être utilisées.

## Références

* [Guide d'initiation en français](https://docs.alliancecan.ca/mediawiki/index.php?title=CMake/fr&oldid=138926) qui couvre aussi bien la création de fichiers CMake que la compilation d'un projet déjà fait.
* [Exemple simple (en anglais)](https://cmake.org/cmake/help/latest/guide/tutorial/index.html) sur le site officiel.
* [Tutoriel (en anglais)](https://cmake.org/cmake/help/latest/guide/tutorial/index.html) plutôt complet sur le site officiel.
* [Tutoriel assez complet en français](https://docs.alliancecan.ca/mediawiki/index.php?title=CMake/fr&oldid=138926)


