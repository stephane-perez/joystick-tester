# Joystick Tester (JOYTEST) — notes pour Claude

Lis ce fichier en entier avant toute modification. Notes techniques et
historique : `docs/fr/NOTES.md`.

## Le projet

Utilitaire Atari (ST, STE, Mega STE, Falcon) qui affiche en direct l'état des
joysticks : ports 0 et 1 (IKBD), port parallèle (adaptateurs 4 joueurs),
ports étendus A et B (manette Jaguar, STE et Falcon). Un seul source,
`src/joytest.s` (assembleur 68000, syntaxe Motorola, vasm) : français par
défaut (`JOYTEST.TOS`), anglais avec `-DENGLISH` (`JOYTSTEN.TOS`). Sorti
d'IK+ Reforged (v1.1.0) sans changement ; ce dépôt-là
(`stephane-perez/ik-plus-reforged`) contient l'historique d'origine.

Le propriétaire (Stéphane) teste sur **520 STF**, **STE 4 Mo / TOS 1.62**,
**Mega STE / TOS 2.06** et **Falcon030 14 Mo / TOS 4.04**. Ce qu'on ne peut
valider que sur la machine, on le lui demande, avec une liste précise de
choses à vérifier.

## Règles

1. **Français** pour les commentaires et les notes techniques (`docs/fr/`) ;
   `README.md` (anglais) et `README_FR.md` (français) ont le même contenu.
   Les textes affichés par le programme sont en ASCII (pas d'accents) et
   tiennent en 40 colonnes (basse résolution).
2. `make check` compare les empreintes des deux programmes ; si une sortie
   change volontairement, mettre à jour les MD5 dans le `Makefile`,
   `README.md` et `README_FR.md`.
3. Aucune ROM TOS ni image disque dans le dépôt (le `.gitignore` les exclut).
4. Toujours tester dans Hatari avant de livrer, et dire clairement ce qui n'a
   été vérifié que dans l'émulateur (et avec quel TOS : vrai TOS ou EmuTOS).
5. Une branche par sujet, partant de `main` (branche par défaut) ; Claude
   ouvre lui-même la demande de fusion (PR), décrite en français, avec une
   section « À vérifier sur machine réelle ». On ne fusionne qu'après le
   retour de la machine réelle ; c'est Stéphane qui fusionne.
6. Étiquettes au format `v1.N.M`, posées sur `main` **après** la fusion ; le
   proxy git des sessions refuse de les pousser : donner la commande à
   Stéphane (`git checkout main && git pull && git tag v1.N.M && git push
   origin v1.N.M`). Avant de proposer un numéro, regarder les étiquettes
   existantes (`git fetch --tags && git tag`).
7. Toute nouvelle connaissance utile (piège matériel, astuce Hatari) va dans
   `docs/fr/NOTES.md`, et toute règle de travail dans ce fichier.

## Intégration continue

`.github/workflows/build.yml` : à chaque envoi, construit les deux programmes,
lance `make check` et les publie comme artefact `joystick-tester` (onglet
Actions). Une étiquette `v*` publie en plus une version (release) GitHub avec
les deux `.TOS`. Un `make check` en échec fait échouer la CI : penser aux MD5.

## Construire et tester

```sh
make          # build/JOYTEST.TOS et build/JOYTSTEN.TOS (vasm construit dans .tools/)
make check
```

Session dans le nuage (conteneur neuf, rien d'installé) :

```sh
apt-get update -qq && apt-get install -y -qq hatari xvfb xdotool   # Hatari 2.4.1
```

ROM TOS : fournies par Stéphane, hors dépôt (chez lui dans
`../ikplus-local/rom/`) ; elles ne sont **pas** dans les sessions dans le
nuage. Sans elles, tester avec **EmuTOS** 1.3 (libre, hors dépôt aussi),
dans le dossier temporaire de la session :

```sh
curl -sSL -o emutos.zip https://sourceforge.net/projects/emutos/files/emutos/1.3/emutos-512k-1.3.zip/download
unzip -q emutos.zip    # puis --tos …/emutos-512k-1.3/etos512us.img (ou etos512fr.img)
```

La version 512 Ko convient à toutes les machines et pose le bon cookie
`_MCH`. Ce n'est pas le TOS d'origine : le dire dans la PR.

- `hatari/run.sh <nom> <machine> <tos> <secondes>` : sans écran, une capture
  par seconde dans `hatari/out/<nom>/` (variables `HD`, `PRG`, `KEYS`).
  Les touches envoyées ainsi ne passent pas par l'émulation des joysticks.
- `hatari/runx.sh <nom> <machine> <tos> <secondes> <script>` : Xvfb + xdotool,
  touches en minuscules, pour passer par l'émulation des joysticks
  (`CFG=$PWD/hatari/joyall.cfg` : ports 0 et 1 + deux prises du port
  parallèle ; `joyste.cfg` : ports 0 et 1 + manette Jaguar sur le port A,
  touches T F G H + R). `CFG` doit être un chemin absolu. Lignes du script :
  `t down|up|tap touche`. JOYTEST est à l'écran vers 12 s sur STF avec un vrai
  TOS, vers 8 s sur STE avec EmuTOS.
- Machines Hatari : `st`, `megast`, `ste`, `megaste`, `tt`, `falcon`.
- Si Hatari plante (rare, vu une fois au démarrage), le script tourne sans
  fin : le lancer sous `timeout` (par exemple `timeout 60 hatari/run.sh …`)
  et relancer.
- Regarder les captures (`.png`) pour vérifier l'affichage ; `hatari/out/`
  n'est pas suivi par git.

## Pièges déjà rencontrés

- **Hatari est plus permissif que la machine** : il ignore le bit 7 du
  registre 7 du PSG (sens du port parallèle) et fige la valeur lue au moment
  de la sélection d'un registre (lire deux fois).
- Sans joystick émulé sur le port parallèle (par exemple avec `joyste.cfg`),
  Hatari lit les lignes D0–D7 à 0 : « Incoherent » sur les lignes
  « Parallele », c'est normal.
- Le TOS passe à `joyvec` un tampon de 3 octets (en-tête, joystick 0, joystick 1).
- Lire `$FF9202` sur une machine sans ports étendus (STF, Mega STE) peut
  provoquer une erreur de bus. Le Mega STE a pourtant un `_MCH` proche du
  STE (`$00010010`) : comparer la valeur exacte.
- Sur la machine réelle, une lecture de `$FF9202` masque les boutons dans la
  lecture suivante de `$FF9200` : lire `$FF9200` juste après la sélection.
  Hatari ne le reproduit pas.
- Les appels GEMDOS/BIOS/XBIOS écrasent d0-d2 et a0-a2.
