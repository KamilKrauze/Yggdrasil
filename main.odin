package main;

import "core:fmt"
// import ygd "framework"
// import nfh "system"
import rl "vendor:raylib"

main :: proc()
{
    // velocities : ygd.SparseSet([2]f32);
    // positions : ygd.SparseSet([2]f32);
    // boxes : ygd.SparseSet(box);

    // make_test_entities(25, &positions, &velocities, &boxes);

    // nfh.positions_ref = &positions;
    // nfh.velocities_ref = &velocities;
    // nfh.global_physics_settings = nfh.PhysicsSettings{{0.0, 1.0}, 9.8, 25 };
    // physics_thread := nfh.start_physics();

    rl.InitWindow(600, 600, "Yggdrasil");
    rl.SetTargetFPS(60);

    screenCentre:=rl.Vector2{ f32(rl.GetScreenWidth())/2, f32(rl.GetScreenHeight())/2 };

    boxA := rl.Rectangle{width=50, height=50, x=screenCentre.x, y=screenCentre.y + 20};
    boxB := rl.Rectangle{width=50, height=50, x=screenCentre.x, y=screenCentre.y};
    

    for rl.WindowShouldClose() == false
    {
        // boxB.x = f32(rl.GetMouseX()) - boxB.width/2;
        // boxB.y = f32(rl.GetMouseY()) - boxB.height/2;
    if rl.IsKeyDown(.A)
    {
        hit, normal, penetration := QueryBoxCollision(boxA, boxB);
        boxA.x += (penetration.x * normal.x)/2;
        boxA.y += (penetration.y * normal.y)/2;

        boxB.x += (penetration.x * normal.x * -1)/2;
        boxB.y += (penetration.y * normal.y * -1)/2;
    }
        rl.BeginDrawing();
        rl.ClearBackground({10, 10, 10, 0});
        rl.DrawFPS(10, 10);

        rl.DrawRectangleRec(boxA, rl.RED);
        rl.DrawRectangleRec(boxB, rl.BLUE);

        rl.EndDrawing();
    }
    
    rl.CloseWindow();
    // nfh.stop_physics(physics_thread);
}

CheckBoxCollision :: proc(rec1:rl.Rectangle, rec2:rl.Rectangle) -> bool
{
    xCol:bool = (rec1.x + rec1.width >= rec2.x) && (rec2.x + rec2.width >= rec1.x);
    yCol:bool = (rec1.y + rec1.height >= rec2.y) && (rec2.y + rec2.height >= rec1.y);

    return xCol && yCol;
}

QueryBoxCollision :: proc(rec1:rl.Rectangle, rec2:rl.Rectangle) -> (hit:bool=false, normal:rl.Vector2={0,0}, penetration:rl.Vector2={0,0})
{
        // Calculate centers
    a_center := rl.Vector2{
        rec1.x + rec1.width * 0.5,
        rec1.y + rec1.height * 0.5,
    }

    b_center := rl.Vector2{
        rec2.x + rec2.width * 0.5,
        rec2.y + rec2.height * 0.5,
    }

    // Calculate half extents
    a_half := rl.Vector2{rec1.width * 0.5, rec1.height * 0.5}
    b_half := rl.Vector2{rec2.width * 0.5, rec2.height * 0.5}

    // Difference between centers
    dx := b_center.x - a_center.x
    dy := b_center.y - a_center.y

    // Calculate overlap on each axis
    overlap_x := a_half.x + b_half.x - abs(dx)
    overlap_y := a_half.y + b_half.y - abs(dy)

        // Check for collision
    if overlap_x > 0 && overlap_y > 0 {
        hit = true

        // Find axis of least penetration
        if overlap_x < overlap_y {
            // Collision on X axis
            if dx > 0 {
                normal = rl.Vector2{-1, 0}
            } 
            else {
                normal = rl.Vector2{1, 0}
            }
            penetration = rl.Vector2{overlap_x, 0}
        } 
        else {
            // Collision on Y axis
            if dy > 0 {
                normal = rl.Vector2{0, -1}
            }
            else {
                normal = rl.Vector2{0, 1}
            }
            penetration = rl.Vector2{0, overlap_y}
        }

    }
    penetration = rl.Vector2{overlap_x, overlap_y}
    
    return;
}