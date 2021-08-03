
@testset "rules" begin
    # Example from https://youtu.be/pZkCecwE-xE.
    # For now, doing the mapping from symbols to integers manually.
    smoking = 1
    tar = 2
    cancer = 3
    genotype = 4
    smoking = 5
    edges = [
        smoking => tar,
        tar => cancer,
        genotype => smoking,
        genotype => cancer
    ]
    G = SimpleDiGraphFromIterator(Edge.(edges))

    G_without_in = Causality.without_incoming(G, Set([smoking, tar]))
    @test G_without_in == SimpleDiGraph(Edge.([tar => cancer, genotype => cancer]))

    @syms Σt(x) c s t
    before_rule3 = Σt(P(c¦d(s),d(t))P(t¦s))
    after_rule3 = Σt(P(c¦d(s))P(t¦s))
    # @test rewrite(G, before_rule3) == after_rule3
end
