
abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

import Base.(<=), Base.(<), Base.(+), Base.(-), Base.(*), Base.(/), Base.minimum, Base.maximum

# default implementations
Base.:(<=)(x::SurrealSet, y::SurrealSet) = @assert false "impl!"
Base.:(>=)(x::SurrealSet, y::SurrealSet) = y <= x
Base.:(==)(x::SurrealSet, y::SurrealSet) = y <= x && x <= y
Base.isequal(x::SurrealSet, y::SurrealSet) = x == y
Base.:(!=)(x::SurrealSet, y::SurrealSet) = !(x == y)
Base.:(<)(x::SurrealSet, y::SurrealSet) = @assert false "impl!"
Base.isless(x::SurrealSet, y::SurrealSet) = x < y
Base.:(>)(x::SurrealSet, y::SurrealSet) = y < x

(lowerUnion(x::Vector{T})::T) where {T <: SurrealSet} = reduce(lowerUnion, x)
(upperUnion(x::Vector{T})::T) where {T <: SurrealSet} = reduce(upperUnion, x)
