const MyRational = Rational{Int64}
abstract type SurrealExpression end
abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

# default implementations
Base.:(<=)(::SurrealSet, ::SurrealSet) = error("unimplemented; requires non-abstract types")
Base.:(>=)(x::SurrealSet, y::SurrealSet) = y <= x
"equivalent, i.e., same equivalence class"
equiv(x::SurrealSet, y::SurrealSet) = x == y || (y <= x && x <= y)
"equivalent"
≅(x::SurrealSet, y::SurrealSet) = equiv(x, y)
Base.:(<)(::SurrealSet, ::SurrealSet) = error("unimplemented; requires non-abstract types")
Base.isless(x::SurrealSet, y::SurrealSet) = x < y
Base.:(>)(x::SurrealSet, y::SurrealSet) = y < x

-(x::SurrealSet, y::SurrealSet) = x + (-y)


"same representation"
function isequal(x::SurrealSet, y::SurrealSet)
	typeof(x) === typeof(y) || return false
	@show typeof(x) typeof(y)
	TODO
end
Base.:(!=)(x::SurrealSet, y::SurrealSet) = !isequal(x, y)
"same representation"
Base.:(==)(x::SurrealSet, y::SurrealSet) = isequal(x, y)

@inline leftUnion(x::SurrealSet) = x
@inline rightUnion(x::SurrealSet) = x
@inline leftUnion(x::Vector) = leftUnion(reduce(leftUnion, x))
@inline rightUnion(x::Vector) = rightUnion(reduce(rightUnion, x))


@inline isLimited(x::SurrealSet)::Bool = hasUpperLimit(x) && hasLowerLimit(x)
@inline isUnlimited(x::SurrealSet)::Bool = !isLimited(x)

@inline Base.length(::SurrealSet) = 1
@inline Base.iterate(x::SurrealSet) = (x, nothing)
@inline Base.iterate(x::SurrealSet, ::Nothing) = nothing
