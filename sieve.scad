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

module polyline(points, width = 1) {
    module polyline_inner(points, index) {
        if(index < len(points)) {
            line(points[index - 1], points[index], width);
            polyline_inner(points, index + 1);
        }
    }

    polyline_inner(points, 1);
}




goldenRatio = (1 + sqrt(5)) / 2;

// penrose tiling based on this article:
// https://preshing.com/20110831/penrose-tiling-explained/

function start_triangle(i) =
    let (
        A = [0, 0],
        B = [r*cos((2*i-1) * 18), r*sin((2*i-1) * 18)],
        C = [r*cos((2*i+1) * 18), r*sin((2*i+1) * 18)]
    )
        i % 2 == 0 ? [0, A, C, B] : [0, A, B, C];

function subdivide(l) = [
    for (tr = l)
        let (
            color = tr[0],
            A = tr[1],
            B = tr[2],
            C = tr[3],
            P = A + (B - A) / goldenRatio,
            Q = B + (A - B) / goldenRatio,
            R = B + (C - B) / goldenRatio
        )
            if (color == 0)
                each [[0, C, P, B], [1, P, C, A]]
            else
                each [[1, R, C, A], [1, Q, R, B], [0, R, Q, A]]
];

function subdivide_n(l, n) =
            n == 0 ? l : subdivide_n(subdivide(l), n-1);


module mesh(triangles, width=0.5) {
    for (tr = triangles)
        let (
            color = tr[0],
            A = tr[1],
            B = tr[2],
            C = tr[3]
        )
            {
                if ( color == 0 )
                    polyline(points = [B, A, C], width=width);
                else
                    polyline(points = [B, A, C], width=width);
            }
 }


$fn = 60;

r = 55;

start_triangles = [
    for (i = [0:9]) start_triangle(i)
];

triangles  = subdivide_n(start_triangles, 6);

intersection() {
   cylinder(h=3, r=50);
   translate([0, 0, 1]) linear_extrude(height=1) mesh(triangles);
}

difference() {
  cylinder(h=50, r=50);
  translate([0, 0, -1]) cylinder(h=52, r=49);
}

