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
