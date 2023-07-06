
struct CountedSurrealSet <: SurrealSet
	e::SubSe
end


"first countable infinity"
const omega = Surreal(CountedSurrealSet(n_s), nil)

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

isFinite(x::CountedSurrealSet)::Bool = isFinite(x.e)

isDyadic(x::CountedSurrealSet) = false

hasFiniteUpperLimit(x::CountedSurrealSet) = hasFiniteUpperLimit(x.e)
hasFiniteLowerLimit(x::CountedSurrealSet) = hasFiniteLowerLimit(x.e)


-(x::CountedSurrealSet) = CountedSurrealSet(neg_s(x.e))

+(x::CountedSurrealSet, y::Surreal) = CountedSurrealSet(add_s(x.e, X_s(y)))
+(x::Surreal, y::CountedSurrealSet) = y + x
+(x::CountedSurrealSet, y::CountedSurrealSet) = TODO

*(x::CountedSurrealSet, y::Surreal) = TODO
*(x::Surreal, y::CountedSurrealSet) = TODO
*(x::CountedSurrealSet, y::CountedSurrealSet) = TODO

lowerUnion(x::CountedSurrealSet, y::SingularSurrealSet) = lowerUnion(x, CountedSurrealSet(X_s(y.s)))
lowerUnion(x::SingularSurrealSet, y::CountedSurrealSet) = lowerUnion(y, x)
function lowerUnion(x::CountedSurrealSet, y::CountedSurrealSet)
	return CountedSurrealSet(luRewriter(lu_s(x.e, y.e)))
end

upperUnion(x::CountedSurrealSet, y::CountedSurrealSet) = upperUnion(x, CountedSurrealSet(X_s(y.s)))
upperUnion(x::SingularSurrealSet, y::CountedSurrealSet) = upperUnion(y, x)
upperUnion(x::CountedSurrealSet, y::CountedSurrealSet) = TODO

birthday(x::CountedSurrealSet) = TODO
