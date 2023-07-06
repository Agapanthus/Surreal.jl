
abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

import Base.(<=), Base.isequal, Base.(<), Base.(+), Base.(-), Base.(*), Base.(/)

# default implementations
Base.:(<=)(x::SurrealSet, y::SurrealSet) = TODO
Base.:(>=)(x::SurrealSet, y::SurrealSet) = y <= x
"equivalent, i.e., same equivalence class"
equiv(x::SurrealSet, y::SurrealSet) = x == y || (y <= x && x <= y)
"equivalent"
⊜(x::SurrealSet, y::SurrealSet) = equiv(x, y)
Base.:(<)(x::SurrealSet, y::SurrealSet) = TODO
Base.isless(x::SurrealSet, y::SurrealSet) = x < y
Base.:(>)(x::SurrealSet, y::SurrealSet) = y < x


"same representation"
function isequal(x::SurrealSet, y::SurrealSet)
	typeof(x) === typeof(y) || return false
	@show typeof(x) typeof(y)
	TODO
end
Base.:(!=)(x::SurrealSet, y::SurrealSet) = !isequal(x, y)
"same representation"
Base.:(==)(x::SurrealSet, y::SurrealSet) = isequal(x, y)

(lowerUnion(x::T)::T) where {T <: SurrealSet} = x
(upperUnion(x::T)::T) where {T <: SurrealSet} = x
(lowerUnion(x::Vector{T})::SurrealSet) where {T <: SurrealSet} = lowerUnion(reduce(lowerUnion, x))
(upperUnion(x::Vector{T})::SurrealSet) where {T <: SurrealSet} = upperUnion(reduce(upperUnion, x))


(isInfinite(x::T)::Bool) where {T <: SurrealSet} = !isFinite(x)