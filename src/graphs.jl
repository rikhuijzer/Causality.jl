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
    d_separated(G::AbstractGraph, X::Int, Y::Int, Z::Set)::Bool

Return whether the elements in `Z` block all paths from `X` to `Y` in graph `G`.
In other words, whether `X` and `Y` are _d_-separated by `Z`, normally written as
`X ⊥⊥ Y ¦ Z`.

Specifically, return whether for all bi-directional paths `path` from `X` to `Y`
[^Bareinboim2015]:

1. `path` contains at least one arrow-emitting node that is in `Z` _or_
2. `path` contains at least one collision node that is outside `Z` and has no descendant
    in `Z`.

[^Bareinboim2015]: Bareinboim, E., & Pearl, J. (2016). Causal inference and the data-fusion problem. Proceedings of the National Academy of Sciences, 113(27), 7345-7352.

"""
function d_separated(G::AbstractGraph, X::Int, Y::Int, Z::Set; verbose=false)::Bool
    @assert isdisjoint(X, Y)
    @assert isdisjoint(X, Z)
    @assert isdisjoint(Y, Z)
    @assert length(nodes(G)) != 0
    return CausalInference.dsep(G, X, Y, Z; verbose)
end

function d_separated(G::AbstractGraph, X::Int, Y::Int, Z::Vector; verbose=false)::Bool
    return d_separated(G, X, Y, Set(Z); verbose)
end

function d_separated(G::AbstractGraph, X, Y, Z::Set; verbose=false)
    if length(X) == 1
        X = first(X)
    else
        error("Not implemented")
    end
    if length(Y) == 1
        Y = first(Y)
    else
        error("Not implemented")
    end
    d_separated(G, X, Y, Z; verbose)
end

function nodes(G::AbstractGraph)
    E = collect(edges(G))
    nodes = unique(union(getproperty.(E, :src), getproperty.(E, :dst)))
    return nodes
end

"""
    graph(edges::Vector{Pair{Symbol, Symbol}})::MetaDiGraph

Return a MetaDiGraph from the `edges` where all the vertices have a `:name` property.
See also `name2node`[@ref].

# Example
```jldoctest
julia> edges = [:U => :V, :V => :W];

julia> G = graph(edges);

julia> get_prop(G, 1, :name)
:U

julia> name2node(G, :U)
1
"""
function graph(edges::Vector{Pair{Symbol, Symbol}})::MetaDiGraph
    N = unique(union(first.(edges), last.(edges)))
    sym2int = Dict(zip(N, 1:length(N)))
    edges = [Edge(sym2int[src] => sym2int[dst]) for (src, dst) in edges]
    G = SimpleDiGraph(edges)
    G = MetaDiGraph(G)

    int2sym = Dict(zip(1:length(N), N))
    foreach(k -> set_prop!(G, k, :name, int2sym[k]), keys(int2sym))

    return G
end

"""
    name2node(G::MetaDiGraph, name::Symbol)::Int

Return the node for a given `name`.
"""
function name2node(G::MetaDiGraph, name::Symbol)::Int
    V = filter_vertices(G, :name, name)
    V = collect(V)
    @assert length(V) == 1
    return first(V)
end
