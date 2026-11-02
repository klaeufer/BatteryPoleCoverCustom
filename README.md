# Custom battery pole cover

Parametric OpenSCAD cover for a 94R/H7-style battery positive terminal area. The deck
has a clearance hole for a mil-spec terminal top post, perimeter support walls,
reinforcing gussets, and two slotted locating pins. Dimensions are in
millimeters.

## Use case

This is a custom cover for the positive terminal stack shown on the included images. Top-to-bottom order:

- terminal-mount accessory fuse block
- OEM terminal
- mil-spec terminal with top post
- positive battery post

The purpose of this stack is to have a reliable way to bolt a [Blue Sea terminal mount fuse block 5023](https://www.bluesea.com/products/5023/ST_Blade_Battery_Terminal_Mount_Fuse_Block) (also part of the [5024 kit](https://www.bluesea.com/products/5024/ST_Blade_Battery_Terminal_Mount_Fuse_Block_Kit)) to the terminal.

Unless you have a similar stack, this pole cover is probably not for you.
If you do have a DIN/European Norm (EN) battery, you'll probably want a standard pole cover, similar to this one but without the clearance hole, such as [the one referenced below](https://www.thingiverse.com/thing:2955260).

## How to use

Open `positive_cover.scad` in OpenSCAD, adjust the parameters near the top to
match your battery and terminal, preview, then render (F6) and export an STL.
Check clearances and fit against the actual battery before installation; the
current dimensions are project-specific starting values, not a guaranteed fit.

To check and export from the command line, run `./scripts/export_stl.sh` from
the project directory. It writes `positive_cover.stl` beside the SCAD file and
fails if OpenSCAD reports a warning/error or produces an empty output. If the
OpenSCAD CLI is not on your `PATH`, set `OPENSCAD_BIN` to its executable path.
GitHub Actions runs this check on pushes and pull requests; successful runs
also publish the rendered STL as a downloadable artifact.

## Related projects

- [94R/H7 battery height spacer](https://github.com/klaeufer/BatterySpacer94R)

## Attributions

Inspired by “Car Battery Cover” by dumbstone ([Thingiverse Thing 2955260](https://www.thingiverse.com/thing:2955260)).
This model was independently measured and created in OpenSCAD; it does not
include the original STL. Original design in this repository is released under
the MIT License; see `LICENSE`.

The parametric OpenSCAD components were authored via an AI-assisted workflow utilizing Google Search AI mode for geometric discovery and Cline (GPT-6) for programmatic Constructive Solid Geometry (CSG) compilation.
