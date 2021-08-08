@testset "simplify_rules" begin
    @syms a b c d

    @eqtest M.causal_simplify(P(a + b + c, d)) == P(a, d) + P(b, d) + P(c, d)
    @eqtest M.causal_simplify(P(a + b, (c + d))) == P(a, (c + d)) + P(b, (c + d))

    @eqtest M.acrule2(P(a, b + Do(c) + Do(d))) == P(a, b + Do(c) + d)
end
