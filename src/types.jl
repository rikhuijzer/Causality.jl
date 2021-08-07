# This is too much work to manually implement.
# Let's resort to using the existing logic for plus.

Add = SU.Add
add_t = SU.add_t
makeadd = SU.makeadd
promote_symtype = SU.promote_symtype

add_t(f, a::SSet, b::SSet) = SSet

function union(a::SSet, b::SSet)
    if a isa Add
        coeff, dict = makeadd(1, 0, b)
        @show symtype(a)
        T = promote_symtype(union, symtype(a), symtype(b))
        @show T
        return Add(add_t(a, b), union(a.coeff, coeff), _merge(union, a.dict, dict, filter=_iszero))
    elseif b isa Add
        return union(b, a)
    end
    Add(SSet, makeadd(1, 0, a, b)...)
end

union(a::SSet) = a

union(a::Add, b::Add) = Add(add_t(a,b),
                        union(a.coeff, b.coeff),
                        _merge(union, a.dict, b.dict, filter=_iszero))
