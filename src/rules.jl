struct EdgesMappings
    name2num::Dict
    num2name::Dict
end

function edges_mappings(edges::AbstractVector)
    L = first.(edges)
    R = last.(edges)
    names = unique([L; R])
    numbers = 1:length(names)
    name2num = Dict(zip(names, numbers))
    num2name = Dict(zip(numbers, names))
    return EdgesMappings(name2num, num2name)
end

function edge2num(mappings::EdgesMappings, edge::Pair)
    return mappings.name2num[edge.first] => mappings.name2num[edge.second]
end

function edges2nums(mappings::EdgesMappings, edges::AbstractVector)
    return [edge2num(mappings, e) for e in edges]
end

"""
    without_incoming(G::AbstractGraph, X::Set)

Return a graph where all the arrows pointing to nodes in the set `X` in graph `G` have been
removed.
"""
function without_incoming(G::AbstractGraph, X::Set)
    E = collect(LightGraphs.edges(G))
    filter!(e -> !(e.dst in X), E)
    return SimpleDiGraph(E)
end

"""
    without_outgoing(G::AbstractGraph, X::Set)

Return a graph where all the arrows coming from nodes in the set `X` in graph `G` have been
removed.
"""
function without_outgoing(G::AbstractGraph, X::Set)
    E = collect(LightGraphs.edges(G))
    filter!(e -> !(e.src in X), E)
    return SimpleDiGraph(E)
end

"""
    _arrow_emitting(path, Z::Set)::Bool

Return whether one of the nodes emits an arrow **on the path** and is in `Z`.
This blocks the path, because the node that emits an arrow overrides all other information.
"""
function _arrow_emitting(path, Z::Set)::Bool
    # arrow_emitting_nodes = 
end

"""
    _paths(G::SimpleGraph, X::Int, Y::Int)

Return all paths from `X` to `Y` in the undirected graph G.

# Example
```jldoctest
julia> G = SimpleGraph(Edge.([(1, 2), (2, 3), (2, 4), (3, 4)]))
{4, 4} undirected simple Int64 graph
```
"""
function _paths(G::SimpleGraph, X::Int, Y::Int)
    tree = dfs_tree(G, X)
    @show collect(edges(tree))
    # Thanks to sbromberger in https://github.com/JuliaGraphs/LightGraphs.jl/issues/599.
    P = dijkstra_shortest_paths(G, X; allpaths=true, trackvertices=true)
end

"""
    _product(X::Set, Y::Set)

# Example
```jldoctest
julia> Causality._product(Set([1, 2]), Set([3, 4])) |> sort
4-element Vector{Tuple{Int64, Int64}}:
 (1, 3)
 (1, 4)
 (2, 3)
 (2, 4)
```
"""
function _product(X::Set, Y::Set)
    P = Iterators.product(X, Y)
    P = vcat(P...)
    return P
end

"""
    _paths(G::SimpleDiGraph, X::Set, Y::Set)

Return all bi-directional paths from nodes in `X` to nodes in `Y`.
Note that this **cannot** be calculated by combining the paths from `X` to `Y` in a DAG in
both directions.
To see why this is so, consider the graph `X -> V <- Y` which should return one path.
"""
function _paths(G::AbstractGraph, X::Set, Y::Set)
    undirected_graph = SimpleGraph(G)
    sources_destinations = _product(X, Y)
    paths = [_paths(src, dst) for (src, dst) in sources_destinations]
    paths = vcat(paths...)
end

"""
    d_separate(G::AbstractGraph, X::Set, Y::Set, Z::Set)::Bool

Return whether `Z` blocks all paths from `X` to `Y` in graph `G`.
In other words, whether `X` and `Y` are _d_-separated by `Z`, normally written as
`X ⊥⊥ Y ¦ Z`.

Specifically, return whether for all bi-directional paths `path` from `X` to `Y` [^Bareinboim2015]:

1. `path` contains at least one arrow-emitting node that is in `Z` _or_
2. `path` contains at least one collision node that is outside `Z` and has no descendant in `Z`.

[^Bareinboim2015]: Bareinboim, E., & Pearl, J. (2016). Causal inference and the data-fusion problem. Proceedings of the National Academy of Sciences, 113(27), 7345-7352.

"""
function d_separate(G::AbstractGraph, X::Set, Y::Set, Z::Set)::Bool
    @assert isdisjoint(X, Y)
    @assert isdisjoint(X, Z)
    @assert isdisjoint(Y, Z)
    forward_paths = paths(G, X, Y)
    backward_paths = paths(reverse(G), X, Y)
    # For all paths p from X to Y
    # test whether
    # p contains at least one arrow-emitting node that is in Z or
    # p contains at least one collision node that is outside Z and has no descendant in Z.
end

function apply_rule3(G::AbstractGraph, ex)
    
end
