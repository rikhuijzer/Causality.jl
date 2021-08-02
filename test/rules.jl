
@testset "rules" begin
    @test NodeSet("a") == NodeSet(Set([Symbol("a")]))
end
