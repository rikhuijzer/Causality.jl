module Causality

import Base: union
import CausalInference
import Combinatorics

using Base
using Reexport
@reexport using LightGraphs
@reexport using MetaGraphs
@reexport using SymbolicUtils

function _update_module_doc()
    path = joinpath(@__DIR__, "..", "README.md")
    text = read(path, String)
    @doc text Causality
end
_update_module_doc()

SU = SymbolicUtils
export SU

include("syms.jl")
export P, Do, ¦

include("undirected_paths.jl")
include("multivar_predicate.jl")
include("graphs.jl")
export graph, name2node

include("rules.jl")
export rule2

include("simplify_rules.jl")

end # module
