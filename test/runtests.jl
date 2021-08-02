using Causality
using Test

"""
    eqtest(expr)

Test equivalence for two symbolic expressions.
Source: SymbolicUtils runtest.jl.
"""
macro eqtest(expr)
    @assert expr.head == :call && expr.args[1] in [:(==), :(!=)]
    if expr.args[1] == :(==)
        :(@test isequal($(expr.args[2]), $(expr.args[3])))
    else
        :(@test !isequal($(expr.args[2]), $(expr.args[3])))
    end |> esc
end
SymbolicUtils.show_simplified[] = false

include("syms.jl")