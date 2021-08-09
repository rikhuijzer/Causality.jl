@testset "conditional_probability_rules" begin
    @syms a b c d

    @eqtest M.identify(P(a + b + c, d)) == P(a, d) + P(b, d) + P(c, d)
    @eqtest M.identify(P(a + b, (c + d))) == P(a, (c + d)) + P(b, (c + d))
end
