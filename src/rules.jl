struct EdgesMappings
    name2num::Dict  # Should be Base.ImmutableDict
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
    _product(X, Y)

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
function _product(X, Y)
    P = Iterators.product(X, Y)
    P = vcat(P...)
    return P
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

function d_separated(G::AbstractGraph, X::Set, Y::Set, Z::Set; verbose=false)
    return error("Not implemented.")
end

function nodes(G::AbstractGraph)
    E = collect(edges(G))
    nodes = unique(union(getproperty.(E, :src), getproperty.(E, :dst)))
    return nodes
end

"""
    rule2_applicable(G::SimpleDiGraph, Y, Z, X, W)::Bool

Return whether rule 2 is applicable given graph `G` with Y, Z, X and W.
In other words, return true if ``(Y \\perp Z | X, W)_{G_{\\overline{x} \\underline{z}}}``.
"""
function rule2_applicable(G::SimpleDiGraph, Y, Z, X, W)::Bool
    G = without_incoming(G, Set(X))
    G = without_outgoing(G, Set(Z))
    isempty(nodes(G)) && return false  # Or true? Not sure.
    return d_separated(G, Y, Z, X)
end

"""
    YZXW(Y::Int, Z::Int, X::Set{Int}, W::Set{Int})

Struct containing the nodes for the predicate checks which are based around ``(Y \\perp Z | X, W)``.
`Y` and `Z` are `Int`s, because `d_separated` cannot handle `Set`s yet.
"""
struct YZXW
    Y::Int
    Z::Int
    X::Set{Int}
    W::Set{Int}
end

"""
    bindings2yzxw(bindings, mapping::Dict)::YZXW

For all three of the rules, we have to check some predicate based around ``(Y \\perp Z | X, W)``.
This step goes from the expression (lowercase) to the predicate (uppercase).
"""
function bindings2yzxw(bindings, mapping::Dict)::YZXW
    Y = bindings[:y]
    Z = bindings[:z]
    X = bindings[:x]
    W = bindings[:w]
    return YZXW(Y, Z, X, W)
end

function rule2_checker(G::SimpleDiGraph)
    function rule2_applicable(bindings)
        Y, Z, X, W = bindings2yzxw(G, bindings)
        rule2_applicable(G, Y, Z, X, W)
    end

    function success(bindings, n)
        if n == 1
            rule2_applicable(bindings) || return nothing
            return rhs(bindings)
        else
            return nothing
        end
    end
    return success
end

"""
    rule2(eq)

Apply rule 2 once on `eq`.
"""
function rule2(eq)
    # First, I need to get the PR merged to allow creating rules with predicates.
    # Then, I need to implement src/simplify_rules.jl.
    r = @acrule P(~y * (Do(~x) + Do(~z) + ~~w)) => (~y * (Do(~x) + ~z + ~~w))
    return r(eq)
    move_do_forward = @rule (~w, Do(~x), Do(~y)) => (Do(~x), Do(~y), ~w)
    return r(eq)
    chain = SymbolicUtils.Chain([r, move_do_forward])
    rewriter = SymbolicUtils.Fixpoint(chain)
    # consequent = r(eq, rule2_checker(G))
    consequent = rewriter(eq)
    return consequent
end
