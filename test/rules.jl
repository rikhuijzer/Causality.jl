@testset "_arrow_emitting" begin
    # Seems unnecessary thanks to CausalInference.dsep.
    # Which is based on the algo in https://arxiv.org/abs/1304.1505.
    G = SimpleDiGraph(Edge.([(1 => 2), (3 => 2)]))
    paths = Causality._paths(G, Set(1), Set(3))
    @test paths == [[1, 2, 3]]
    path = first(paths)
    @test !Causality._arrow_emitting(G, path, Set(2))
    @test Causality._arrow_emitting(G, path, Set(3))
end

@testset "d_separated" begin
    nodes = [:Z1, :W1, :X, :Z3, :W3, :Y, :Z2, :W2]
    mapping = Dict(zip(nodes, 1:length(nodes)))
    m = mapping
    edges = [
        :Z1 => :W1,
        :W1 => :X,
        :Z1 => :Z3,
        :Z3 => :X,
        :Z2 => :Z3,
        :Z2 => :W2,
        :Z3 => :Y,
        :W2 => :Y,
        :W3 => :Y,
        :X => :W3
    ]
    edges_num = [m[pair.first] => m[pair.second] for pair in edges]
    G = SimpleDiGraph(Edge.(edges_num))

    # Examples from <https://doi.org/10.1073/PNAS.1510507113>.
    X = m[:Z1]
    Y = m[:Y]
    Z = Set([m[:X], m[:Z3], m[:W2]])
    @test Causality.d_separated(G, X, Y, Z)
    Z = Set([m[:X], m[:Z3], m[:W3]])
    @test !(Causality.d_separated(G, X, Y, Z))
end

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

    G_without_out = Causality.without_outgoing(G, Set([smoking, tar]))
    @test G_without_out == SimpleDiGraph(Edge.([genotype => smoking, genotype => cancer]))

    @syms Σt(x) c s t
    before_rule3 = Σt(P(c¦d(s),d(t))P(t¦s))
    after_rule3 = Σt(P(c¦d(s))P(t¦s))
    # @test rewrite(G, before_rule3) == after_rule3
end
