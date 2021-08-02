@testset "syms" begin
    @syms x u v w

    # Validate the allowed number of args (probably easier method possible).
    p_single_arg = @rule P(~u) => ~u + ~u
    @eqtest p_single_arg(P(u)) == (2u)

    p_multiple_args = @rule P(~u, ~v, ~w) => ~u + ~v + ~w
    @eqtest p_multiple_args(P(u, v, w)) == (u + v + w)

    d_single_arg = @rule d(~x) => ~x + ~x
    @eqtest d_single_arg(d(x)) == (2x)
end
