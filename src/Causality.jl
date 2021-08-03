module Causality

using Base
using Reexport
@reexport using LightGraphs
@reexport using SymbolicUtils

function _update_module_doc()
    path = joinpath(pkgdir(Causality), "README.md")
    text = read(path, String)
    @doc text Causality
end
_update_module_doc()

include("syms.jl")
export P, d, ¦

include("rules.jl")

function rewrite_sin()
    @syms w z
    r1 = @rule sin(2(~x)) => 2sin(~x) * cos(~x)
    r1(sin(2z))
end

function rewrite_do()
    @syms z d(x) redo(x)

    r = @rule d(~x) => redo(~x)
    r(d(z))
end

end # module
