@testset "undirected_paths" begin
    G = SimpleGraph(Edge.([(1, 2), (2, 3), (2, 4), (3, 4)]))
    expected = Set([[1, 2], [1, 2, 3]])
    @test Set(Causality.undirected_paths_search(G, 1, 4)) == expected
end
