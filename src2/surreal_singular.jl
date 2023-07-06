struct SingularSurrealSet <: SurrealSet
	s::Surreal
end

autoSurrealSet(x::Surreal) = SingularSurrealSet(x)
<=(x::SingularSurrealSet, y::SingularSurrealSet) = x.s <= y.s
<(x::SingularSurrealSet, y::SingularSurrealSet) = x.s < y.s

<(x::SingularSurrealSet, y::Surreal) = x.s < y
<(x::Surreal, y::SingularSurrealSet) = x < y.s

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

birthday(x::SingularSurrealSet) = birthday(x.s)