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

Base.show(io::IO, x::VectorSurrealSet) = print(io, "{", x.v..., "}")
isDyadic(x::VectorSurrealSet) = all(isDyadic, x.v)


-(x::VectorSurrealSet) = VectorSurrealSet(.-x.s)

+(x::VectorSurrealSet, y::Surreal) = VectorSurrealSet(x.s .+ y)
+(x::Surreal, y::VectorSurrealSet) = VectorSurrealSet(x .+ y.s)
+(x::VectorSurrealSet, y::VectorSurrealSet) = TODO

*(x::VectorSurrealSet, y::Surreal) = VectorSurrealSet(x.s .* y)
*(x::Surreal, y::VectorSurrealSet) = VectorSurrealSet(x .* y.s)
*(x::VectorSurrealSet, y::VectorSurrealSet) = TODO

Base.maximum(x::VectorSurrealSet) = SingularSurrealSet(maximum(x.s))
Base.minimum(x::VectorSurrealSet) = SingularSurrealSet(minimum(x.s))

lowerUnion(x::VectorSurrealSet, y::T) where {T <: SurrealSet} = lowerUnion(maximum(x), y)
lowerUnion(x::T, y::VectorSurrealSet) where {T <: SurrealSet} = lowerUnion(x, maximum(y))
lowerUnion(x::VectorSurrealSet, y::VectorSurrealSet) = lowerUnion(maximum(x), maximum(y))

upperUnion(x::VectorSurrealSet, y::T) where {T <: SurrealSet} = upperUnion(minimum(x), y)
upperUnion(x::T, y::VectorSurrealSet) where {T <: SurrealSet} = upperUnion(x, minimum(y))
upperUnion(x::VectorSurrealSet, y::VectorSurrealSet) = upperUnion(minimum(x), minimum(y))