module funnel(r1, h1, r2, h2, h3) {
    union() {
       cylinder(h=h1+1, r=r1);
       translate([0, 0, h1]) cylinder(h=h2, r1=r1, r2=r2);
       translate([0, 0, h1 + h2 - 1]) cylinder(h=h3+1, r=r2);
    }
}

module empty_funnel(r1, h1, r2, h2, h3, thickness=1) {
    difference() {
        funnel(r1, h1, r2, h2, h3);
        translate([0, 0, -1]) funnel(r1 - thickness, h1 + 1, r2 - thickness, h2, h3 + 1);
    }
}

$fn = 60;

empty_funnel(52, 20, 10, 60, 30);
