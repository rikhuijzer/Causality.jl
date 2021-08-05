module Causality

import CausalInference
import Combinatorics

using Base
using Reexport
@reexport using LightGraphs
@reexport using SymbolicUtils

function _update_module_doc()
    path = joinpath(@__DIR__, "..", "README.md")
    text = read(path, String)
    @doc text Causality
end
_update_module_doc()

include("syms.jl")
export P, d, ¦

include("undirected_paths.jl")
include("rules.jl")

include("multivar_predicate.jl")
export success

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
