// =================================================================
// SIMPLIFIED LOW-PROFILE 94R/H7 BATTERY POLE ADAPTER DECK
// 70mm x 75mm platform with open sides and oversized post clearance
// =================================================================
$fn = 100;

// --- 1. CORE PARAMETERS & CLEARANCES ---
clearance       = 0.4;   // Clearance buffer for standard printer filament expansion
wall_thickness  = 2.4;   // Solid thickness for robust engine bay durability (ABS/ASA)
pin_dia         = 4.8;   // Target diameter for a snug friction fit inside 5.0mm holes
pin_height      = 6.0;  // Approximate pin length, based on the reference image
pin_slit_width  = 0.8;   // Width of each tension slit
pin_slit_length = pin_height / 2; // Slit runs upward from the free end
wall_gusset     = 3.2;   // Interior triangular brace size at wall/plate joints
round_corner_gusset_size = 3.2; // Plan size of brace at rounded -X/+Y corner
round_corner_gusset_drop = 22.0;  // Vertical depth of that brace below the plate

// --- 2. DECK FACE FOOTPRINT (70mm x 75mm) ---
deck_width      = 70.0;  // Total X-axis width including casing overlap
deck_length     = 75.0;  // Total Y-axis length including casing overlap
plate_thickness = 2.4;   // Height of the flat top deck plate face
wall_drop       = 22.0;  // Drop from battery-facing plate underside to wall bottoms
short_wall_length = 12.0; // Maximum return length on the +X edge
minus_x_wall_start_y = 8.0; // Leave the -Y plate overlap without a dropped wall
corner_radius   = 6.0;   // Rounded trim radius at the -X / +Y corner
perimeter_chamfer = 1.2; // Plan-view bevel along the -X and +Y outside edges
top_edge_chamfer = wall_thickness / 2; // 45-degree bevel around the top plate perimeter

// --- 3. HARDWARE PASS-THROUGH LOCATION ---
// Oversized to 21mm to build in horizontal wiggle-room around the pole base
post_center_x   = 28.0;
post_center_y   = 54.0;
pass_through_dia= 23.0;  // Intentionally wider than SAE base spec for placement flexibility

// --- 4. ANCHOR PIN PLACEMENT (+X / near edge) ---
pin_edge_inset  = 8.0;   // Pin centers are inset from the +X edge
pin_y_start     = 14.0;  // First pin center measured from the -Y edge
pin_y_spacing   = 40.0;  // Separation between pins along Y

// =================================================================
// MAIN ASSEMBLY GENERATION
// =================================================================

