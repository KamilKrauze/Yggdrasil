package data

import ygd "../../framework"

cell_size :f32 = 32; // slightly bigger than 25

cell_coord :: proc(pos: ^[2]f32) -> [2]int {
    return {
        int(pos[0] / cell_size),
        int(pos[1] / cell_size),
    };
}


///Spatial entity grid for broad-phase collision detection 
Grid :: map[[2]int][dynamic]ygd.Entity;

update_grid :: proc(grid:^Grid, e:ygd.Entity, pos:^[2]f32)
{
    cell := cell_coord(pos);

    if !(cell in grid^) {
        grid^[cell] = make([dynamic]ygd.Entity);
    }

    list := grid^[cell];
    append(&list, e);
    grid^[cell] = list;
}

NearbyIterator :: struct {
    grid: ^Grid,
    base: [2]int,
    dx, dy: int,
    list: [dynamic]ygd.Entity,
    index: int,
    self: ygd.Entity,
}

nearby_begin :: proc(grid:^Grid, pos:^[2]f32, self:ygd.Entity) -> NearbyIterator {
    return NearbyIterator{
        grid = grid,
        base = cell_coord(pos),
        dx = -1,
        dy = -1,
        list = nil,
        index = 0,
        self = self,
    };
}

nearby_next :: proc(it:^NearbyIterator) -> (ygd.Entity, bool) {
    for {
        if it.list != nil && it.index < len(it.list) {
            e := it.list[it.index];
            it.index += 1;

            if e != it.self {
                return e, true;
            }
            continue;
        }

        // advance cell
        it.dy += 1;
        if it.dy > 1 {
            it.dy = -1;
            it.dx += 1;
        }

        if it.dx > 1 {
            return 0, false;
        }

        cell := [2]int{
            it.base[0] + it.dx,
            it.base[1] + it.dy,
        };

        if !(cell in it.grid^) {
            it.list = nil;
            continue;
        }

        it.list = it.grid^[cell];
        it.index = 0;
    }
}