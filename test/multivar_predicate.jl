@testset "multivar_predicate" begin
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

    @eqtest r1(sin(2a), define_success) == 2cos(a)*sin(a)
    @eqtest r1(sin(2b), define_success) == nothing

end
