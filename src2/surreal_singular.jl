struct SingularSurrealSet <: SurrealSet
	s::Surreal
end

autoSurrealSet(x::Surreal) = SingularSurrealSet(x)
<=(x::SingularSurrealSet, y::SingularSurrealSet) = x.s <= y.s
<(x::SingularSurrealSet, y::SingularSurrealSet) = x.s < y.s

<(x::SingularSurrealSet, y::Surreal) = x.s < y
<(x::Surreal, y::SingularSurrealSet) = x < y.s

Base.show(io::IO, x::SingularSurrealSet) = print(io, x.s)
#isDyadic(x.s) ? print(io, toFrac(x.s)) : print(io, x.s)

isDyadic(x::SingularSurrealSet) = isDyadic(x.s)

-(x::SingularSurrealSet) = SingularSurrealSet(-x.s)

+(x::SingularSurrealSet, y::Surreal) = SingularSurrealSet(x.s + y)
+(x::Surreal, y::SingularSurrealSet) = SingularSurrealSet(x + y.s)
+(x::SingularSurrealSet, y::SingularSurrealSet) = SingularSurrealSet(x.s + y.s)

*(x::SingularSurrealSet, y::Surreal) = SingularSurrealSet(x.s * y)
*(x::Surreal, y::SingularSurrealSet) = SingularSurrealSet(x * y.s)
*(x::SingularSurrealSet, y::SingularSurrealSet) = SingularSurrealSet(x.s * y.s)

lowerUnion(x::SingularSurrealSet, y::SingularSurrealSet) = max(x, y)
upperUnion(x::SingularSurrealSet, y::SingularSurrealSet) = min(x, y)

maximum(x::SingularSurrealSet) = x
minimum(x::SingularSurrealSet) = x