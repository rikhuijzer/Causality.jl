@testset "syms" begin
    @syms x u v w

    @testset "allowed number of args" begin
        # Probably, there is an easier test for this possible.
        p_single_arg = @rule P(~u) => ~u + ~u
        @eqtest p_single_arg(P(u)) == (2u)

        p_multiple_args = @rule P(~u, ~v, ~w) => ~u + ~v + ~w
        @eqtest p_multiple_args(P(u, v, w)) == (u + v + w)

        d_single_arg = @rule Do(~x) => ~x + ~x
        @eqtest d_single_arg(Do(x)) == (2x)

        given_single_arg = @rule ¦(~u, ~v) => ~u + ~v
        @eqtest given_single_arg(u ¦ v) == (u + v)
    end
end
