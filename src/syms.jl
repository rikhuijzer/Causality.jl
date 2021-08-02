# Not using `@syms` in this file to be more flexible (allowing vargs) and avoid using `@doc`.
# Use macroexpand(Main, :(@syms f(x))) to see what @syms would generate.

"""
    P(x)
    P(x, y)
    P(vargs...)

A named variable to denote probability.
"""
const P = SymbolicUtils.Sym{SymbolicUtils.FnType{Tuple, Number}}(:P)


"""
    d(x)

Do-operator.
Pearl denotes this operator with `do`.
However, Julia's parser already uses `do`, so `d` seemed to be the most natural alternative.
"""
const d = SymbolicUtils.Sym{(SymbolicUtils.FnType){Tuple{Number}, Number}}(:d)

sym_given = @syms |(u, v)

function _document_syms()
    text = """
        u | v

        `u` given `v`.
        """
    # I have no idea 
    # @doc text 
end
