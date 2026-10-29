# WLED Effects Studio gallery

Effects made in the [WLED Effects Studio](https://github.com/Aceftwspades/wled-effects-studio),
shared. Each is a graph you can open in your own project, change and put on
your own lights.

## Browsing it

In the studio: **Library** (Window > Library) > **Gallery**. Every effect
here is a tile with its preview; a click fetches it into your project. The
studio asks first, since an effect is code that runs on your computer when
it is built - open what you trust.

You can also look around here: `previews/` has a turn of each effect on a
cube, `effects/` the graphs themselves.

## Sharing yours

1. In the studio, open the graph and choose **Library > Gallery > Share
   this graph...**: name it, describe it in a sentence, tag it. The studio
   makes a folder in `captures/gallery-share/<id>/` with the graph
   (`effects/<id>.graph.json`), a preview (`previews/<id>.gif`) and its
   entry (`entry.json`).
2. Fork this repository, copy the two files into the same folders, and add
   the object in `entry.json` to the `entries` list of `index.json`.
3. Open a pull request. A check makes sure the files match the entry (the
   sha256 is the graph file's) and are within the sizes below.

What fits: a graph that runs on WLED with the studio's usermod, with no
picture or video file of its own (a gallery bundle carries neither), no
firmware outside a standard WLED tree, a file under 2 MB and a preview
under 6 MB.

## The index

`index.json` lists the effects:

```json
{"gallery": 1, "entries": [
  {"id": "aurora-ribbon", "name": "Aurora Ribbon", "author": "you",
   "description": "One sentence about it.", "tags": ["2-D", "audio"],
   "sha256": "<sha256 of effects/aurora-ribbon.graph.json>", "requires": []}
]}
```

An id is lower case letters, digits and dashes; the studio finds an entry's
files by its id alone.

## Licence

The effects (the graphs) are shared under the EUPL v1.2 or later, the
studio's and WLED's licence ([LICENSE](LICENSE)). By opening a pull request
you share yours under it too. The add-on looks keep their own licences,
below.

## Add-on looks for the VJ

Beside the graphs are packs of looks for the studio's VJ: MilkDrop presets
and Shadertoy shaders, in `looks/<pack id>/`, listed in `packs.json` with a
picture of each pack in `previews/packs/`. In the studio: **Packs...** in the
VJ window installs a whole pack or a single look, for every project on that
computer, and removes them the same way.

| Pack | Looks | Licence |
|---|---|---|
| MilkDrop: Tunnels & radial | 7 | each preset its author's, shared freely |
| MilkDrop: Kaleidoscopes & mirrors | 7 | each preset its author's, shared freely |
| MilkDrop: Liquid & fire | 5 | each preset its author's, shared freely |
| MilkDrop: Shapes & waves | 9 | each preset its author's, shared freely |
| MilkDrop: Cosmic & orbits | 8 | each preset its author's, shared freely |
| MilkDrop: Neon & wire | 8 | each preset its author's, shared freely |
| MilkDrop: Psychedelic | 8 | each preset its author's, shared freely |
| MilkDrop: Ripples & clouds | 8 | each preset its author's, shared freely |
| MilkDrop: Particles & sparks | 8 | each preset its author's, shared freely |
| Shadertoy: Raymarched | 7 | CC0, MIT |
| Shadertoy: Colour & flow | 6 | CC BY 4.0, CC0, MIT |
| Shadertoy: Patterns & kaleidoscopes | 8 | **CC BY-NC-SA 3.0, non-commercial** |
| Shadertoy: Worlds | 6 | **CC BY-NC-SA 3.0, non-commercial** |
| Shadertoy: Light & space | 7 | CC0, MIT |
| Shadertoy: Tiles & loops | 8 | CC BY 4.0, CC0, MIT |
| Shadertoy: Scenes | 8 | CC BY 4.0, CC0 |
| Shadertoy: Neon & stars | 8 | **CC BY-NC-SA 3.0, non-commercial** |
| Shadertoy: Deep space | 8 | **CC BY-NC-SA 3.0, non-commercial** |
| Shadertoy: Op art | 8 | **CC BY-NC-SA 3.0, non-commercial** |

Each look names its author, its source and its licence at its top, and
again in `packs.json`. They are **not** under the EUPL like the graphs:

- **The MilkDrop presets** come from the "cream of the crop" collection the
  [projectM](https://github.com/projectM-visualizer/presets-cream-of-the-crop)
  project gathered from the MilkDrop community, where presets have always
  been shared freely. Each stays its author's.
- **The open shaders** are under the licence written in their own source:
  CC0, MIT or CC BY 4.0. Keep the notice when you share them.
- **The packs marked non-commercial** are under Shadertoy's default
  licence, [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/):
  use them in shows and share them, credited, but not for money (not in a
  paid product, not in paid work), and share a changed one on the same
  terms. The studio marks these packs and their looks in amber.

What was changed: every shader has a few lines at the end of its Image pass,
marked, that swell it on the beat and lift its light with the bass, as far
as the deck's amount knob says (at 0 it is the shader as it was). Presets
that barely moved with the music have two per-frame lines, noted in the
file's header, so the bass swells their zoom and the treble their turn. A
shader that reads the mouse can be steered from the deck. Shaders that
misbehaved in the studio, or sat dark or still, were left out.

`packs.json`:

```json
{"packs": 1, "list": [
  {"id": "milkdrop-tunnels", "name": "MilkDrop: Tunnels & radial", "kind": "milkdrop",
   "description": "One sentence.", "licence": "...", "noncommercial": false,
   "items": [{"file": "Tunnel race.milk", "name": "Tunnel race", "author": "martin",
              "licence": "...", "sha256": "<the file's>", "tags": [], "note": "what was changed"}]}
]}
```

A look's file name is letters, digits, spaces and `. _ ( ) + & , ' -`,
ending `.milk` or `.glsl`, within 512 KB; the check holds packs to this.
