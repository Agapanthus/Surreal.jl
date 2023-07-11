const MyRational = Rational{Int64}
abstract type SurrealExpression end
abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

# default implementations
Base.:(<=)(::SurrealSet, ::SurrealSet) = error("unimplemented; requires non-abstract types")
Base.:(>=)(x::SurrealSet, y::SurrealSet)::MaybeBool = y <= x
"equivalent, i.e., same equivalence class"
equiv(x::SurrealSet, y::SurrealSet)::MaybeBool = x == y || (y <= x && x <= y)
"equivalent"
≅(x::SurrealSet, y::SurrealSet)::MaybeBool = equiv(x, y)
Base.:(<)(::SurrealSet, ::SurrealSet) = error("unimplemented; requires non-abstract types")
Base.isless(x::SurrealSet, y::SurrealSet)::MaybeBool = x < y
Base.:(>)(x::SurrealSet, y::SurrealSet)::MaybeBool = y < x

Base.max(x::SurrealSet, y::SurrealSet) = @trif x > y x error("no max") y
Base.min(x::SurrealSet, y::SurrealSet) = @trif x < y x error("no min") y

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

@inline isLimited(x::SurrealSet)::MaybeBool = hasUpperLimit(x) && hasLowerLimit(x)
@inline isUnlimited(x::SurrealSet)::MaybeBool = !isLimited(x)

@inline Base.length(::SurrealSet) = 1
@inline Base.iterate(x::SurrealSet) = (x, nothing)
@inline Base.iterate(x::SurrealSet, ::Nothing) = nothing
