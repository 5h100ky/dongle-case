// =============================================================================
// Snake Dongle Case – Top Shell
// Includes: display window, button holes, light-sensor slot, screw bosses
// =============================================================================
include <parameters.scad>

half = case_d / 2;   // each half uses half the total depth

// ── Helper: rounded rectangular prism ────────────────────────────────────
module rrect(w, h, r, d) {
    hull()
        for (x = [r, w-r], y = [r, h-r])
            translate([x, y, 0]) cylinder(r=r, h=d);
}

// ── Main top-shell module ─────────────────────────────────────────────────
module top_shell() {
    difference() {

        // ── Outer body ────────────────────────────────────────────────────
        rrect(case_w, case_h, corner, half);

        // ── Inner cavity ──────────────────────────────────────────────────
        translate([wall, wall, floor])
            rrect(case_w - 2*wall, case_h - 2*wall, corner - 0.5,
                  half - floor + 0.01);

        // ── Display window ────────────────────────────────────────────────
        translate([disp_win_x, disp_win_y, -0.1])
            cube([disp_win_w, disp_win_h, floor + 0.2]);

        // ── Display PCB recess (0.5 mm step so PCB sits flush) ────────────
        translate([disp_off_x - tol, disp_off_y - tol, floor - 0.5])
            cube([disp_pcb_w + 2*tol, disp_pcb_h + 2*tol, 1.0]);

        // ── Button holes ──────────────────────────────────────────────────
        translate([btn1_x, btn1_y, -0.1])
            cylinder(d=btn_d, h=floor + 0.2);
        translate([btn2_x, btn2_y, -0.1])
            cylinder(d=btn_d, h=floor + 0.2);

        // ── Light-sensor slot ─────────────────────────────────────────────
        // Rectangular slot exposes the LDR to ambient light
        translate([sensor_slot_x, sensor_slot_y, -0.1])
            cube([sensor_slot_w, sensor_slot_h, floor + 0.2]);

        // ── Screw clearance holes through face ────────────────────────────
        for (p = screw_pos)
            translate([p[0], p[1], -0.1])
                cylinder(d=screw_d, h=half + 0.2);
    }

    // ── Heat-set insert bosses (raised from cavity floor) ─────────────────
    for (p = screw_pos)
        translate([p[0], p[1], floor])
            difference() {
                cylinder(d=boss_od, h=insert_len + 1);
                translate([0, 0, 1])
                    cylinder(d=insert_od, h=insert_len + 0.1);
            }
}

top_shell();
