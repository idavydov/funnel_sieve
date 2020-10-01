// based on https://openhome.cc/eGossip/OpenSCAD/Polyline.html
// I only replaced atan with atan2 (more numerically stable)
module line(point1, point2, width = 1, cap_round = true) {
    angle = 90 - atan2((point2[1] - point1[1]), (point2[0] - point1[0]));
    offset_x = 0.5 * width * cos(angle);
    offset_y = 0.5 * width * sin(angle);

    offset1 = [-offset_x, offset_y];
    offset2 = [offset_x, -offset_y];

    if(cap_round) {
        translate(point1) circle(d = width, $fn = 24);
        translate(point2) circle(d = width, $fn = 24);
    }

    polygon(points=[
        point1 + offset1, point2 + offset1,  
        point2 + offset2, point1 + offset2
    ]);
}

            
module lines(minmax, step, width=0.7) {
    minmax = floor(minmax/step) * step; 
    for (i = [-minmax:step:minmax]) {
        line([i, -minmax], [i, minmax], width=width);
    }
}

module mesh(minmax, n, step, width=0.7) {
    for (i = [0:n])
        rotate([0, 0, i*180/n]) lines(minmax, step, width);
}


$fn = 120;

r = 52;

intersection() {
   cylinder(h=1.5, r=49.5);
   linear_extrude(height=1.5) mesh(r, 2, 2.4, 0.7);
}

difference() {
  cylinder(h=50, r=49.5);
  translate([0, 0, -1]) cylinder(h=52, r=47.5);
}
