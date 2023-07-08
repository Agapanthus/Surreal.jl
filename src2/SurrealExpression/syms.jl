abstract type SurrealExpression end

SymbolicUtils.:(<ₑ)(a::SurrealExpression, b::Surreal) = false
SymbolicUtils.:(<ₑ)(a::Surreal, b::SurrealExpression) = true
SymbolicUtils.:(<ₑ)(a::Symbolic, b::Surreal) = false
SymbolicUtils.:(<ₑ)(a::Surreal, b::Symbolic) = true

# symbolic expression n
@syms n_s::SurrealExpression
@syms omega_s::SurrealExpression

@syms X_s(x::Surreal)::SurrealExpression

# lower union 
@syms lu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression
@syms uu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression

SymbolicUtils.zero(::Surreal) = S0

const SubSe = SymbolicUtils.BasicSymbolic{SurrealExpression}

isTerm(e::SubSe) = exprtype(e) == SymbolicUtils.TERM
isSym(e::SubSe) = exprtype(e) == SymbolicUtils.SYM
isAdd(e::SubSe) = exprtype(e) == SymbolicUtils.ADD
isMul(e::SubSe) = exprtype(e) == SymbolicUtils.MUL
left(e::SubSe) = arguments(e)[1]
right(e::SubSe) = arguments(e)[2]

isSurreal(e::SubSe) = isTerm(e) && operation(e) == X_s

@inline function typeofSubSe(e::SubSe)
	if isTerm(e)
		return Symbol(operation(e))
	elseif isSym(e)
		return nameof(e)
	elseif isAdd(e)
		return :add
	elseif isMul(e)
		return :mul
	else
		@show exprtype(e)
		TODO
	end
end

function printFactor(io::IO, a, forceSign::Bool = false)
	@assert operation(a) == *
	local v = arguments(a)[1]
	local factor = arguments(a)[2]
	@assert !(factor == S0)
	if factor == S1
		forceSign && print(io, "+")
		print(io, v)
	elseif factor == SM1
		print(io, "-", v)
	else
		forceSign && isPositive(factor) && print(io, "+")
		print(io, factor, "*", v)
	end
end

function Base.show(io::IO, e::SubSe)
	@match typeofSubSe(e) begin
		:add => begin
			print(io, "(")
			local a = arguments(e)
			if a[1] isa Surreal
				print(io, a[1])
			else
				printFactor(io, a[1])
			end
			for arg in a[2:end]
				printFactor(io, arg, true)
			end
			print(io, ")")
		end
		:mul => for (i, arg) in enumerate(arguments(e))
			print(io, i == 1 ? "" : "*", arg)
		end
		:lu_s => print(io, left(e), "∪", right(e))
		:uu_s => print(io, left(e), "∩", right(e))
		:X_s => print(io, left(e))
		:n_s => print(io, "n")
		:omega_s => print(io, "ω")
		_ => @assert false typeofSubSe(e)
	end
end
