


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

isSurreal(e::SubSe) = isTerm(e) && operation(e) == X_s
function arg1(e::SubSe) 
	@assert isTerm(e) 
	@assert length(arguments(e)) >= 1
	return arguments(e)[1]
end

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
		:add_s	=> print(io, arguments(e)[1], "+", arguments(e)[2])
		:mul_s	=> print(io, arguments(e)[1], "*", arguments(e)[2])
		:lu_s	=> print(io, arguments(e)[1], "∪", arguments(e)[2])
		:uu_s	=> print(io, arguments(e)[1], "∩", arguments(e)[2])
		:neg_s	=> print(io, "-", arguments(e)[1])
		:inv_s	=>print(io, "1/", arguments(e)[1])
		:X_s	=> print(io, arguments(e)[1])
		:n_s	=> print(io, "n")
		:omega_s => print(io, "ω")
		_ => @assert false typeofSubSe(e)
	end
end

function isFinite(e::SubSe)::Bool
	@match typeofSubSe(e) begin
		:add_s => begin
			local f1 = isFinite(arguments(e)[1])
			local f2 = isFinite(arguments(e)[2])
			f1 && f2 && return true
			if !f1 && !f2
				# both infinite
				TODO
			end
			return false
		end
		:neg_s	=> return isFinite(arguments(e)[1])
		:X_s	=> return isFinite(arguments(e)[1])
		:n_s	=> return false
		:omega_s => return false
		_ => @assert false typeofSubSe(e)
	end
end

	

function hasFiniteUpperLimit(e::SubSe)
	@match typeofSubSe(e) begin
		:add_s => begin
			local f1 = isFinite(arguments(e)[1])
			local f2 = isFinite(arguments(e)[2])
			f1 && f2 && return true
			if !f1 && !f2
				# both infinite
				TODO
			end
			return false
		end
		:neg_s	=> return  hasFiniteLowerLimit(arguments(e)[1])
		:X_s => return isFinite(arguments(e)[1])
		:n_s => return false
		:omega_s => return false
	end
end

hasFiniteLowerLimit(e::SubSe) = TODO


prepareChain(cas) = x -> SymbolicUtils.simplify(x;
	threaded = true,
	rewriter = (cas |>
				SymbolicUtils.RestartedChain |>
				SymbolicUtils.Prewalk),
)

function showMeError(f)
	return x -> try
		return f(x)
	catch err
		showerror(stdout, err)
		display(stacktrace(catch_backtrace()))
	end
end

simplificationRules = [
	@rule X_s(~x) => X_s(simplify(~x))
]

additionRules = [
	@rule add_s(X_s(~x::isZeroFast), ~y) => ~y
	@rule add_s(~y, X_s(~x::isZeroFast)) => ~y

	@rule add_s(X_s(~x), X_s(~y)) => X_s(~x + ~y)

	#  @rule add(~x, S(∅, ∅)) => ~x
	#  @rule add(SSS(~x), ~y) => SSS(~x ⊕ ~y)

	# @rule (S(∅, ∅) ⊕ ~y) => ~y
	# @rule (~x ⊕ S(∅, ∅)) => ~x
	# @rule (S(~XL, ~XR) ⊕ S(~YL, ~YR)) =>  S(maxUnion(add(~XL, S(~YL, ~YR)), add(~YL, S(~XL, ~XR))), minUnion(add(~XR, S(~YL, ~YR)), add(~YR, S(~XL, ~XR))))
]

luRules = [
	#@rule lu_s(add_s(n_s, X_s(~x::(isFinite))), ) =>

	# ignore finite additions to infinite stuff
	@rule lu_s(add_s(n_s, X_s(~x::isFinite)), ~y) => lu_s(n_s, ~y)
	@rule lu_s(add_s(X_s(~x::isFinite), n_s), ~y) => lu_s(n_s, ~y)
	@rule lu_s(~y, add_s(n_s, X_s(~x::isFinite))) => lu_s(n_s, ~y)
	@rule lu_s(~y, add_s(X_s(~x::isFinite), n_s)) => lu_s(n_s, ~y)

	# ignore adding smaller stuff (TODO: how to use acrule here?)
	@rule lu_s(n_s, X_s(~x::isInfinite)) => X_s(~x)
	
	# same on both sides is irrelevant
	@rule lu_s(~x, ~x) => ~x

]

omegaRules = [
	@rule X_s(~x::showMeError(isOmegaFast)) => omega_s

]


luRewriter = prepareChain(vcat(
	simplificationRules...,
	additionRules...,
	luRules...,
	omegaRules...,
))

simplifyRewriter = prepareChain(vcat(
	simplificationRules...,
	additionRules...,
	omegaRules...,
))


#=Base.show(io::IO, ::SEn) = print(io, "n")
Base.show(io::IO, x::SEAdd) = print(io, x.x, "+", x.y)
Base.show(io::IO, x::SENeg) = print(io, "-", x.x)
Base.show(io::IO, x::SENum) = print(io, x.x)=#
