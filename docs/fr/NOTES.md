# JOYTEST — notes techniques

Notes de travail, en français. JOYTEST est né dans
[IK+ Reforged](https://github.com/stephane-perez/ik-plus-reforged) (voir son
`docs/fr/VERSIONS.md`, §7, §8 et §12, pour le contexte complet) ; il en a été
sorti tel quel : les deux programmes sont identiques à l'octet à ceux
construits par IK+ Reforged v1.1.0.

## Ports 0 et 1 (IKBD)

- L'IKBD passe en mode joystick par événements (commande `$14`) ; le
  vecteur `joyvec` du TOS (`Kbdvbase`, décalage 24) reçoit chaque paquet.
- **Piège** : le TOS passe à `joyvec` un tampon de **3 octets** : en-tête
  `$FE`/`$FF`, joystick 0, joystick 1. Il faut lire les deux octets de
  joystick, pas seulement celui que désigne l'en-tête.
- En sortant : `joyvec` d'origine, souris remise en service (commande `$08`).

## Port parallèle (adaptateurs 4 joueurs)

- Données D0–D7 : registre 15 du PSG (port B). Le **bit 7 du registre 7 doit
  être à 0** (port B en entrée) juste avant chaque lecture, interruptions
  masquées. Sinon, la machine réelle relit le verrou de sortie et non les
  joysticks ; **Hatari ignore ce bit** et lit toujours les joysticks.
- BUSY : MFP GPIP bit 0. STROBE : registre 14 du PSG, bit 5 (remis à 1 avant
  la lecture). Toutes les lignes sont actives à 0.
- Câblage vérifié sur machine réelle (adaptateur type Gauntlet II /
  Leatherneck), identique à celui que Hatari émule : joystick 3 = D4–D7 +
  BUSY, joystick 4 = D0–D3 + STROBE.
- En sortant : registres 7 et 14 du PSG remis comme avant.

## Ports étendus A et B (manette Jaguar)

- Seulement sur STE (`_MCH` = `$00010000`) et Falcon (`$00030000`) : lire
  `$FF9202` sur STF ou Mega STE peut provoquer une erreur de bus.
- Lignes de sélection écrites dans `$FF9202` (les deux ports ensemble :
  `$FFEE`, `$FFDD`, `$FFBB`, `$FF77`). Ligne 0 : directions en bits 8–11 de
  `$FF9202`, Pause en bit 0 et A en bit 1 de `$FF9200` ; lignes 1, 2, 3 : B,
  C, Option en bit 1. Tout est actif à 0.
- **Sur la machine réelle, une lecture de `$FF9202` masque les boutons dans
  la lecture suivante de `$FF9200`** (relu `FFFF`) ; une nouvelle sélection
  remet tout en ordre. Hatari ne reproduit pas ce comportement. D'où les
  trois colonnes du tableau brut : (1) juste après la sélection, (2) après
  ~64 cycles d'attente, (3) après une lecture de `$FF9202`. Sur STE réel,
  (1) et (2) montrent les cinq boutons, (3) reste à `FFFF`.
- La ligne « Port étendu » utilise la lecture (1).

## Historique (IK+ Reforged)

1. Première version : ports 0 et 1, port parallèle (D0–D3, D4–D7, BUSY,
   STROBE, 8 lignes brutes). A permis de trouver la vraie cause du joystick 3
   muet dans le jeu (le bit 7 du registre 7).
2. Version anglaise (`-DENGLISH`, `JOYTSTEN.TOS`).
3. Ports étendus A et B, puis lignes brutes : la manette Jaguar d'origine
   montrait des boutons muets (A, Option).
4. Trois lectures de `$FF9200` par ligne : découverte du masquage par la
   lecture de `$FF9202`, sur STE réel.
