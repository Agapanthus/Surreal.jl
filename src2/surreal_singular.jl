struct SingularSurrealSet <: SurrealSet
	s::Surreal
end

autoSurrealSet(x::Surreal) = SingularSurrealSet(x)
<=(x::SingularSurrealSet, y::SingularSurrealSet) = x.s <= y.s
@passDownType (x -> x.s) SingularSurrealSet Surreal true (<(x, y) = x < y)

isequal(x::SingularSurrealSet, y::SingularSurrealSet) = isequal(x.s, y.s)

function Base.show(io::IO, x::SingularSurrealSet)
	if isDyadic(x.s)
		local f = toFrac(x.s)
		if denominator(f) == 1
			print(io, numerator(f))
		else
			print(io, f)
		end
	else
		print(io, x.s)
	end
end

-(x::SingularSurrealSet) = SingularSurrealSet(-x.s)
@passDownType (x -> x.s) SingularSurrealSet Surreal true (+(x, y) = SingularSurrealSet(x + y))
@passDownType (x -> x.s) SingularSurrealSet Surreal true (*(x, y) = SingularSurrealSet(x * y))

lowerUnion(x::SingularSurrealSet, y::SingularSurrealSet) = max(x, y)
upperUnion(x::SingularSurrealSet, y::SingularSurrealSet) = min(x, y)

isDyadic(x::SingularSurrealSet) = isDyadic(x.s)
birthday(x::SingularSurrealSet) = birthday(x.s)
simplify(x::SingularSurrealSet, ::Bool) = simplify(x.s)

hasFiniteUpperLimit(x::SingularSurrealSet) = isFinite(x.s)
hasFiniteLowerLimit(x::SingularSurrealSet) = isFinite(x.s)
