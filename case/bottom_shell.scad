// =============================================================================
// Snake Dongle Case – Bottom Shell
// Includes: USB cut-out, controller pocket, screw bosses with counter-bores
// =============================================================================
include <parameters.scad>

half = case_d / 2;

// ── Helper: rounded rectangular prism ────────────────────────────────────
module rrect(w, h, r, d) {
    hull()
        for (x = [r, w-r], y = [r, h-r])
            translate([x, y, 0]) cylinder(r=r, h=d);
}

// ── Main bottom-shell module ──────────────────────────────────────────────
module bottom_shell() {
    difference() {

        // ── Outer body ────────────────────────────────────────────────────
        rrect(case_w, case_h, corner, half);

        // ── Inner cavity ──────────────────────────────────────────────────
        translate([wall, wall, floor])
            rrect(case_w - 2*wall, case_h - 2*wall, corner - 0.5,
                  half - floor + 0.01);

        // ── USB-C cut-out (positioned at the bottom edge, centred) ────────
        // The nRF52840 USB connector faces the bottom edge of the case.
        translate([usb_x, -0.1, floor])
            cube([usb_w, wall + 0.2, usb_h]);

        // ── Screw through-holes + counter-bore for screw head ─────────────
        for (p = screw_pos) {
            translate([p[0], p[1], -0.1])
                cylinder(d=screw_d, h=half + 0.2);           // clearance hole
            translate([p[0], p[1], -0.1])
                cylinder(d=screw_d + 2.4, h=1.8);            // counter-bore
        }
    }

    // ── Alignment rim that mates with the top shell ───────────────────────
    // A thin lip around the perimeter so both halves register to each other.
    translate([wall + tol, wall + tol, half - 0.8])
        difference() {
            rrect(case_w - 2*(wall+tol),
                  case_h - 2*(wall+tol),
                  corner - 0.5, 1.2);
            translate([1.2, 1.2, -0.1])
                rrect(case_w - 2*(wall+tol) - 2.4,
                      case_h - 2*(wall+tol) - 2.4,
                      corner - 0.5, 1.4);
        }
}

bottom_shell();
