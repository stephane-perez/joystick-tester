# Joystick Tester (JOYTEST)

*[English version](README.md)*

Un petit utilitaire pour **Atari ST, STE, Mega STE et Falcon** qui affiche, en temps réel, l'état de tous les joysticks que la machine sait lire :

- **les ports 0 (souris) et 1** du ST : les 8 directions et le bouton de tir ;
- **le port parallèle**, pour les adaptateurs 4 joueurs (Gauntlet II, Leatherneck…) : les directions lues sur D0–D3 et sur D4–D7, le tir sur BUSY et sur STROBE, et les 8 lignes de données brutes. On voit ainsi le câblage de n'importe quel adaptateur ;
- **les ports joystick étendus A et B** (STE et Falcon seulement) : les directions de la manette Jaguar et les boutons A, B, C, Pause (P) et Option (O).

Une touche quelconque quitte le programme : le gestionnaire de joystick d'origine, la souris et les registres du circuit sonore sont remis comme avant. Il fonctionne en basse, moyenne et haute résolution.

JOYTEST a d'abord été écrit pour [IK+ Reforged](https://github.com/stephane-perez/ik-plus-reforged), pour vérifier les adaptateurs 3 joueurs et les manettes Jaguar sur machine réelle. Il vit désormais ici, comme un outil à part entière.

## Téléchargement

Chaque envoi construit les deux programmes : on les télécharge dans l'onglet **Actions**, sous le nom `joystick-tester`. Chaque étiquette `v*` publie aussi une version (release).

- `JOYTEST.TOS` : français
- `JOYTSTEN.TOS` : anglais

## Ce qui est lu, et comment

| Source | Lecture |
|---|---|
| Ports 0 et 1 | IKBD en mode joystick par événements (`$14`) ; paquets `$FE`/`$FF` captés par le vecteur `joyvec` du TOS (`Kbdvbase`). |
| Port parallèle | Lignes de données D0–D7 (registre 15 du circuit sonore, port B en entrée), BUSY (MFP GPIP bit 0), STROBE (registre 14 bit 5, remis à 1 avant chaque lecture). Toutes les lignes sont actives à 0. |
| Ports étendus | Seulement si le cookie `_MCH` indique un STE (`$00010000`) ou un Falcon (`$00030000`) : lire `$FF9202` sur STF ou Mega STE peut provoquer une erreur de bus. Ligne de sélection écrite dans `$FF9202`, boutons lus dans `$FF9200`, directions dans `$FF9202`. |

Sur un vrai STE, une lecture de `$FF9202` masque les boutons dans la lecture suivante de `$FF9200` (relu `FFFF`) ; l'émulateur Hatari ne le fait pas. JOYTEST, comme tout programme qui lit une manette Jaguar, lit donc `$FF9200` juste après la sélection, avant toute lecture de `$FF9202`.

## Construction

Il faut `make`, un compilateur C (pour construire l'assembleur vasm) et `curl` ou `git`.

```sh
make          # build/JOYTEST.TOS et build/JOYTSTEN.TOS
make check    # compare les deux programmes aux empreintes attendues
```

Au premier lancement, `make` construit l'assembleur [vasm](http://sun.hasenbraten.de/vasm/) (68000, syntaxe Motorola) dans `.tools/`. Pour en utiliser un autre : `make VASM=/chemin/vers/vasmm68k_mot`.

| Fichier | MD5 |
|---|---|
| `JOYTEST.TOS` | `db27ce125f4dc90f3078bd4d6b742221` |
| `JOYTSTEN.TOS` | `87ce3a687f6094a70bfb160fa0ab3e4b` |

## Essais dans Hatari

`hatari/run.sh` lance un programme sans écran et enregistre des captures ; `hatari/runx.sh` lance Hatari sur un écran X virtuel et appuie sur les touches avec `xdotool`, pour passer par l'émulation des joysticks de Hatari (configurations `joy3.cfg`, `joy4.cfg`, `joyall.cfg`, et `joyste.cfg` pour la manette Jaguar). Les images ROM du TOS ne sont pas fournies.

## Fichiers

- `src/joytest.s` : le programme (français par défaut, anglais avec `-DENGLISH`).
- `docs/fr/NOTES.md` : notes techniques et historique des essais sur machine réelle.

## Licence

MIT, voir [LICENSE](LICENSE). Atari, ST, STE, Mega STE, Falcon et Jaguar sont des marques de leurs propriétaires respectifs.
