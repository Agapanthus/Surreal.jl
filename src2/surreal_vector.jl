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

function Base.show(io::IO, x::VectorSurrealSet)
	print(io, "{")
	for (i, v) in enumerate(x.v)
		print(io, i == 1 ? "" : ",", v)
	end
	print(io, "}")
end
isDyadic(x::VectorSurrealSet) = all(isDyadic, x.v)

-(x::VectorSurrealSet) = VectorSurrealSet(.-x.v)

+(x::VectorSurrealSet, y::Surreal) = VectorSurrealSet(x.v .+ y)
+(x::Surreal, y::VectorSurrealSet) = VectorSurrealSet(x .+ y.v)
+(x::VectorSurrealSet, y::VectorSurrealSet) = TODO

*(x::VectorSurrealSet, y::Surreal) = VectorSurrealSet(x.v .* y)
*(x::Surreal, y::VectorSurrealSet) = VectorSurrealSet(x .* y.v)
*(x::VectorSurrealSet, y::VectorSurrealSet) = TODO

#maximum(x::VectorSurrealSet) = maximum(x.v)
#minimum(x::VectorSurrealSet) = minimum(x.v)

lowerUnion(x::VectorSurrealSet, y::T) where {T <: SurrealSet} = lowerUnion([x.v..., y])
lowerUnion(x::T, y::VectorSurrealSet) where {T <: SurrealSet} = lowerUnion([x, y.v...])
lowerUnion(x::VectorSurrealSet, y::VectorSurrealSet) = lowerUnion([x.v..., y.v...])
lowerUnion(::EmptySurrealSet, ::VectorSurrealSet) = nil
lowerUnion(::VectorSurrealSet, ::EmptySurrealSet) = nil

upperUnion(x::VectorSurrealSet, y::T) where {T <: SurrealSet} = upperUnion([x.v..., y])
upperUnion(x::T, y::VectorSurrealSet) where {T <: SurrealSet} = upperUnion([x, y.v...])
upperUnion(x::VectorSurrealSet, y::VectorSurrealSet) = upperUnion([x.v..., y.v...])
upperUnion(::EmptySurrealSet, ::VectorSurrealSet) = nil
upperUnion(::VectorSurrealSet, ::EmptySurrealSet) = nil

birthday(x::VectorSurrealSet) = maximum(birthday.(x.v))