package niflheim;
import ygd "../framework"
import data "../system/structures"

import "core:fmt"
import "core:thread"
import "core:time"

// Global physics settings
PhysicsSettings :: struct
{
    gravity_dir:[2]f32,     // Gravity direction.
    gravity_strength:f32,   // Gravity direction strength multiplier.
    tick_rate:u32,          // How many physics tick updates to compute per second.
}

global_physics_settings : PhysicsSettings;

positions_ref : ^ygd.SparseSet([2]f32) = nil;
velocities_ref : ^ygd.SparseSet([2]f32) = nil;

physics_tick_update :: proc(dt:f32)
{
    entities := ygd.entity_count([2]f32, positions_ref);

    gravity_dt : [2]f32 = {
        global_physics_settings.gravity_dir[0] * global_physics_settings.gravity_strength * dt,
        global_physics_settings.gravity_dir[1] * global_physics_settings.gravity_strength * dt,
    };

    // --- Build grid ---
    grid: data.Grid;
    // IMPORTANT: initialize map
    grid = make(data.Grid);

    // 🔥 THIS LOOP IS MISSING
    for i in 0 ..< entities
    {
        other := ygd.get_entity([2]f32, positions_ref, i);
        other_pos := ygd.get_entity_component([2]f32, positions_ref, other);

        data.update_grid(&grid, other, other_pos);
    }

    for idx in 0 ..< entities {
        e := ygd.get_entity([2]f32, positions_ref, idx);

        pos := ygd.get_entity_component([2]f32, positions_ref, e);
        vel := ygd.get_entity_component([2]f32, velocities_ref, e);

        // Apply gravity once per tick
        vel[0] += gravity_dt[0];
        vel[1] += gravity_dt[1];

        remaining_dt := dt;

        // Iterate a few times to resolve multiple collisions
        for iter := 0; iter < 4; iter += 1 {
            if remaining_dt <= 0 {
                break;
            }

            closest_t :f32= 1.0;
            hit_normal := [2]f32{0, 0};
            hit_any := false;

            // --- Query nearby entities ---
            it := data.nearby_begin(&grid, pos, e);
            for {
                other, ok := data.nearby_next(&it);
                if !ok {
                    break;
                }

                other_pos := ygd.get_entity_component([2]f32, positions_ref, other);

                hit, t, normal := aabb_sweep(
                    rect{25, 25}, vec2{pos[0], pos[1]}, vec2{vel[0], vel[1]},
                    rect{25, 25}, vec2{other_pos[0], other_pos[1]},
                );

                if hit && t < closest_t {
                    closest_t = t;
                    hit_normal = {normal.x, normal.y};
                    hit_any = true;
                }
            }

            if hit_any {
                // Move up to impact
                pos[0] += vel[0] * closest_t;
                pos[1] += vel[1] * closest_t;

                // Slide (remove velocity along normal)
                dot := vel[0]*hit_normal[0] + vel[1]*hit_normal[1];
                if dot < 0 {
                    vel[0] -= dot * hit_normal[0];
                    vel[1] -= dot * hit_normal[1];
                }

                // Reduce remaining time
                remaining_dt *= (1 - closest_t);

            } else {
                // No collision → move fully
                pos[0] += vel[0] * remaining_dt;
                pos[1] += vel[1] * remaining_dt;
                break;
            }
        }
    }
}

run_phys_thread :: proc(t:^thread.Thread)
{
    delay_per_tick_update:f32 = 1.0/f32(global_physics_settings.tick_rate);
    delay := time.Duration(delay_per_tick_update * f32(time.Second));
    
    for true
    {
        physics_tick_update(delay_per_tick_update);
        time.sleep(delay);
    }
}

start_physics :: proc() -> ^thread.Thread
{
    assert(positions_ref != nil, "\n\tPositions reference must be set before starting physics thread.");
    assert(positions_ref != nil, "\n\tVelocities reference must be set before starting physics thread.");
    
    t:=thread.create(run_phys_thread);
    thread.start(t);
    return t;
}

stop_physics :: proc(phys_thread: ^thread.Thread)
{
    assert(phys_thread != nil);
    fmt.println("Terminating physics thread...");
    thread.terminate(phys_thread, 0);

    velocities_ref = nil;
    positions_ref = nil;
}