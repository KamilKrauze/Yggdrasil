package niflheim;

vec2 :: struct
{
    x:f32,
    y:f32,
}

rect :: struct
{
    w:f32,
    h:f32,
}

aabb_sweep :: proc(
    a_box: rect, a_pos: vec2, vel: vec2, 
    b_box: rect, b_pos:vec2) -> (bool, f32, vec2)
{
    inv_entry, inv_exit: vec2

    if vel.x > 0 {
        inv_entry.x = b_pos.x - (a_pos.x + a_box.w)
        inv_exit.x  = (b_pos.x + b_box.w) - a_pos.x
    } else {
        inv_entry.x = (b_pos.x + b_box.w) - a_pos.x
        inv_exit.x  = b_pos.x - (a_pos.x + a_box.w)
    }

    if vel.y > 0 {
        inv_entry.y = b_pos.y - (a_pos.y + a_box.h)
        inv_exit.y  = (b_pos.y + b_box.h) - a_pos.y
    } else {
        inv_entry.y = (b_pos.y + b_box.h) - a_pos.y
        inv_exit.y  = b_pos.y - (a_pos.y + a_box.h)
    }

    entry, exit: vec2

    if vel.x == 0 {
        entry.x = -1e30
        exit.x  = 1e30
    } else {
        entry.x = inv_entry.x / vel.x
        exit.x  = inv_exit.x / vel.x
    }

    if vel.y == 0 {
        entry.y = -1e30
        exit.y  = 1e30
    } else {
        entry.y = inv_entry.y / vel.y
        exit.y  = inv_exit.y / vel.y
    }

    entry_time := max(entry.x, entry.y)
    exit_time  := min(exit.x, exit.y)

    if entry_time > exit_time || entry_time < 0 || entry_time > 1 {
        return false, 1, vec2{0, 0}
    }

    normal := vec2{0, 0}

    if entry.x > entry.y {
        normal.x = inv_entry.x < 0 ? 1 : -1;
    } else {
        normal.y = inv_entry.y < 0 ? 1 : -1;
    }

    return true, entry_time, normal
}