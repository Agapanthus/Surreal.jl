
struct EmptySurrealSet <: SurrealSet
	EmptySurrealSet() = new()
end

<=(x::EmptySurrealSet, y::EmptySurrealSet) = true
<(x::EmptySurrealSet, y::EmptySurrealSet) = true

<=(x::SurrealSet, y::EmptySurrealSet) = true
<(x::SurrealSet, y::EmptySurrealSet) = true

<(x::EmptySurrealSet, y::SurrealSet) = true
<=(x::EmptySurrealSet, y::SurrealSet) = true

<(x::Surreal, y::EmptySurrealSet) = true
<=(x::Surreal, y::EmptySurrealSet) = true

<(x::EmptySurrealSet, y::Surreal) = true
<=(x::EmptySurrealSet, y::Surreal) = true

isequal(::EmptySurrealSet, ::EmptySurrealSet) = true

Base.show(io::IO, _::EmptySurrealSet) = print(io, "∅")
isDyadic(x::EmptySurrealSet) = true

-(x::EmptySurrealSet) = nil

+(x::EmptySurrealSet, y::Surreal) = nil
+(x::Surreal, y::EmptySurrealSet) = nil
+(x::EmptySurrealSet, y::SurrealSet) = nil
+(x::SurrealSet, y::EmptySurrealSet) = nil
+(x::EmptySurrealSet, y::EmptySurrealSet) = nil

*(x::EmptySurrealSet, y::Surreal) = nil
*(x::Surreal, y::EmptySurrealSet) = nil
*(x::EmptySurrealSet, y::SurrealSet) = nil
*(x::SurrealSet, y::EmptySurrealSet) = nil
*(x::EmptySurrealSet, y::EmptySurrealSet) = nil

(lowerUnion(x::EmptySurrealSet, y::T)::T) where {T <: SurrealSet} = y
(lowerUnion(x::T, y::EmptySurrealSet)::T) where {T <: SurrealSet} = x
lowerUnion(x::EmptySurrealSet, y::EmptySurrealSet) = nil

(upperUnion(x::EmptySurrealSet, y::T)::T) where {T <: SurrealSet} = y
(upperUnion(x::T, y::EmptySurrealSet)::T) where {T <: SurrealSet} = x
upperUnion(x::EmptySurrealSet, y::EmptySurrealSet) = nil

isEmpty(x::SurrealSet) = typeof(x) === EmptySurrealSet


birthday(x::EmptySurrealSet) = -1

hasFiniteUpperLimit(::EmptySurrealSet) = true
hasFiniteLowerLimit(::EmptySurrealSet) = true

simplify(::EmptySurrealSet, ::Bool) = nil