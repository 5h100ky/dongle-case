// =============================================================================
// Snake Dongle Case – Full Assembly Preview
// Renders both halves together so you can visually verify the design before
// exporting each shell for printing.
//
// Print instructions
//   • Export top_shell.scad  → top_shell.stl   (face down, no supports needed)
//   • Export bottom_shell.scad → bottom_shell.stl (face down, no supports)
//   • Recommended settings:
//       – Layer height  : 0.15–0.20 mm
//       – Infill        : 20–30 %
//       – Wall count    : 3
//       – Filament      : PLA or PETG
// =============================================================================
include <parameters.scad>
use    <top_shell.scad>
use    <bottom_shell.scad>

half = case_d / 2;

// Top shell – shown above, exploded for clarity
translate([0, 0, half + 3])
    top_shell();

// Bottom shell – shown below
bottom_shell();
