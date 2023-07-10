
SymbolicUtils.:(<ₑ)(a::SurrealExpression, b::Surreal) = false
SymbolicUtils.:(<ₑ)(a::Surreal, b::SurrealExpression) = true
SymbolicUtils.:(<ₑ)(a::Symbolic, b::Surreal) = false
SymbolicUtils.:(<ₑ)(a::Surreal, b::Symbolic) = true
SymbolicUtils.:(<ₑ)(a::Surreal, b::Surreal) = true # a <= b

# symbolic expression n
@syms n_s::SurrealExpression
@syms omega_s::SurrealExpression

# lower union (interested in lower bounds, usually right side)
@syms lu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression

# upper union (interested in upper bounds, usually left side)
@syms uu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression

@syms isPos_s(x::SurrealExpression)::Bool

# only interested in the upper bound
@syms ub_s(x::SurrealExpression)::SurrealExpression

# only interested in the lower bound
@syms lb_s(x::SurrealExpression)::SurrealExpression

const SubSe = SymbolicUtils.BasicSymbolic{SurrealExpression}
const SubSePlus = Union{SubSe, Surreal}
SymbolicUtils.zero(::Surreal) = S0
SymbolicUtils.one(::Surreal) = S1

function try_ub_s(x::SubSePlus)::SubSe
	if isTerm(x)
		if operation(x) == ub_s
			return x
		end
		@assert operation(x) != lb_s
	end
	return ub_s(x)
end

function try_lb_s(x::SubSePlus)::SubSe
	if isTerm(x)
		if operation(x) == lb_s
			return x
		end
		@assert operation(x) != ub_s
	end
	return lb_s(x)
end

function SymbolicUtils.similarterm(t::SubSe, f, args, symtype; metadata = nothing)

	# TODO: copied from types.jl, must adjust this!

	if f isa Symbol
		error("$f must not be a Symbol")
	end
	T = symtype

	if (f in (+, *)) || (f in (/, ^, lu_s, uu_s) && length(args) == 2) || (f in (ub_s, lb_s) && length(args) == 1)
		res = f(args...)
		if res isa Symbolic
			SymbolicUtils.@set! res.metadata = metadata
		end
		return res
	end

	@show t f args symtype
	TODO

	#=
	if T === nothing
		T = _promote_symtype(f, args)
	end
	if T <: SymbolicUtils.LiteralReal
		SymbolicUtils.Term{T}(f, args, metadata=metadata)
	elseif symtype <: Number && (f in (+, *) || (f in (/, ^) && length(args) == 2)) && all(x->symtype(x) <: Number, args)
		res = f(args...)
		if res isa Symbolic
			SymbolicUtils.@set! res.metadata = metadata
		end
		return res
	else
		SymbolicUtils.Term{T}(f, args, metadata=metadata)
	end
	=#
end


isTerm2(e::Symbolic) = exprtype(e) == SymbolicUtils.TERM
isTerm(e::SubSe) = exprtype(e) == SymbolicUtils.TERM
isSym(e::SubSe) = exprtype(e) == SymbolicUtils.SYM
isAdd(e::SubSe) = exprtype(e) == SymbolicUtils.ADD
isMul(e::SubSe) = exprtype(e) == SymbolicUtils.MUL
left(e::SubSe) = arguments(e)[1]
right(e::SubSe) = arguments(e)[2]

#isSurreal(e::SubSe) = isTerm(e) && operation(e) == X_s

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


function iterateAdd(e)
	@assert isAdd(e)
	local res = Vector{Tuple{Surreal, Union{Surreal, SubSe}}}()
	local a = arguments(e)

	function getFactor(e)
		if isTerm(e) && operation(e) == *
			local args = arguments(e)
			@assert length(args) == 2
			local v, factor = args
			@assert factor isa Surreal
			@assert !(factor == S0)
			factor, v
		else
			@assert typeof(e) == SubSe
			S1, e
		end
	end

	if a[1] isa Surreal
		push!(res, (S1, a[1]))
	else
		push!(res, getFactor(a[1]))
	end
	for arg in a[2:end]
		push!(res, getFactor(arg))
	end
	res
end


function iterateMul(e)
	@assert isMul(e)
	local res = Vector{Tuple{Surreal, Union{Surreal, SubSe}}}()
	local a = arguments(e)

	function getExponent(e)
		if ispow(e)
			local args = arguments(e)
			@assert length(args) == 2
			local v, exponent = args
			@assert exponent isa Surreal
			@assert !(exponent == S0)
			exponent, v
		else
			@assert typeof(e) == SubSe
			S1, e
		end
	end

	if a[1] isa Surreal
		push!(res, (S1, a[1]))
	else
		push!(res, getExponent(a[1]))
	end
	for arg in a[2:end]
		push!(res, getExponent(arg))
	end
	res
end


"negation, i.e., -1 * x"
function isNeg(e, f = x -> x == SM1)
	e isa SubSe && isMul(e) || return false
	local fs = iterateMul(e)
	return length(fs) == 2 && fs[1][1] == (S1) && isDyadic(fs[1][2]) && f(fs[1][2]) && fs[2][1] == S1
end

function printSummand(io::IO, factor, v, forceSign::Bool = false)
	if factor == S1
		if isNeg(v, isNegative)
			local (_, factor2), (_, v2) = iterateMul(v)
			if factor2 == SM1
				print(io, "-", v2)
			else
				print(io, factor2, "*", v2)
			end
		else
			forceSign && print(io, "+")
			print(io, v)
		end
	elseif factor == SM1
		print(io, "-", v)
	else
		forceSign && isPositive(factor) && print(io, "+")
		print(io, factor, "*", v)
	end
end


function printFactor(io::IO, exponent, v, forceSign::Bool = false)
	@assert !(exponent == S0)
	forceSign && print(io, "*")
	if exponent == S1
		print(io, v)
	else
		print(io, v, "^", exponent)
	end
end

function Base.show(io::IO, e::SubSe)
	@match typeofSubSe(e) begin
		:add => begin
			print(io, "(")
			for (i, arg) in enumerate(iterateAdd(e))
				printSummand(io, arg..., i > 1)
			end
			print(io, ")")
		end
		:mul => begin
			local factors = iterateMul(e)
			if factors[1] == (S1, SM1)
				print(io, "-")
				popfirst!(factors)
			end
			for (i, arg) in enumerate(factors)
				printFactor(io, arg..., i > 1)
			end
		end
		:lu_s => print(io, left(e), "⩁", right(e))
		:uu_s => print(io, left(e), "⩂", right(e))
		:le_s => print(io, left(e), "<", right(e))
		:leq_s => print(io, left(e), "<=", right(e))
		:n_s => print(io, "n")
		:ub_s => print(io, "U(", left(e), ")")
		:lb_s => print(io, "L(", left(e), ")")
		:omega_s => print(io, "ω")
		_ => @assert false typeofSubSe(e)
	end
end

function <(x::SubSePlus, y::SubSePlus)
	#archimedeanClass(x)

	local res = simplifyRewriter(isPos_s(lb_s(y - x)))
	res === true && return true
	res === false && return false
	@show x y res
	TODO
end

function <=(x::SubSePlus, y::SubSePlus)
	x < y && return true

	@show x y res
	TODO
end