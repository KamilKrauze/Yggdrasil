package yggdrasil

Entity :: u64

@(private)
next_entity: Entity = 0

create_entity :: proc() -> Entity {
    e := next_entity
    next_entity += 1
    return e
}