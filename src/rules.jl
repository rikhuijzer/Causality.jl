"""
    rule2_applicable(G::SimpleDiGraph, Y, Z, X, W)::Bool

Return whether rule 2 is applicable given graph `G` with Y, Z, X and W.
In other words, return true if ``(Y \\perp Z | X, W)_{G_{\\overline{x} \\underline{z}}}``.
"""
function rule2_applicable(G::AbstractGraph, Y, Z, X, W)::Bool
    G = without_incoming(G, Set(X))
    G = without_outgoing(G, Set(Z))
    return d_separated(G, Y, Z, Set(X))
end

sym2uppercase(s::Symbol) = Symbol(uppercase(string(s)))
name2node(G, s::SymbolicUtils.Sym) = name2node(G, sym2uppercase(s.name))
name2node(G, S::AbstractArray) = Set([name2node(G, s) for s in S])
name2node(G, s::Set) = s

function rule2(G::MetaDiGraph, y, z, x, w)
    Y = name2node(G, y)
    Z = name2node(G, z)
    X = name2node(G, x)
    W = name2node(G, w)
    out = rule2_applicable(G, Y, Z, X, W)
    return out
end

function rule2(G::MetaDiGraph)
    # Make sure to put a simplified version at the lhs
    # This even holds when not using the infix operator.
    # So, +(a, b), in nested expressions, is not always the same as +(b, a).
    # (https://github.com/JuliaSymbolics/SymbolicUtils.jl/issues/331).

    forms = [
        # Rule 2 (Pearl, 2009; eq. 3.32) where x is empty.
        @acrule(P(~y, +(~~w, Do(~z))) => rule2(G, ~y, ~z, ~~w, Set()) ? P(~y, +(~z, ~~w...)) : nothing),
        # Rule 2 (Pearl, 2009; eq. 3.32) where x and w are empty.
        @acrule(P(~y, Do(~z)) => rule2(G, ~y, ~z, Set(), Set()) ? P(~y, ~z) : nothing)
    ]

    return SU.Chain(forms)
end

