

abstract type SurrealSet end

autoSurrealSet(x::SurrealSet)::SurrealSet = x

import Base.(<=), Base.(<)

# default implementations
Base.:(<=)(x::SurrealSet, y::SurrealSet) = @assert false "impl!"
Base.:(>=)(x::SurrealSet, y::SurrealSet) = y <= x
Base.:(==)(x::SurrealSet, y::SurrealSet) = y <= x && x <= y
Base.isequal(x::SurrealSet, y::SurrealSet) = x == y
Base.:(!=)(x::SurrealSet, y::SurrealSet) = !(x == y)
Base.:(<)(x::SurrealSet, y::SurrealSet) = @assert false "impl!" 
Base.isless(x::SurrealSet, y::SurrealSet) = x < y
Base.:(>)(x::SurrealSet, y::SurrealSet) = y < x

##############

struct Surreal
	L::SurrealSet
	R::SurrealSet

	function Surreal(L, R)
		local l = autoSurrealSet(L)
		local r = autoSurrealSet(R)
		@assert l < r
		new(l, r)
	end
end

<=(x::Surreal, y::Surreal) = x.L < y && x < y.R
Base.:(>=)(x::Surreal, y::Surreal) = y <= x
Base.:(==)(x::Surreal, y::Surreal) = y <= x && x <= y
Base.isequal(x::Surreal, y::Surreal) = x == y
Base.:(!=)(x::Surreal, y::Surreal) = !(x == y)
Base.:(<)(x::Surreal, y::Surreal) = x <= y && !(y <= x)
Base.isless(x::Surreal, y::Surreal) = x < y
Base.:(>)(x::Surreal, y::Surreal) = y < x

##############

struct EmptySurrealSet <: SurrealSet
	EmptySurrealSet() = new()
end
const nil = EmptySurrealSet()

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

##############

struct SingularSurrealSet <: SurrealSet
	s::Surreal
end

autoSurrealSet(x::Surreal) = SingularSurrealSet(x)
<=(x::SingularSurrealSet, y::SingularSurrealSet) = x.s <= y.s
<(x::SingularSurrealSet, y::SingularSurrealSet) = x.s < y.s

<(x::SingularSurrealSet, y::Surreal) = x.s < y
<(x::Surreal, y::SingularSurrealSet) = x < y.s

##############

struct VectorSurrealSet <: SurrealSet
	v::Vector{SurrealSet}
end

autoSurrealSet(v::Vector{T}) where {T} = VectorSurrealSet(autoSurrealSet.(v))
autoSurrealSet(v::Set{T}) where {T} = autoSurrealSet(collect(v))

<=(x::VectorSurrealSet, y::SurrealSet) = all(v -> v <= y, x.v)
<=(x::SurrealSet, y::VectorSurrealSet) = all(v -> x <= v, y.v)
<=(x::VectorSurrealSet, y::EmptySurrealSet) = true
<=(x::EmptySurrealSet, y::VectorSurrealSet) = true
<=(x::VectorSurrealSet, y::Surreal) = all(v -> v <= y, x.v)
<=(x::Surreal, y::VectorSurrealSet) = all(v -> x <= v, y.v)

<(x::VectorSurrealSet, y::SurrealSet) = all(v -> v < y, x.v)
<(x::SurrealSet, y::VectorSurrealSet) = all(v -> x < v, y.v)
<(x::VectorSurrealSet, y::EmptySurrealSet) = true
<(x::EmptySurrealSet, y::VectorSurrealSet) = true
<(x::VectorSurrealSet, y::Surreal) = all(v -> v < y, x.v)
<(x::Surreal, y::VectorSurrealSet) = all(v -> x < v, y.v)
