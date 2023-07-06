
abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

import Base.(<=), Base.(<), Base.(+), Base.(-), Base.(*), Base.(/)

# default implementations
Base.:(<=)(x::SurrealSet, y::SurrealSet) = @assert false "impl!"
Base.:(>=)(x::SurrealSet, y::SurrealSet) = y <= x
Base.:(==)(x::SurrealSet, y::SurrealSet) = y <= x && x <= y
Base.isequal(x::SurrealSet, y::SurrealSet) = x == y
Base.:(!=)(x::SurrealSet, y::SurrealSet) = !(x == y)
Base.:(<)(x::SurrealSet, y::SurrealSet) = @assert false "impl!" 
Base.isless(x::SurrealSet, y::SurrealSet) = x < y
Base.:(>)(x::SurrealSet, y::SurrealSet) = y < x