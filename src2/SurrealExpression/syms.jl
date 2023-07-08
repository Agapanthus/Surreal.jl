
SymbolicUtils.:(<ₑ)(a::SurrealExpression, b::Surreal) = false
SymbolicUtils.:(<ₑ)(a::Surreal, b::SurrealExpression) = true
SymbolicUtils.:(<ₑ)(a::Symbolic, b::Surreal) = false
SymbolicUtils.:(<ₑ)(a::Surreal, b::Symbolic) = true

# symbolic expression n
@syms n_s::SurrealExpression
@syms omega_s::SurrealExpression

# TODO: remove X_s
@syms X_s(x::Surreal)::SurrealExpression

# lower union 
@syms lu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression
@syms uu_s(x::SurrealExpression, y::SurrealExpression)::SurrealExpression

const SubSe = SymbolicUtils.BasicSymbolic{SurrealExpression}
SymbolicUtils.zero(::Surreal) = S0
SymbolicUtils.one(::Surreal) = S1

function SymbolicUtils.similarterm(t::SubSe, f, args, symtype; metadata = nothing)

	# TODO: copied from types.jl, must adjust this!

	if f isa Symbol
		error("$f must not be a Symbol")
	end
	T = symtype

	if (f in (+, *)) || (f in (/, ^, lu_s, uu_s) && length(args) == 2)
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


function iterateAdd(e)
	local res = Vector{Tuple{Surreal, SubSe}}()
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
		push!(res, (S1, X_s(a[1])))
	else
		push!(res, getFactor(a[1]))
	end
	for arg in a[2:end]
		push!(res, getFactor(arg))
	end
	res
end

function printFactor(io::IO, factor, v, forceSign::Bool = false)
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
			for (i, arg) in enumerate(iterateAdd(e))
				printFactor(io, arg..., i > 1)
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
