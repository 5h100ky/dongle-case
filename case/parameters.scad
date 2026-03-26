// =============================================================================
// Snake Dongle Case – Shared Parameters
// Compatible with:
//   • Pro Micro nRF52840 / Nice Nano v2 controller
//   • 1.54" TFT 240×240 ST7789 display  (PCB: 35 mm × 38 mm, window: 28 mm × 28 mm)
//   • 2× 6×6×8 mm tactile push buttons
//   • LDR light-sensor module           (replaces the buzzer, ~8 mm × 12 mm)
//   • M2 heat-set brass inserts + M2 screws
// =============================================================================

// ── General print tolerances ───────────────────────────────────────────────
$fn = 40;
tol = 0.2;          // fit tolerance between mating parts

// ── Wall & structure ───────────────────────────────────────────────────────
wall   = 1.8;       // shell wall thickness (mm)
floor  = 1.8;       // top / bottom face thickness (mm)
corner = 2.5;       // outer corner radius

// ── Overall case envelope ─────────────────────────────────────────────────
case_w = 46;        // width  (X)
case_h = 62;        // height (Y)
case_d = 15;        // total depth (Z) – split equally between top and bottom half

// ── Display (1.54" TFT, ST7789) ───────────────────────────────────────────
disp_pcb_w  = 35;
disp_pcb_h  = 38;
disp_win_w  = 28;   // visible display window width
disp_win_h  = 28;   // visible display window height
// Top-left corner of the display PCB pocket, measured from the front-face origin
disp_off_x  = (case_w - disp_pcb_w) / 2;
disp_off_y  = 5;
// Window centred on the PCB
disp_win_x  = disp_off_x + (disp_pcb_w - disp_win_w) / 2;
disp_win_y  = disp_off_y + (disp_pcb_h - disp_win_h) / 2;

// ── Buttons (6×6 tactile) ─────────────────────────────────────────────────
btn_d  = 6.6;       // through-hole diameter for button cap
btn1_x = 11;        // menu / reset button – left
btn1_y = case_h - 13;
btn2_x = case_w - 11; // action button – right
btn2_y = btn1_y;

// ── Light sensor (LDR module, replaces buzzer) ────────────────────────────
// Module dimensions: ~12 mm × 8 mm; exposed sensor window: 7 mm × 4 mm
sensor_slot_w = 9;   // opening width
sensor_slot_h = 5;   // opening height
// Centred between display and bottom edge
sensor_slot_x = (case_w - sensor_slot_w) / 2;
sensor_slot_y = disp_off_y + disp_pcb_h + 4;

// ── USB connector (USB-C, on the nRF52840 controller) ─────────────────────
usb_w  = 10;
usb_h  = 4.5;
usb_x  = (case_w - usb_w) / 2;

// ── Fasteners (M2 heat-set inserts) ───────────────────────────────────────
insert_od  = 3.2;   // heat-set insert outer diameter
insert_len = 3.0;   // insert height
screw_d    = 2.2;   // M2 clearance hole diameter
boss_od    = insert_od + 2 * wall;  // boss outer diameter

// Screw-boss centres (one at each corner)
screw_pos = [
    [6,         6        ],
    [case_w-6,  6        ],
    [6,         case_h-6 ],
    [case_w-6,  case_h-6 ],
];
