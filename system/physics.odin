package sys;
import ygd "../framework"

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

physics_tick_update := proc(dt:f32)
{
    for idx in 0 ..< ygd.entity_count([2]f32, positions_ref)
    {
        e := ygd.get_entity([2]f32, positions_ref, idx);
        for i:=0; i<5; i+=1
        {
            pos := ygd.get_entity_component([2]f32, positions_ref, e);
            vel := ygd.get_entity_component([2]f32, velocities_ref, e);

            // Apply gravity.
            vel[0] += (global_physics_settings.gravity_dir[0] * global_physics_settings.gravity_strength * dt);
            vel[1] += (global_physics_settings.gravity_dir[1] * global_physics_settings.gravity_strength * dt);

            // Update position.
            pos[0] += vel[0] * dt;
            pos[1] += vel[1] * dt;
        }
    }
}

run_phys_thread :: proc(t:^thread.Thread)
{
    delay_per_tick_update:f32 = 1.0/f32(global_physics_settings.tick_rate);
    delay := time.Duration(delay_per_tick_update * 1000) * time.Millisecond;
    
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