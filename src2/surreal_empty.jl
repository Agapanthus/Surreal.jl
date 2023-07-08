
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

Base.show(io::IO, _::EmptySurrealSet) = print(io, "∅")
isDyadic(x::EmptySurrealSet) = true

-(x::EmptySurrealSet) = nil

@commu (lowerUnion(x::EmptySurrealSet, y::T)::T) where {T <: SurrealSet} = y
lowerUnion(::EmptySurrealSet, ::EmptySurrealSet) = nil
@commu (upperUnion(x::EmptySurrealSet, y::T)::T) where {T <: SurrealSet} = y
upperUnion(::EmptySurrealSet, ::EmptySurrealSet) = nil

isEmpty(x::SurrealSet) = typeof(x) === EmptySurrealSet

birthday(x::EmptySurrealSet) = -1

hasFiniteUpperLimit(::EmptySurrealSet) = true
hasFiniteLowerLimit(::EmptySurrealSet) = true

simplify(::EmptySurrealSet, ::Bool) = nil