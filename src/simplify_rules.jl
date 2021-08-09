# Similar to SU.jl simplify_rules.jl.

# Set union is commutative and associative like plus, so we can (ab)use the logic for plus.
# Using comma (,) instead of vertical line (|) in P(a | b) because | or my own defined ¦ are considered commutative by SU.

CONDITIONAL_PROBABILITY_RULES = [
    # P(A1 ∪ A2 ∪ A3 ... | B) = P(A1 | B) + P(A2 | B) + P(A3 | B) + ...
    # TODO: Check that sets ~~A are disjoint.
    @acrule P(+(~~A), ~~B) => +([P(a, ~~B...) for a in ~~A]...)
]

SSet = SU.Symbolic{<:Set}
SN = SU.Symbolic{<:Number}

conditional_simplifier() = SU.Chain(CONDITIONAL_PROBABILITY_RULES)

function causal_simplifier()
    return SU.If(SU.istree, SU.Fixpoint(conditional_simplifier()))
end

"""
    identify(G, query)

Given a graph `G` and a `query`, identify the causal effect if possible.
This retuns a probability expression involving only observed quantities
(Pearl, 2009; Corollary 3.4.2).

Unlike Pearl's do-calculus, the implementation in this package is, currently, unlikely to
be complete.
"""
function identify(x)
    simplifiers = [SU.serial_simplifier, causal_simplifier()]
    f = SU.Chain(simplifiers)
    simplified = SU.PassThrough(f)(x)
    return simplified
end
