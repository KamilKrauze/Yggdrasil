package framework

SparseSet :: struct($ComponentT : typeid)
{
    dense: [dynamic]Entity,
    data: [dynamic]ComponentT,
    sparse: [dynamic]u32, // Maps entity to dense index;
}

attach_component :: proc($ComponentT: typeid, dataset: ^SparseSet(ComponentT), e:Entity, component: ComponentT)
{
    sparse_size:u64 = u64(len(dataset.sparse));
    if e >= sparse_size
    {
        new_size:u64 = e + 4;
        resize(&dataset.sparse, new_size);
        
        new_sparse_size := u64(len(dataset.sparse));
        for i in sparse_size+1 ..<new_sparse_size
        {
            dataset.sparse[i] = INVALID
        }
    }

    dataset.sparse[e] = u32(len(dataset.dense));
    append(&dataset.dense, e);
    append(&dataset.data, component);
}

detach_component :: proc($ComponentT:typeid, dataset: ^SparseSet(ComponentT), e:Entity)
{
    if has_entity(ComponentT, dataset, e)
    {
        ordered_remove(&dataset.data, get_entity_component(ComponentT, dataset, e));
        ordered_remove(&dataset.dense, e);
        dataset.sparse[e] = INVALID;
    }
}

cleanup :: proc($ComponentT:typeid, dataset: ^SparseSet(ComponentT))
{
    assert(dataset != nil);
    clear(&dataset.dense);
    clear(&dataset.data);
    clear(&dataset.sparse);
}

has_entity :: proc($T:typeid, dataset:^SparseSet(T), e:Entity) -> bool
{
    return e < u64(len(dataset.sparse)) && dataset.sparse[e] != INVALID;
}

get_entity :: proc($T:typeid, dataset:^SparseSet(T), index: int) -> Entity
{
    return dataset.dense[index];
}

get_component_by_index :: proc($ComponentT: typeid, dataset: ^SparseSet(ComponentT), idx: int) -> ^ComponentT
{
    return &dataset.data[idx];
}

get_entity_component :: proc($T: typeid, dataset: ^SparseSet(T), e:Entity) -> ^T
{
    assert(has_entity(T, dataset, e) == true, "Given sparse-set does not contain entity");
    return &dataset.data[dataset.sparse[e]];
}

entity_count :: proc($T:typeid, dataset : ^SparseSet(T)) -> int
{
    return len(dataset.dense);
}