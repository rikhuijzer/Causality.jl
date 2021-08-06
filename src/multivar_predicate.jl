"""
    success(rhs)

An example success function.
This is an example of how to add a predicate to check the bindings before reporting a match.
"""
function success(rhs)
    mypredicate(bindings) = true

    function success(bindings, n)
        @show bindings
        @show n
        @show rhs(bindings)
        if n == 1
            mypredicate(bindings) || return nothing
            return rhs(bindings)
        else
            return nothing
        end
    end
    return success
end

"""
    (r::SymbolicUtils.Rule)(term, success::Function)

Allow for overriding the success function to check a predicate inside it.
"""
function (r::SymbolicUtils.Rule)(term, success::Function)
    rhs = r.rhs
    success_closure = success(rhs)

    try
        return r.matcher(success_closure, (term,), SymbolicUtils.EMPTY_DICT)
    catch err
        throw(SymbolicUtils.RuleRewriteError(r, term))
    end
end

"""
    (acr::SymbolicUtils.ACRule)(term, success)

Same as (r::SymbolicUtils.Rule)(term, success::Function) but then for an ACRule.
"""
function (acr::SymbolicUtils.ACRule)(term, success)
    Rule = SymbolicUtils.Rule
    istree = SymbolicUtils.istree
    operation = SymbolicUtils.operation
    symtype = SymbolicUtils.symtype
    arguments = SymbolicUtils.arguments
    Term = SymbolicUtils.Term
    similarterm = SymbolicUtils.similarterm

    r = Rule(acr)
    if !istree(term)
        r(term)
    else
      f = operation(term)
      # Assume that the matcher was formed by closing over a term
      if f != operation(r.lhs) # Maybe offer a fallback if m.term errors.-
          return nothing
      end

      T = symtype(term)
      args = arguments(term)

      itr = acr.sets(eachindex(args), acr.arity)

      for inds in itr
          result = r(Term{T}(f, @views args[inds]), success)
          if !isnothing(result)
              # Assumption: inds are unique
              length(args) == length(inds) && return result
              return similarterm(term, f, [result, (args[i] for i in eachindex(args) if i ∉ inds)...], symtype(term))
          end
      end
  end
end
