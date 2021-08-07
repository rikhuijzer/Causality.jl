# Similar to SU.jl simplify_rules.jl.

# Set union is commutative and associative like plus, so we can (ab)use the logic for plus.

CONDITIONAL_PROBABILITY_RULES = [
    # P(A1 ∪ A2 ∪ A3 ... | B) = P(A1 | B) + P(A2 | B) + P(A3 | B) + ...
    # TODO: Check that sets A are disjoint.
    @acrule P(+(~~A) ¦ ~~B) => +([P(a, ~~B...) for a in ~~A]...)
    # +(P(~~A ¦ ~~B))
]

SSet = SU.Symbolic{<:Set}

conditional_simplifier() = SU.Chain(CONDITIONAL_PROBABILITY_RULES)

function default_simplifier()
    SU.Postwalk(conditional_simplifier())
end

serial_simplifier() = SU.If(SU.istree, SU.Fixpoint(conditional_simplifier()))

function simplify(x)
    f = serial_simplifier()
    SU.PassThrough(f)(x)
end
