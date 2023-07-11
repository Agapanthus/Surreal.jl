struct VectorSurrealSet <: SurrealSet
	v::Vector{SurrealSet}
end

autoSurrealSet(v::Vector{T}) where {T} = VectorSurrealSet(autoSurrealSet.(v))
autoSurrealSet(v::Set{T}) where {T} = autoSurrealSet(collect(v))

for f in [:<, :<=], T2 in [SurrealSet, Surreal]
	eval(quote
		@passDownType (x -> x.v) VectorSurrealSet ($T2) false ($f(x, y) = all2(($f).(x, y)))
		@commu $f(x::VectorSurrealSet, y::EmptySurrealSet) = true
		$f(x::VectorSurrealSet, y::VectorSurrealSet) = all2(v -> all2(vv -> $f(vv, v), x.v), y.v)
	end)
end

isequal(x::VectorSurrealSet, y::VectorSurrealSet) = length(x.v) == length(y.v) && all(isequal(l, r) for (l, r) in zip(x.v, y.v))

function Base.show(io::IO, x::VectorSurrealSet)
	print(io, "{")
	for (i, v) in enumerate(x.v)
		print(io, i == 1 ? "" : ",", v)
	end
	print(io, "}")
end
isDyadic(x::VectorSurrealSet)::Bool = all(isDyadic, x.v)

-(x::VectorSurrealSet) = VectorSurrealSet(.-x.v)

for f in [:+, :*]
	eval(quote
		@passDownType (x -> x.v) VectorSurrealSet Surreal true ($f(x, y) = VectorSurrealSet(vec([$f(a, b) for a in x, b in y])))
	end)
end

for f in [:leftUnion, :rightUnion]
	eval(quote
		@passDownType (x -> x.v) VectorSurrealSet SurrealSet true ($f(x, y) = $f([x..., y...]))
		@commu $f(::EmptySurrealSet, ::VectorSurrealSet) = nil
		$f(x::VectorSurrealSet) = $f(x.v)
	end)
end

birthday(x::VectorSurrealSet) = maximum(birthday.(x.v))
simplify(x::VectorSurrealSet, upper::Bool) = upper ? simplify(rightUnion(x.v), upper) : simplify(leftUnion(x.v), upper)