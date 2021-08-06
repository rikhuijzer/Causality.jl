@testset "multivar_predicate" begin
    let
        @syms w a b α::Real β::Real

        r1 = @rule sin(2(~x)) => 2sin(~x)*cos(~x)

        function define_success(rhs)
            function mypredicate(bindings)::Bool
                return bindings[:x] === a
            end

            function success(bindings, n)
                if n == 1
                    return mypredicate(bindings) ? rhs(bindings) : nothing
                else
                    return nothing
                end
            end
            return success
        end

        @eqtest r1(sin(2a)) == 2cos(a)*sin(a)
        @eqtest r1(sin(2a), define_success) == 2cos(a)*sin(a)
        @eqtest r1(sin(2b), define_success) == nothing
    end

    let
        @syms x a b z

        acr = @acrule((~a)^(~u) * (~a)^(~v) => (~a)^(~u + ~v))

        function define_success(rhs)
            function mypredicate(bindings)::Bool
                return bindings[:u] === a
            end

            function success(bindings, n)
                if n == 1
                    return mypredicate(bindings) ? rhs(bindings) : nothing
                else
                    return nothing
                end
            end
            return success
        end

        @eqtest acr(x^a * x^z) == x^(a + z)
        @eqtest acr(x^a * x^z, define_success) == x^(a + z)
        @eqtest acr(x^b * x^z, define_success) == nothing
    end


end
