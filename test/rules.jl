@testset "rule2" begin
    @syms u x z y

    # Example from Section 3.4.3 (Pearl, 2009).
    edges = [
        :U => :X,
        :U => :Y,
        :X => :Z,
        :Z => :Y
    ]
    G = graph(edges)
    @test [name2node(G, s) for s in [:U, :X, :Z, :Y]] == [1, 2, 3, 4]
    r = rule2(G)
    @eqtest r(P(y, x + Do(z))) == P(y, x + z)
    @eqtest r(P(z, Do(x))) == P(z, x)

end
