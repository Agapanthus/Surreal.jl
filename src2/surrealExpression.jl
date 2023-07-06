using Symbolics
using SymbolicUtils: SymbolicUtils, Symbolic, nameof, symtype, exprtype, operation, arguments



abstract type SurrealExpression end

#@syms S_s(l::SurrealSet, r::SurrealSet)::Surreal
#@syms ∅_s::EmptySurrealSet
#@syms SSS_s(x::Surreal)::SingularSurrealSet

# symbolic expression n
@syms n_s::SurrealExpression

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

#=
"representation equality"
function Base.isequal(x::SubSe, y::SubSe)
	x === y && return true
	# see https://github.com/JuliaSymbolics/SymbolicUtils.jl/blob/e4519eb267f16082839c13e8817bd9afa2ff3e2c/src/types.jl#L29

	local E = exprtype(x)
	exprtype(x) == exprtype(y) || return false
	if E == SymbolicUtils.TERM
        a = arguments(x)
        b = arguments(y)
		return isequal(operation(x), operation(y)) && 
			length(a) == length(b) &&
            all(isequal(l, r) for (l, r) in zip(a, b))
	else
		return x.name == y.name
	end
end
=#

function Base.show(io::IO, e::SubSe)
	local E = exprtype(e)
	if E == SymbolicUtils.TERM
		if operation(e) == add_s
			print(io, arguments(e)[1], "+", arguments(e)[2])
		elseif operation(e) == mul_s
			print(io, arguments(e)[1], "*", arguments(e)[2])
		elseif operation(e) == lu_s
			print(io, arguments(e)[1], "∪", arguments(e)[2])
		elseif operation(e) == uu_s
			print(io, arguments(e)[1], "∩", arguments(e)[2])
		elseif operation(e) == neg_s
			print(io, "-", arguments(e)[1])
		elseif operation(e) == inv_s
			print(io, "1/", arguments(e)[1])
		elseif operation(e) == X_s
			print(io, arguments(e)[1])
		else
			@show operation(e)
			TODO
		end
	elseif E == SymbolicUtils.SYM
		if nameof(e) == :n_s
			print(io, "n")
		else
			@show nameof(e)
			TODO
		end
	else
		@show E
		TODO
	end
end

function isFinite(e::SubSe)::Bool
	if istree(e)
		if operation(e) == add_s
			local f1 = isFinite(arguments(e)[1])
			local f2 = isFinite(arguments(e)[2])
			f1 && f2 && return true
			if !f1 && !f2
				# both infinite
				TODO
			end
			return false
		elseif operation(e) == neg_s
			return isFinite(arguments(e)[1])
		elseif operation(e) == X_s
			return isFinite(arguments(e)[1])
		else
			@show operation(e)
			TODO
		end
	else
		if nameof(e) == :n_s
			return false
		else
			@show nameof(e)
			TODO
		end
	end

end

function hasFiniteUpperLimit(e::SubSe)
	if istree(e)
		if operation(e) == add_s
			local f1 = isFinite(arguments(e)[1])
			local f2 = isFinite(arguments(e)[2])
			f1 && f2 && return true
			if !f1 && !f2
				# both infinite
				TODO
			end
			return false
		elseif operation(e) == neg_s
			return hasFiniteLowerLimit(arguments(e)[1])
		elseif operation(e) == X_s
			return isFinite(arguments(e)[1])
		else
			@show operation(e)
			TODO
		end
	else
		if nameof(e) == :n_s
			return false
		else
			@show nameof(e)
			TODO
		end
	end
end

hasFiniteLowerLimit(e::SubSe) = TODO


prepareChain(cas) = x -> SymbolicUtils.simplify(x;
	threaded = true,
	rewriter = (cas |>
				SymbolicUtils.RestartedChain |>
				SymbolicUtils.Prewalk),
)

additionRules = [
	@rule add_s(X_s(~x::(x -> isZeroFast(x))), ~y) => ~y
	@rule add_s(~y, X_s(~x::(x -> isZeroFast(x)))) => ~y
	#  @rule add(~x, S(∅, ∅)) => ~x
	#  @rule add(SSS(~x), ~y) => SSS(~x ⊕ ~y)

	# @rule (S(∅, ∅) ⊕ ~y) => ~y
	# @rule (~x ⊕ S(∅, ∅)) => ~x
	# @rule (S(~XL, ~XR) ⊕ S(~YL, ~YR)) =>  S(maxUnion(add(~XL, S(~YL, ~YR)), add(~YL, S(~XL, ~XR))), minUnion(add(~XR, S(~YL, ~YR)), add(~YR, S(~XL, ~XR))))
]


luRewriter = prepareChain(vcat(
	additionRules...,
))


#=Base.show(io::IO, ::SEn) = print(io, "n")
Base.show(io::IO, x::SEAdd) = print(io, x.x, "+", x.y)
Base.show(io::IO, x::SENeg) = print(io, "-", x.x)
Base.show(io::IO, x::SENum) = print(io, x.x)=#
