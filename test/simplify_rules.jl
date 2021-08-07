@testset "simplify_rules" begin
    @syms A B C D

    before = P(A + B + C ¦ D)
    after = P(A, D) + P(B, D) + P(C, D)
    @eqtest M.simplify(before) == after
end
