# Joystick Tester (JOYTEST)

*[Version française](README_FR.md)*

A small utility for the **Atari ST, STE, Mega STE and Falcon** that shows, in real time, the state of every joystick the machine can read:

- **ports 0 (mouse) and 1** of the ST: the 8 directions and the fire button;
- **the parallel port**, for 4-player adapters (Gauntlet II, Leatherneck…): the directions read on D0–D3 and on D4–D7, the fire button on BUSY and on STROBE, and the 8 raw data lines. This shows how any adapter is wired;
- **the enhanced joystick ports A and B** (STE and Falcon only): Jaguar pad directions and the A, B, C, Pause (P) and Option (O) buttons, plus the raw values read on each of the 4 select lines, three different ways (a hardware diagnostic, see below).

Press any key to quit: the original joystick handler, the mouse and the sound chip registers are restored. It works in low, medium and high resolution.

JOYTEST was first written for [IK+ Reforged](https://github.com/stephane-perez/ik-plus-reforged), to check the 3-player adapters and the Jaguar pads on real hardware. It now lives here as a tool of its own.

## Download

Every push builds both programs: they can be downloaded from the **Actions** tab, as the `joystick-tester` artifact. Each `v*` tag also publishes a release.

- `JOYTEST.TOS`: French
- `JOYTSTEN.TOS`: English

## What it reads, and how

| Source | How it is read |
|---|---|
| Ports 0 and 1 | IKBD in event joystick mode (`$14`); `$FE`/`$FF` packets caught through the TOS `joyvec` vector (`Kbdvbase`). |
| Parallel port | Data lines D0–D7 (sound chip register 15, port B set as input), BUSY (MFP GPIP bit 0), STROBE (sound chip register 14 bit 5, set back to 1 before each read). All lines are active low. |
| Enhanced ports | Only when the `_MCH` cookie says STE (`$00010000`) or Falcon (`$00030000`): reading `$FF9202` on an STF or a Mega STE can cause a bus error. Select line written to `$FF9202`, buttons read in `$FF9200`, directions in `$FF9202`. |

The raw table at the bottom shows, for each select line L0–L3 (both ports selected together), `$FF9202` and `$FF9200` read (1) just after the select, (2) after a short wait, (3) after a read of `$FF9202`. On a real STE, a read of `$FF9202` hides the buttons in the next read of `$FF9200` (column 3 stays `FFFF`); the Hatari emulator does not do this. Programs reading a Jaguar pad must read `$FF9200` first.

## Building

Requirements: `make`, a C compiler (to build the vasm assembler) and `curl` or `git`.

```sh
make          # build/JOYTEST.TOS and build/JOYTSTEN.TOS
make check    # compares both programs with the expected checksums
```

On the first run, `make` builds the [vasm](http://sun.hasenbraten.de/vasm/) assembler (68000, Motorola syntax) into `.tools/`. To use another copy: `make VASM=/path/to/vasmm68k_mot`.

| File | MD5 |
|---|---|
| `JOYTEST.TOS` | `409a6a20a58231d018e19241b7feac34` |
| `JOYTSTEN.TOS` | `324808fc4ba48e3561794939379ea1ce` |

## Testing in Hatari

`hatari/run.sh` runs a program without a display and saves screenshots; `hatari/runx.sh` runs Hatari on a virtual X display and presses keys with `xdotool`, so they go through Hatari's joystick emulation (configurations `joy3.cfg`, `joy4.cfg`, `joyall.cfg` and `joyste.cfg` for the Jaguar pad). TOS ROM images are not provided.

## Files

- `src/joytest.s`: the program (French by default, English with `-DENGLISH`).
- `docs/fr/NOTES.md`: technical notes and the history of real-hardware tests (in French).

## License

MIT, see [LICENSE](LICENSE). Atari, ST, STE, Mega STE, Falcon and Jaguar are trademarks of their respective owners.
