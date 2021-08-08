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
    @test M.d_separated(G, X, Y, Z)
    Z = Set([m[:X], m[:Z3], m[:W3]])
    @test !(M.d_separated(G, X, Y, Z))
end

@testset "without_in_out" begin
    # From https://youtu.be/pZkCecwE-xE.
    # See also https://youtu.be/9X4pR4jvKmM?t=1025 for the same example with more
    # explanation.
    s = 1  # smoking
    t = 2  # tar
    c = 3  # cancer
    g = 4  # genotype
    E = [
        s => t,
        t => c,
        g => s,
        g => c
    ]
    E = Edge.(E)
    G = SimpleDiGraphFromIterator(E)
    @test Set(M.nodes(G)) == Set([1, 2, 3, 4])

    G_without_in = M.without_incoming(G, Set([s, t]))
    @test G_without_in == SimpleDiGraph(Edge.([t => c, g => c]))

    G_without_out = M.without_outgoing(G, Set([s, t]))
    @test G_without_out == SimpleDiGraph(Edge.([g => s, g => c]))
end
