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

Return whether one of the nodes emits an arrow [^emit_note] and is in `Z`.
This blocks the path, because the node that emits an arrow overrides all other information.

[^emit_note]: Note that the arrow has to be emitted on the path.
    So, the the destination has to also be on the path.
"""
function _arrow_emitting(G, path, Z::Set)::Bool
    E = collect(edges(G))
    # Arrow has to be fully on the path.
    filter!(e -> (e.src in path && e.dst in path), E)
    # Arrow has to be in `Z`.
    filter!(e -> (e.src in Z), E)
    return length(E) == 0 ? false : true
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
    _paths(G::SimpleDiGraph, X::Set, Y::Set)

Return all bi-directional paths from nodes in `X` to nodes in `Y`.
Note that this **cannot** be calculated by combining the paths from `X` to `Y` in a DAG in
both directions.
To see why this is so, consider the graph `X -> V <- Y`, which should return one path.
"""
function _paths(G::AbstractGraph, X::Set, Y::Set)
    undirected_graph = SimpleGraph(G)
    sources_destinations = _product(X, Y)
    paths = [undirected_paths(undirected_graph, s, d) for (s, d) in sources_destinations]
    paths = vcat(paths...)
    return paths
end

"""
    d_separated(G::AbstractGraph, X::Set, Y::Set, Z::Set)::Bool

Return whether the elements in `Z` block all paths from `X` to `Y` in graph `G`.
In other words, whether `X` and `Y` are _d_-separated by `Z`, normally written as
`X ⊥⊥ Y ¦ Z`.
Note that when ``Z = \\{ A, B \\}``, then `X ⊥⊥ Y ¦ Z` can also be written as
`X ⊥⊥ Y ¦ A, B`.

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

function _Y_Z_pairs(N::AbstractVector)
    P = _product(N, N)
    filter!(p -> first(p) != last(p), P)
    return P
end

"""
    _X_Y_Z_W_tuples(N, Y, Z)

Find all possible combinations for `Y ⊥⊥ Z ¦ X, W` given all the nodes `N` and `Y` and `Z`.
Note that, in the do-calculus rules, `W` can be empty, but `X` cannot.
(X should not be empty, it seems, because do(x) where x is empty makes no sense.)

# Example
```jldoctest
julia> N = 1:4;

julia> Vector{Any}(Causality._Y_Z_X_W_tuples(N, 1, 2)) |> sort
3-element Vector{Any}:
 (Y = 1, Z = 2, X = [3], W = [4])
 (Y = 1, Z = 2, X = [3, 4], W = Int64[])
 (Y = 1, Z = 2, X = [4], W = [3])
```
"""
function _Y_Z_X_W_tuples(N, Y, Z)
    rest = setdiff(setdiff(N, Y), Z)
    W = collect(Combinatorics.powerset(rest))
    YZXWs = map(W) do w
        X = setdiff(rest, w)
        return (; Y, Z, X, W=w)
    end
    YZXWs = filter!(YZXW -> !isempty(YZXW.X), YZXWs)
    return YZXWs
end

"""
    _Y_Z_X_W_tuples(N, YZs)

Find all possible combinations for `Y ⊥⊥ Z ¦ X, W` given pairs of Y and Z.

# Example
```jldoctest
julia> N = 1:4;

julia> YZs = [[1, 2]];

julia> Vector{Any}(Causality._Y_Z_X_W_tuples(N, YZs)) |> sort
3-element Vector{Any}:
 (Y = 1, Z = 2, X = [3], W = [4])
 (Y = 1, Z = 2, X = [3, 4], W = Int64[])
 (Y = 1, Z = 2, X = [4], W = [3])
```
"""
function _Y_Z_X_W_tuples(N, YZs)
    YZXWs = [_Y_Z_X_W_tuples(N, Y, Z) for (Y, Z) in YZs]
    YZXWs = collect(Iterators.flatten(YZXWs))
    return YZXWs
end

"""
    d_separated_combinations(G::SimpleDiGraph, rule::Symbol)

Naive method to find all valid _d_-separated combinations for graph `G`.
This is used for generating a set of rules for which the _d_-separation holds.
Much more efficient would be to use the predicates for matching from SymbolicUtils with
memoize.
However, the matcher doesn't seem expressive enough (yet) to handle this.
"""
function d_separated_combinations(G::SimpleDiGraph, rule::Symbol)
    N = nodes(G)
    # Since only X::Int and Y::Int is implemented, this is relatively straightforward.
    YZs = _Y_Z_pairs(N)
    YZXWs = _Y_Z_X_W_tuples(N, YZs)
    if rule == :rule2
        valid_separations = map(YZXWs) do YZXW
            Y, Z, X, W = YZXW
            @show YZXW
            G = without_incoming(G, Set(X))
            G = without_outgoing(G, Set(Z))
            isempty(nodes(G)) && return missing
            if d_separated(G, Y, Z, X)
                # @show edges(G) |> collect
                # @show YZXW
                return YZXW
            end
            return missing
        end
        valid_separations = collect(skipmissing(valid_separations))
        return valid_separations
    end
    error("Not implemented")
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
    rule2()

# Example
```jldoctest
julia> @syms y x z w v;

julia> r = Causality.rule2();

julia> eq = P(y¦d(x),d(z),w,v);

julia> r(eq)
P(y | d(x), z, SymbolicUtils.Symbolic{Number}[w, v])
```
"""
function rule2()
    r = @rule P(~y¦d(~x),d(~z),~~w) => P(~y¦d(~x),~z,~~w)
end
