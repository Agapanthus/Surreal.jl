
struct CountedSurrealSet <: SurrealSet
	e::SubSe
end

autoSurrealSet(x::SubSe) = CountedSurrealSet(x)

<=(x::CountedSurrealSet, y::CountedSurrealSet) = TODO
<(x::CountedSurrealSet, y::CountedSurrealSet) = TODO

function <(x::CountedSurrealSet, y::Surreal)
	local hul = hasUpperLimit(x)
	!hul && (isNegative(y) || isFinite(y)) && return false
	hul && isPositive(y) && isInfinite(y) && return true

	# risk of infinite recursion
	# getLUB(x) < y && return true

	@show x y
	TODO
end

function <(x::Surreal, y::CountedSurrealSet)
	local hll = hasLowerLimit(y)
	!hll && (isPositive(x) || isFinite(x)) && return false
	hll && isNegative(x) && isInfinite(x) && return true

	@show x y
	TODO
end

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

function simplify(x::CountedSurrealSet, upper::Bool)
	local res = CountedSurrealSet(simplifyRewriter(x.e))
	isSurreal(res.e) && return SingularSurrealSet(left(res.e))
	return res
end

-(x::CountedSurrealSet) = CountedSurrealSet(-x.e)

@commu +(x::CountedSurrealSet, y::Surreal) = CountedSurrealSet(x.e + y)
+(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(x.e + y.e)

@commu *(x::CountedSurrealSet, y::Surreal) = CountedSurrealSet(x.e * y)
*(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(x.e * y.e)

@commu lowerUnion(x::CountedSurrealSet, y::SingularSurrealSet) = autoSurrealSet(simplifyRewriter(lu_s(x.e, y.s)))
lowerUnion(x::CountedSurrealSet, y::CountedSurrealSet) = autoSurrealSet(simplifyRewriter(lu_s(x.e, y.e)))

@commu upperUnion(x::CountedSurrealSet, y::SingularSurrealSet) = autoSurrealSet(simplifyRewriter(uu_s(x.e, y.s)))
upperUnion(x::CountedSurrealSet, y::CountedSurrealSet) = autoSurrealSet(simplifyRewriter(uu_s(x.e, y.e)))

