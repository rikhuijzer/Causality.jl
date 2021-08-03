using Causality
using Documenter
using LightGraphs
using Test

DocMeta.setdocmeta!(
    Causality,
    :DocTestSetup,
    :(using Causality);
    recursive=true
)

Causality._update_module_doc()
doctest(Causality)

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
include("rules.jl")
