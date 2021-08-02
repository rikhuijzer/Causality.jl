# Not using `@syms` in this file to be more flexible (allowing vargs) and avoid using `@doc`.

"""
    P(x)
    P(x, y)
    P(vargs...)

A named variable to denote probability.
"""
P = SymbolicUtils.Sym{SymbolicUtils.FnType{Tuple, Number}}(:P)

@syms d(x)
sym_given = @syms |(u, v)

function _document_syms()

    text = """
        d(x)

        Do-operator.
        Unfortunately, the Julia parser will try to parse `do`, so `d` seemed to be most natural alternative.
        """
    @doc text d

    text = """
        u | v

        `u` given `v`.
        """
    # I have no idea 
    # @doc text 
end

_document_syms()
