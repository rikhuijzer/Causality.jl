@testset "rule2" begin
    @syms u x z y

    # From the Causality book (2009) around page 86.
    edges = [
        :U => :X,
        :U => :Y,
        :X => :Z,
        :Z => :Y
    ]
    G = graph(edges)
    r = rule2(G)
    @eqtest r(P(y, x + Do(z))) == P(y, x + z)
    # @eqtest r(P(u, b + Do(c) + Do(d))) == P(a, b + Do(c) + d)

end
