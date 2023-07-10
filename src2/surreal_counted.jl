
struct CountedSurrealSet <: SurrealSet
	e::SubSe
end

autoSurrealSet(x::SubSe) = CountedSurrealSet(x)

<=(x::CountedSurrealSet, y::CountedSurrealSet) = x.e <= y.e
<=(x::CountedSurrealSet, y::SingularSurrealSet) = x.e <= y.s
<=(x::SingularSurrealSet, y::CountedSurrealSet) = x.s <= y.e

<(x::CountedSurrealSet, y::CountedSurrealSet) = x.e < y.e
<(x::CountedSurrealSet, y::SingularSurrealSet) = x.e < y.s
<(x::SingularSurrealSet, y::CountedSurrealSet) = x.s < y.e
<(x::CountedSurrealSet, y::Surreal) = x.e < y
<(x::Surreal, y::CountedSurrealSet) = x < y.e

isequal(x::CountedSurrealSet, y::CountedSurrealSet) = isequal(x.e, y.e)
Base.show(io::IO, x::CountedSurrealSet) = print(io, x.e)
isDyadic(x::CountedSurrealSet) = false

for f in [
	:isLimited,
	:hasUpperLimit,
	:hasLowerLimit,
	:birthday,
]
	eval(quote
		$f(x::CountedSurrealSet) = $f(x.e)
	end)
end

_simplify(e) = autoSurrealSet(prettifyRewriter(simplifyRewriter(e)))

function simplify(x::CountedSurrealSet, upper::Bool)
	# in the upper half we are interested in the lower bound etc.
	local e = upper ? try_lb_s(x.e) : try_ub_s(x.e)
	return _simplify(e)
end

-(x::CountedSurrealSet) = CountedSurrealSet(-x.e)

@commu +(x::CountedSurrealSet, y::Surreal) = CountedSurrealSet(x.e + y)
+(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(x.e + y.e)

@commu *(x::CountedSurrealSet, y::Surreal) = CountedSurrealSet(x.e * y)
*(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(x.e * y.e)

@commu leftUnion(x::CountedSurrealSet, y::SingularSurrealSet) = _simplify(ub_s(uu_s(x.e, y.s)))
leftUnion(x::CountedSurrealSet, y::CountedSurrealSet) = _simplify(ub_s(uu_s(x.e, y.e)))

@commu rightUnion(x::CountedSurrealSet, y::SingularSurrealSet) = _simplify(lb_s(lu_s(x.e, y.s)))
rightUnion(x::CountedSurrealSet, y::CountedSurrealSet) = _simplify(lb_s(lu_s(x.e, y.e)))

