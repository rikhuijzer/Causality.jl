struct DoRule
    G
    rule::SymbolicUtils.Rule
    predicate
end

function (dr::DoRule)(term)
    rhs = dr.rule.rhs
    @show rhs

    dic = SymbolicUtils.EMPTY_DICT
    @show dr.rule.matcher(println, (term,), dic)
    try
        return dr.rule.matcher((term,), dic) do bindings, n
            n == 1 ? (SymbolicUtils.@timer "RHS" rhs(bindings)) : nothing
        end
    catch err
        error("RuleRewriteError")
    end
end

"""
    @lhs_term(expr)

Return a Term for the rule lhs.

# Example
```jldoctest
julia> t = @lhs_term ~x + ~y => ~x
~x + ~y
```
"""
macro lhs_term(expr)
    lhs = expr.args[2]
    keys = Symbol[]
    lhs_term = SymbolicUtils.makepattern(lhs, keys)
    quote
        lhs_pattern = $(lhs_term)
    end
end

function wrapped_matcher(lhs_pattern)
    f = SymbolicUtils.matcher(lhs_pattern)
    function my_matcher(success, data, bindings)
        @show success
        @show data
        @show bindings
        return f(success, data, bindings)
    end
    return my_matcher
end

macro dorule(expr)
    @assert expr.head == :call && expr.args[1] == :(=>)
    lhs,rhs = expr.args[2], expr.args[3]
    keys = Symbol[]
    lhs_term = SymbolicUtils.makepattern(lhs, keys)
    unique!(keys)
    quote
        $(__source__)
        lhs_pattern = $(lhs_term)
        matcher = wrapped_matcher(lhs_pattern)
        SymbolicUtils.Rule($(QuoteNode(expr)),
             lhs_pattern,
             matcher,
             __MATCHES__ -> $(SymbolicUtils.makeconsequent(rhs)),
             SymbolicUtils.rule_depth($lhs_term))
    end
end

function success(bindings, n)
    function success(bindings, n)
        @show bindings
        @show n
        @show bindings
        @show SymbolicUtils.rhs(bindings)
        return n == 1 ? SymbolicUtils.rhs(bindings) : nothing
    end
end

function (r::SymbolicUtils.Rule)(term, success::Function)
    rhs = r.rhs

    try
        return r.matcher(success, (term,), EMPTY_DICT)
    catch err
        throw(RuleRewriteError(r, term))
    end
end
