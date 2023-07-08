const MyRational = Rational{Int64}

abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

# default implementations
Base.:(<=)(x::SurrealSet, y::SurrealSet) = TODO
Base.:(>=)(x::SurrealSet, y::SurrealSet) = y <= x
"equivalent, i.e., same equivalence class"
equiv(x::SurrealSet, y::SurrealSet) = x == y || (y <= x && x <= y)
"equivalent"
≅(x::SurrealSet, y::SurrealSet) = equiv(x, y)
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

@inline lowerUnion(x::SurrealSet) = x
@inline upperUnion(x::SurrealSet) = x
@inline lowerUnion(x::Vector) = lowerUnion(reduce(lowerUnion, x))
@inline upperUnion(x::Vector) = upperUnion(reduce(upperUnion, x))


@inline isLimited(x::SurrealSet)::Bool = hasUpperLimit(x) && hasLowerLimit(x)
@inline isUnlimited(x::SurrealSet)::Bool = !isLimited(x)

@inline Base.length(::SurrealSet) = 1
@inline Base.iterate(x::SurrealSet) = (x, nothing)
@inline Base.iterate(x::SurrealSet, ::Nothing) = nothing
