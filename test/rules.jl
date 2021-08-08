@testset "rule2" begin
    @syms a b c d e

    G = MetaDiGraph()
    r = rule2(G)
    @eqtest r(P(a, b + Do(c) + Do(d))) == P(a, b + Do(c) + d)
end
