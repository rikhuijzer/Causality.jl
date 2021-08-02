module Causality

using Base
using Reexport
@reexport using SymbolicUtils

include("syms.jl")
export P, d, ¦

include("rules.jl")
export NodeSet

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
