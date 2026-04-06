package main;

import "core:math/rand"
import rl "vendor:raylib"
import ygd "framework";


box :: struct
{
    dim:rl.Vector2,
    colour:rl.Color,
}

make_test_entities :: proc(count:u32, 
    positions: ^ygd.SparseSet([2]f32), 
    velocities: ^ygd.SparseSet([2]f32), 
    boxes: ^ygd.SparseSet(box))
{
    for i in 0 ..< count
    {
        e := ygd.create_entity();

        sign := i % 2 == 0 ? 1 : -1;

        x := rand.float32_range(-100, 100);
        y := rand.float32_range(-25, 25);


        ygd.attach_component([2]f32, positions, e, [2]f32{x + f32(15 * sign), y + f32(15 * sign)});
        ygd.attach_component([2]f32, velocities, e, [2]f32{0.0, 0.0});

        randColour := rl.Color{
            u8(rand.uint32_range(120, 255*2)),
            u8(rand.uint32_range(120, 255*2)),
            u8(rand.uint32_range(120, 255*2)),
            0xFF
        };
        ygd.attach_component(box, boxes, e, box{{25.0, 25.0}, randColour});
    }
}

draw_entities :: proc(positions: ^ygd.SparseSet([2]f32), boxes: ^ygd.SparseSet(box))
{
    for idx in 0 ..< ygd.entity_count(box, boxes)
    {
        e := ygd.get_entity(box, boxes, idx);
        b := ygd.get_entity_component(box, boxes, e);
        pos := ygd.get_entity_component([2]f32, positions, e);

        rl.DrawRectangleV(
            rl.Vector2{pos[0] + f32(rl.GetScreenWidth() / 2), pos[1] + f32(rl.GetScreenHeight() / 2)},
            b.dim,
            b.colour
        );
    }
}