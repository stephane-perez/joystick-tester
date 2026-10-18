# Joystick Tester (JOYTEST) — notes pour Claude

Lis ce fichier en entier avant toute modification. Notes techniques et
historique : `docs/fr/NOTES.md`.

## Le projet

Utilitaire Atari (ST, STE, Mega STE, Falcon) qui affiche en direct l'état des
joysticks : ports 0 et 1 (IKBD), port parallèle (adaptateurs 4 joueurs),
ports étendus A et B (manette Jaguar, STE et Falcon). Un seul source,
`src/joytest.s` : français par défaut (`JOYTEST.TOS`), anglais avec
`-DENGLISH` (`JOYTSTEN.TOS`). Sorti d'IK+ Reforged (v1.1.0) sans changement.

Le propriétaire (Stéphane) teste sur **520 STF**, **STE 4 Mo / TOS 1.62**,
**Mega STE / TOS 2.06** et **Falcon030 14 Mo / TOS 4.04**. Ce qu'on ne peut
valider que sur la machine, on le lui demande, avec une liste précise de
choses à vérifier.

## Règles

1. **Français** pour les commentaires et les notes techniques (`docs/fr/`) ;
   `README.md` (anglais) et `README_FR.md` (français) ont le même contenu.
2. `make check` compare les empreintes des deux programmes ; si une sortie
   change volontairement, mettre à jour les MD5 dans le `Makefile`,
   `README.md` et `README_FR.md`.
3. Aucune ROM TOS ni image disque dans le dépôt (le `.gitignore` les exclut).
4. Toujours tester dans Hatari avant de livrer, et dire clairement ce qui n'a
   été vérifié que dans l'émulateur.
5. Une branche par sujet, une demande de fusion (PR) décrite en français ; on
   ne fusionne qu'après le retour de la machine réelle.
6. Étiquettes au format `v1.N.M` ; le proxy git des sessions refuse de les
   pousser : donner la commande à Stéphane.

## Construire et tester

```sh
make          # build/JOYTEST.TOS et build/JOYTSTEN.TOS (vasm construit dans .tools/)
make check
```

Hatari 2.4.1, ROM TOS fournies par Stéphane (hors dépôt, par exemple dans
`../ikplus-local/rom/`) :

- `hatari/run.sh <nom> <machine> <tos> <secondes>` : sans écran, captures dans
  `hatari/out/<nom>/` (variables `HD`, `PRG`, `KEYS`).
- `hatari/runx.sh <nom> <machine> <tos> <secondes> <script>` : Xvfb + xdotool,
  touches en minuscules, pour passer par l'émulation des joysticks
  (`CFG=…/joyall.cfg` : ports 0 et 1 + deux prises du port parallèle ;
  `joyste.cfg` : manette Jaguar sur le port A). Lignes du script :
  `t down|up|tap touche`. Sur STF, JOYTEST est à l'écran vers 12 s.

## Pièges déjà rencontrés

- **Hatari est plus permissif que la machine** : il ignore le bit 7 du
  registre 7 du PSG (sens du port parallèle) et fige la valeur lue au moment
  de la sélection d'un registre (lire deux fois).
- Le TOS passe à `joyvec` un tampon de 3 octets (en-tête, joystick 0, joystick 1).
- Lire `$FF9202` sur une machine sans ports étendus (STF, Mega STE) peut
  provoquer une erreur de bus.
- Sur la machine réelle, une lecture de `$FF9202` masque les boutons dans la
  lecture suivante de `$FF9200` : lire `$FF9200` juste après la sélection.
  Hatari ne le reproduit pas.
