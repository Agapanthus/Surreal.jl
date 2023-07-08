abstract type SurrealExpression end

#@syms S_s(l::SurrealSet, r::SurrealSet)::Surreal
#@syms ∅_s::EmptySurrealSet
#@syms SSS_s(x::Surreal)::SingularSurrealSet

# symbolic expression n
@syms n_s::SurrealExpression
@syms omega_s::SurrealExpression

# TODO: Use optimized add / mul structures from package https://symbolicutils.juliasymbolics.org/api/
@syms add_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression
@syms mul_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression

@syms inv_s(x::SurrealExpression)::SurrealExpression
@syms neg_s(x::SurrealExpression)::SurrealExpression
@syms X_s(x::Surreal)::SurrealExpression

# lower union 
@syms lu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression
@syms uu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression

const SubSe = SymbolicUtils.BasicSymbolic{SurrealExpression}

isTerm(e::SubSe) = exprtype(e) == SymbolicUtils.TERM
isSym(e::SubSe) = exprtype(e) == SymbolicUtils.SYM
left(e::SubSe) = arguments(e)[1]
right(e::SubSe) = arguments(e)[2]

isSurreal(e::SubSe) = isTerm(e) && operation(e) == X_s


@inline function typeofSubSe(e::SubSe)
	if isTerm(e)
		return Symbol(operation(e))
	elseif isSym(e)
		return nameof(e)
	else
		@show exprtype(e)
		TODO
	end
end

function Base.show(io::IO, e::SubSe)
	@match typeofSubSe(e) begin
		:add_s => print(io, left(e), "+", right(e))
		:mul_s => print(io, left(e), "*", right(e))
		:lu_s => print(io, left(e), "∪", right(e))
		:uu_s => print(io, left(e), "∩", right(e))
		:neg_s => print(io, "-", left(e))
		:inv_s => print(io, "1/", left(e))
		:X_s => print(io, left(e))
		:n_s => print(io, "n")
		:omega_s => print(io, "ω")
		_ => @assert false typeofSubSe(e)
	end
end
