struct SingularSurrealSet <: SurrealSet
	s::Surreal
end

autoSurrealSet(x::Surreal) = SingularSurrealSet(x)
<=(x::SingularSurrealSet, y::SingularSurrealSet) = x.s <= y.s
@passDownType (x -> x.s) SingularSurrealSet Surreal true (<(x, y) = x < y)

isequal(x::SingularSurrealSet, y::SingularSurrealSet) = isequal(x.s, y.s)

Base.show(io::IO, x::SingularSurrealSet) = print(io, x.s)

-(x::SingularSurrealSet) = SingularSurrealSet(-x.s)
@passDownType (x -> x.s) SingularSurrealSet Surreal true (+(x, y) = SingularSurrealSet(x + y))
@passDownType (x -> x.s) SingularSurrealSet Surreal true (*(x, y) = SingularSurrealSet(x * y))

leftUnion(x::SingularSurrealSet, y::SingularSurrealSet) = max(x, y)
rightUnion(x::SingularSurrealSet, y::SingularSurrealSet) = min(x, y)

isDyadic(x::SingularSurrealSet) = isDyadic(x.s)
birthday(x::SingularSurrealSet) = birthday(x.s)
simplify(x::SingularSurrealSet, ::Bool) = simplify(x.s)

hasUpperLimit(x::SingularSurrealSet) = isFinite(x.s)
hasLowerLimit(x::SingularSurrealSet) = isFinite(x.s)
isLimited(x::SingularSurrealSet) = isFinite(x.s)