union() {
    // --- PART A: THE TOP DECK PLATFORM & WALL MODULE ---
    difference() {
        // I. Additive Solid Structure (Deck Plate + Specified Downward Walls)
        union() {
            // Plate perimeter profiles are offset inward at the top to create
            // a 45-degree chamfer, including a concentric offset of the round
            // -X/+Y corner. The straight upper edges meet the rounded profile.
            linear_extrude(height = plate_thickness - top_edge_chamfer)
                deck_outline(0, corner_radius);
            translate([0, 0, plate_thickness - top_edge_chamfer])
                hull() {
                    linear_extrude(height = 0.01)
                        deck_outline(0, corner_radius);
                    translate([0, 0, top_edge_chamfer - 0.01])
                        linear_extrude(height = 0.01)
                            deck_outline(top_edge_chamfer,
                                         corner_radius - top_edge_chamfer);
                }

            // Downward Wall along the -X axis boundary
            translate([0, minus_x_wall_start_y, -wall_drop])
                cube([wall_thickness,
                      deck_length - minus_x_wall_start_y,
                      wall_drop]);

            // Downward Wall along the +Y axis boundary
            translate([0, deck_length - wall_thickness, -wall_drop])
                cube([deck_width, wall_thickness, wall_drop]);

            // Optional narrow stabilizing wall section along the +X axis
            // Shunted toward the +Y edge to anchor the corner structure cleanly
            translate([deck_width - wall_thickness,
                       deck_length - short_wall_length,
                       -wall_drop])
                cube([wall_thickness, short_wall_length, wall_drop]);

            // Interior triangular gussets reinforce the long wall-to-plate
            // joints, while remaining inside the existing outer footprint.
            gusset_along_y(wall_thickness,
                           minus_x_wall_start_y,
                           deck_length - minus_x_wall_start_y,
                           wall_gusset);
            gusset_along_x(0, deck_length - wall_thickness,
                           deck_width, wall_gusset);

            // Broad diagonal brace beneath the plate at the rounded -X/+Y
            // corner. It ties the two walls together and backs the curved wall.
            rounded_corner_gusset(round_corner_gusset_size,
                                  round_corner_gusset_drop);
        }

        // II. Subtractive Precision Cuts
        union() {
            // Oversized center pass-through hole for the mil-spec post connection
            translate([post_center_x, post_center_y, -wall_drop - 1])
                cylinder(h = total_height() + 2, d = pass_through_dia + clearance);

            // Continue the rounded -X/+Y outside corner through the dropped
            // walls and gusset. This matches the lower plate outline; the
            // inset top profile preserves the perimeter bevel above it.
            translate([-1, deck_length - corner_radius, -wall_drop - 1])
                difference() {
                    cube([corner_radius + 1, corner_radius + 1,
                          total_height() + 2]);
                    translate([corner_radius + 1, 0, -0.1])
                        cylinder(h = total_height() + 2.2, r = corner_radius);
                }

            // Small 45-degree plan-view bevels run the full length of the
            // outside -X and +Y edges, including the dropped walls.
            linear_extrude(height = total_height() + 2)
                polygon(points=[[-1, -1],
                                [perimeter_chamfer, -1],
                                [-1, perimeter_chamfer]]);

            linear_extrude(height = total_height() + 2)
                translate([0, deck_length, 0])
                    polygon(points=[[-1, 1],
                                    [perimeter_chamfer, 1],
                                    [-1, -perimeter_chamfer]]);
        }
    }

    // --- PART B: THE INTEGRATED DOWNWARD ANCHORING PINS ---
    // Slotted pins along the +X edge. Each slit opens from the free tip
    // halfway up the pin, allowing the two sides to flex for a tension fit.
    slotted_pin(deck_width - pin_edge_inset, pin_y_start);
    slotted_pin(deck_width - pin_edge_inset, pin_y_start + pin_y_spacing);
}

// --- Dynamic Height Calculation Helper ---
function total_height() = plate_thickness + wall_drop;

// 2D plate outline; offset and radius shrink together for the beveled top.
module deck_outline(inset, radius) {
    difference() {
        translate([inset, inset])
            square([deck_width - 2 * inset,
                    deck_length - 2 * inset]);
        translate([-1, deck_length - corner_radius, -0.1])
            difference() {
                square([corner_radius + 1, corner_radius + 1]);
                translate([corner_radius + 1, 0])
                    circle(r = radius);
            }
    }
}

module slotted_pin(x, y) {
    difference() {
        translate([x, y, -pin_height])
            cylinder(h = pin_height, d = pin_dia);
        translate([x - pin_slit_width/2,
                   y - pin_dia/2 - 0.5,
                   -pin_height - 0.01])
            cube([pin_slit_width, pin_dia + 1,
                  pin_slit_length + 0.01]);
    }
}

// Triangular brace against a wall running along Y; x is its inner face.
module gusset_along_y(x, y_start, length, size) {
    translate([x, y_start + length, 0])
        rotate([90, 0, 0])
            linear_extrude(height = length)
                polygon(points=[[0, 0], [size, 0], [0, -size]]);
}

// Triangular brace against a wall running along X; y is its inner face.
module gusset_along_x(x_start, y, length, size) {
    translate([x_start, 0, 0])
        rotate([0, 90, 0])
            linear_extrude(height = length)
                polygon(points=[[0, y], [0, y - size], [size, y]]);
}

// Triangular-prism rib in plan, extruded down from the plate to reinforce
// the rounded corner wall and join the inner faces of the -X and +Y walls.
module rounded_corner_gusset(size, drop) {
    x_inner = wall_thickness;
    y_inner = deck_length - wall_thickness;
    translate([0, 0, -drop])
        linear_extrude(height = drop)
            polygon(points=[
                [x_inner,        y_inner - size],
                [x_inner + size, y_inner],
                [x_inner,        y_inner]
            ]);
}
