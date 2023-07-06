
abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

import Base.(<=), Base.(<), Base.(+), Base.(-), Base.(*), Base.(/), Base.minimum, Base.maximum

# default implementations
Base.:(<=)(x::SurrealSet, y::SurrealSet) = TODO
Base.:(>=)(x::SurrealSet, y::SurrealSet) = y <= x
Base.:(==)(x::SurrealSet, y::SurrealSet) = y <= x && x <= y
Base.isequal(x::SurrealSet, y::SurrealSet) = x == y
Base.:(!=)(x::SurrealSet, y::SurrealSet) = !(x == y)
Base.:(<)(x::SurrealSet, y::SurrealSet) = TODO
Base.isless(x::SurrealSet, y::SurrealSet) = x < y
Base.:(>)(x::SurrealSet, y::SurrealSet) = y < x

(lowerUnion(x::T)::T) where {T <: SurrealSet} = x
(upperUnion(x::T)::T) where {T <: SurrealSet} = x
(lowerUnion(x::Vector{T})::SurrealSet) where {T <: SurrealSet} = lowerUnion(reduce(lowerUnion, x))
(upperUnion(x::Vector{T})::SurrealSet) where {T <: SurrealSet} = upperUnion(reduce(upperUnion, x))
