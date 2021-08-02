@testset "syms" begin
    @syms u v w

    p_single_arg = @rule P(~u) => ~u + ~u
    @eqtest p_single_arg(P(u)) == (2u)

    p_multiple_args = @rule P(~u, ~v, ~w) => ~u + ~v + ~w
    @eqtest p_multiple_args(P(u, v, w)) == (u + v + w)
end
