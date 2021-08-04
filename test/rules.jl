@testset "_arrow_emitting" begin
    # Seems unnecessary thanks to CausalInference.dsep.
    # Which is based on the algo in https://arxiv.org/abs/1304.1505.
    G = SimpleDiGraph(Edge.([(1 => 2), (3 => 2)]))
    paths = Causality._paths(G, Set(1), Set(3))
    @test paths == [[1, 2, 3]]
    path = first(paths)
    @test !C._arrow_emitting(G, path, Set(2))
    @test C._arrow_emitting(G, path, Set(3))
end

@testset "d_separated" begin
    # Examples from <https://doi.org/10.1073/PNAS.1510507113>.
    nodes = [:Z1, :W1, :X, :Z3, :W3, :Y, :Z2, :W2]
    mapping = Dict(zip(nodes, 1:length(nodes)))
    m = mapping
    E = [
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
    edges_num = [m[pair.first] => m[pair.second] for pair in E]
    G = SimpleDiGraph(Edge.(edges_num))
    X = m[:Z1]
    Y = m[:Y]
    Z = Set([m[:X], m[:Z3], m[:W2]])
    @test C.d_separated(G, X, Y, Z)
    Z = Set([m[:X], m[:Z3], m[:W3]])
    @test !(C.d_separated(G, X, Y, Z))
end

@testset "rules" begin
    # From https://youtu.be/pZkCecwE-xE.
    s = 1  # smoking
    t = 2  # tar
    c = 3  # cancer
    g = 4  # genotype
    s = 5  # smoking
    edges = [
        s => t,
        t => c,
        g => s,
        g => c
    ]
    G = SimpleDiGraphFromIterator(Edge.(edges))

    G_without_in = C.without_incoming(G, Set([s, t]))
    @test G_without_in == SimpleDiGraph(Edge.([t => c, g => c]))

    G_without_out = C.without_outgoing(G, Set([s, t]))
    @test G_without_out == SimpleDiGraph(Edge.([g => s, g => c]))

    
    # expected = Set([(X=
    # rule = 2
    # @test Set(C.d_separated_combinations(G, rule)) == expected

    @syms Σt(x) c s t
    # before_rule2 = Σt(P(c¦d(s),t)P(t¦d(s)))
    # after_rule2 = Σt(P(c¦d(s),d(t)) P(t¦d(s)))
    # @test rewrite(G, before_rule3) == after_rule3
end
