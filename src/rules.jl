"""
    rule2_applicable(G::SimpleDiGraph, Y, Z, X, W)::Bool

Return whether rule 2 is applicable given graph `G` with Y, Z, X and W.
In other words, return true if ``(Y \\perp Z | X, W)_{G_{\\overline{x} \\underline{z}}}``.
"""
function rule2_applicable(G::AbstractGraph, Y, Z, X, W)::Bool
    G = without_incoming(G, Set(X))
    G = without_outgoing(G, Set(Z))
    isempty(nodes(G)) && return false  # Or true? Not sure.
    return d_separated(G, Y, Z, X)
end

sym2uppercase(s::Symbol) = Symbol(uppercase(string(s)))
sym2uppercase(s::SymbolicUtils.Sym{Number, Nothing}) = sym2uppercase(s.name)

function rule2(G::MetaDiGraph, y, z, x; w=nothing)
    Y = name2node(G, sym2uppercase(y))
    @show Y
    Z = name2node(G, sym2uppercase(z))
    Z = Set(Z)
    X = name2node(G, sym2uppercase(x))
    W = isnothing(w) ? Set() : name2node(G, sym2uppercase(w))
    out = rule2_applicable(G, Y, Z, X, W)
    @show out
    return out
end

function rule2(G::MetaDiGraph)
    # Make sure to put a simplified version at the lhs
    # (https://github.com/JuliaSymbolics/SymbolicUtils.jl/issues/331).

    r = @acrule P(~y, ~z + Do(~x)) => rule2(G, ~y, ~z, ~x) ? P(~y, ~z + ~x) : nothing
    return r
end

