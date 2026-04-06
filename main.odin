package main;

import ygd "framework"
import nfh "system"
import rl "vendor:raylib"


main :: proc()
{
    velocities : ygd.SparseSet([2]f32);
    positions : ygd.SparseSet([2]f32);
    boxes : ygd.SparseSet(box);

    make_test_entities(25, &positions, &velocities, &boxes);

    nfh.positions_ref = &positions;
    nfh.velocities_ref = &velocities;
    nfh.global_physics_settings = nfh.PhysicsSettings{{0.0, 1.0}, 9.8, 25 };
    physics_thread := nfh.start_physics();

    rl.InitWindow(600, 600, "Yggdrasil");
    // rl.SetTargetFPS(60);
    for rl.WindowShouldClose() == false
    {
        rl.BeginDrawing();
        rl.ClearBackground({10, 10, 10, 0});
        rl.DrawFPS(10, 10);

        draw_entities(&positions, &boxes);
        
        rl.EndDrawing();
    }
    
    rl.CloseWindow();
    nfh.stop_physics(physics_thread);
}