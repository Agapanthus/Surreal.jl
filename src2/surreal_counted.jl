
struct CountedSurrealSet <: SurrealSet
	e::SubSe
end

autoSurrealSet(x::SubSe) = CountedSurrealSet(x)

<=(x::CountedSurrealSet, y::CountedSurrealSet) = TODO
<(x::CountedSurrealSet, y::CountedSurrealSet) = TODO
function <(x::CountedSurrealSet, y::Surreal)
	if isInfinite(x) && isFinite(y)
		return isNegative(x)
	end

	@show x.e == add_s(n_s, X_s(S0))
	@show add_s(n_s, X_s(S0))
	@show x y
	TODO
end
<(x::Surreal, y::CountedSurrealSet) = TODO

isequal(x::CountedSurrealSet, y::CountedSurrealSet) = isequal(x.e, y.e)
Base.show(io::IO, x::CountedSurrealSet) = print(io, x.e)
isDyadic(x::CountedSurrealSet) = false

for f in [
	:isFinite,
	:hasFiniteUpperLimit,
	:hasFiniteLowerLimit,
	:birthday,
]
	eval(quote
		$f(x::CountedSurrealSet) = $f(x.e)
	end)
end

function simplify(x::CountedSurrealSet, upper::Bool)
	local res = CountedSurrealSet(simplifyRewriter(x.e))
	isSurreal(res.e) && return SingularSurrealSet(arg1(res.e))
	return res
end

-(x::CountedSurrealSet) = CountedSurrealSet(neg_s(x.e))

@commu +(x::CountedSurrealSet, y::Surreal) = x + CountedSurrealSet(X_s(y))
+(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(add_s(x.e, y.e))

@commu *(x::CountedSurrealSet, y::Surreal) = x * CountedSurrealSet(X_s(y))
*(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(mul_s(x.e, y.e))

@commu lowerUnion(x::CountedSurrealSet, y::SingularSurrealSet) = lowerUnion(x, CountedSurrealSet(X_s(y.s)))
lowerUnion(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(luRewriter(lu_s(x.e, y.e)))

@commu upperUnion(x::CountedSurrealSet, y::CountedSurrealSet) = upperUnion(x, CountedSurrealSet(X_s(y.s)))
upperUnion(x::CountedSurrealSet, y::CountedSurrealSet) = CountedSurrealSet(luRewriter(uu_s(x.e, y.e)))

