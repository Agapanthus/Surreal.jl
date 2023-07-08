
struct EmptySurrealSet <: SurrealSet
	EmptySurrealSet() = new()
end

for T in [EmptySurrealSet, SurrealSet, Surreal]
	eval(quote
		@commu <(x::$(T), y::EmptySurrealSet) = true
		@commu <=(x::$(T), y::EmptySurrealSet) = true
		@commu +(x::$(T), y::EmptySurrealSet) = nil
		@commu *(x::$(T), y::EmptySurrealSet) = nil
	end)
end

isequal(::EmptySurrealSet, ::EmptySurrealSet) = true
Base.show(io::IO, ::EmptySurrealSet) = print(io, "∅")
isDyadic(::EmptySurrealSet) = true
-(::EmptySurrealSet) = nil

for f in [:lowerUnion, :upperUnion]
	eval(quote
		# this is commutative, i.e., it always returns the SurrealSet and not the empty one
		@commu $f(x::EmptySurrealSet, y::SurrealSet) = y
		$f(::EmptySurrealSet, ::EmptySurrealSet) = nil
	end)
end

isEmpty(x::SurrealSet) = typeof(x) === EmptySurrealSet

birthday(x::EmptySurrealSet) = -1

hasUpperLimit(::EmptySurrealSet) = true
hasLowerLimit(::EmptySurrealSet) = true

simplify(::EmptySurrealSet, ::Bool) = nil