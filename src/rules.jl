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

function rule2(G::MetaDiGraph, y, z, x, w)
    return true
end

function rule2(G::MetaDiGraph)
    # Make sure to put a simplified version at the lhs
    # (https://github.com/JuliaSymbolics/SymbolicUtils.jl/issues/331).

    r = @acrule P(~y, ~z + Do(~x) + Do(~w)) => rule2(G, ~y, ~z, ~x, ~w) ? P(~y, ~z + Do(~x) + ~w) : nothing
    return r
end

