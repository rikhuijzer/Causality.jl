using Causality
using Documenter
using LightGraphs
using Test

M = Causality

DocMeta.setdocmeta!(
    M,
    :DocTestSetup,
    :(using Causality);
    recursive=true
)

M._update_module_doc()
doctest(M)

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
include("undirected_paths.jl")
include("rules.jl")
include("multivar_predicate.jl")
include("simplify_rules.jl")
include("graphs.jl")
