@testset "simplify_rules" begin
    @syms a b c d

    before = P(a + b + c ¦ d)
    after = P(a ¦ d) + P(b ¦ d) + P(c ¦ d)
    @eqtest M.simplify(before) == after

    before = P(a + b ¦ (c + d))
    after = P(a ¦ (c + d)) + P(b ¦ (c + d))
    @eqtest M.simplify(before) == after
end
