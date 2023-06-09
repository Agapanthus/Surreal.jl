using PyCall
using SymPy
using Symbolics
using SymbolicUtils
using Latexify

# convert Symbolics.jl to sympy
function PyObject(ex::Num)::Sym
	ex |> x -> latexify(x, env = :raw) |>
			   String |>
			   x -> replace(x, r"(?<![\+,\-]) (?![\+,\-])" => "*") |>
					sympy.parse_expr |> Sym
end

function sideToF(s::Side, xVar)
	@assert !isempty(s)

	if s == SSetId
		return xVar
	elseif s == SSetAdd
		return sideToF(left(s), xVar) + sideToF(right(s), xVar)
	elseif s == SSetMul
		return sideToF(left(s), xVar) + sideToF(right(s), xVar)
	elseif s == SSetInv
		return 1 / sideToF(left(s), xVar)
	elseif s == SSetNeg
		return -sideToF(left(s), xVar)
	elseif s == SSetLit
		@assert isFiniteStructure(value(s)) value(s)
		return toR(value(s))
	end

	@show s
	todo
end

function getCompOperation(s::Symbol)
	s == :leq && return LessThan
	s == :le && return StrictLessThan
	s == :geq && return GreaterThan
	s == :ge && return StrictGreaterThan
	s == :eq && return Eq
	@assert false
end

function invertOp(s::Symbol)::Symbol
	s == :leq && return :geq
	s == :le && return :ge
	s == :geq && return :leq
	s == :ge && return :le
	s == :eq && return :eq
	@assert false
end

function containsNaturals(x, xVar = nothing, yVar = nothing)::Union{Bool, Nothing}
	local r = false

	r = sympy.S.Naturals.is_subset(x)
	typeof(r) == Bool && return r

	r = sympy.Interval(1, oo).is_subset(x)
	typeof(r) == Bool && return r

	# not sure
	return nothing
end

getPyType(x::PyCall.PyObject)::String = pycall(pybuiltin("type"), PyCall.PyObject, x).__name__


function sympyGetNumeric(x)
	try
		local res = N(x)
		typeof(res) == Sym && return nothing
	catch err
		return nothing
	end
end

function containsAnyNatural(x)::Bool
	# returns true if it does
	# returns false if not or not sure

	#display(x)

	if typeof(x) == Vector{Sym}
		for s in collect(x)
			containsAnyNatural(s) && return true
		end
	elseif typeof(x) == Vector{Any}
		@assert length(x) == 0
		return false
	elseif typeof(x) == Sym
		local t = getPyType(x.__pyobject__)

		if t in ["Integer", "NegativeOne", "Zero", "One"]
			# @show x + 0
			return true
		elseif t in ["Mul", "Pow"]
			all(containsAnyNatural, x.args) && return true
		elseif t in ["Or"]
			any(containsAnyNatural, x.args) && return true
		elseif t in ["LessThan"]
			local z = sympyGetNumeric(x.args[1])
			# greater than something is always natural
			!isnothing(z) && return true

			z = sympyGetNumeric(x.args[2])
			# if 1 fits below, that's fine
			!isnothing(z) && z >= 1 && return true

		elseif t in ["GreaterThan"]
			local z = sympyGetNumeric(x.args[2])
			# greater than something is always natural
			!isnothing(z) && return true

			z = sympyGetNumeric(x.args[1])
			# if 1 fits below, that's fine
			!isnothing(z) && z >= 1 && return true

		elseif t in ["Half"]
			# pass
		else
			@show t
			@assert false "unknown type"
		end

	else
		@show typeof(x)
		@assert false "unknown type"
	end

	return false
end

function eachRight(y::Side)::Side
	# todo: use symbolics to normalize expressions!

	# unwrap literals
	y == SSetLit && return value(y).R

	# open to the right
	#y == SSetId && return ∅

	# adding finite values doesn't change anything in a countably infinite set
	#y == SSetAdd && left(y) == SSetId && right(y) == SSetLit && isFinite(value(right(y))) && return ∅

	# TODO: is this correct?
	return y


	@show y
	todo
end

#=
function eachLeft(y::Side)::Side
	# todo: use symbolics to normalize expressions!

	# adding finite values doesn't change anything in a countably infinite set
	y == SSetAdd && left(y) == SSetId && right(y) == SSetLit && isFinite(value(right(y))) && return Side(SSetId)

	y == SSetLit && return value(y).L

	# subtract one to get lower bounds 
	y == SSetId && return Side(SSetAdd, y, S(-1))

	@show y
	todo
end
=#

function applyOp(s, a, b)
	s == :leq && return a <= b
	s == :le && return a < b
	s == :geq && return a >= b
	s == :ge && return a > b
	s == :eq && return a == b
	@assert false op
end

function surrealToSym(x::Surreal, ss)
	isFiniteStructure(x) && return toR(x)
	return ss.S(sideToF2(x.L, ss), sideToF2(x.R, ss))
end


function sideToF2(s::Side, ss)
	if isempty(s)
		return ss.∅
	elseif s == SSetId
		return ss.n
	elseif s == SSetAdd
		return sideToF2(left(s), ss) + sideToF2(right(s), ss)
	elseif s == SSetMul
		return sideToF2(left(s), ss) + sideToF2(right(s), ss)
	elseif s == SSetInv
		return 1 / sideToF2(left(s), ss)
	elseif s == SSetNeg
		return -sideToF2(left(s), ss)
	elseif s == SSetLit
		return surrealToSym(value(s), ss)
	end

	@show s
	todo
end

function myProof(x, s, op)
	# TODO: this should replace all the sympy stuff

	# TODO: don't use Integer, but define operators for surreals
	SymbolicUtils.@syms n::Integer S(l, r)::Integer ∅ omega epsilon leq(l, r)
	ss = (n = n, S = S, ∅ = ∅)

	local f = 0

	if typeof(x) == Surreal
		f = applyOp(op, surrealToSym(x, ss), sideToF2(s, ss))
	else
		f = applyOp(op, sideToF2(x, ss), sideToF2(s, ss))
	end

	local myRules = SymbolicUtils.RestartedChain([
		@rule S(n, ∅) => omega
		#@acrule sin(~x)^2  => 1
	])

	myRules = SymbolicUtils.PassThrough(SymbolicUtils.Prewalk(myRules))

	display(f)
	local f2 = SymbolicUtils.simplify(f)
	f2 = myRules(f2)
	#f2 !== f &&
	display(f2)


end


function compareAll(x::Surreal, s::Side, op::Symbol)::Union{Nothing, Bool}
	# all s compare to x as specified

	#@show x s

	isempty(s) && return true

	myProof(x, s, op)

	if !isFiniteStructure(x)
		if op == :ge && x == ω && structEq(s, Side(SSetId))
			return true
		end

		if op == :geq && x == ω && structEq(s, Side(SSetAdd, Side(SSetId), Side(S1)))
			return true
		end

		#=
		if op == :le
			# all x.L < all s
			#@show x s

			#=local res = compareAll(x.L, s, :le)
			isnothing(res) && return nothing
			res == false && return false

			todo=#

			#@show x.L s

			# all xL < s
			local res = compareAll(x.L, s, :le)
			#@show res
			isnothing(res) && return nothing
			res == false && return false

			# all x < sR
			#@show x s
			compareAll(x, eachRight(s), :le)

			# todo: and not equal!
			todo

		elseif op == :ge
			# all x.L < all s

			#= @show x s

			local res = compareAll(s, x.L, :le)
			isnothing(res) && return nothing
			res == false && return false

			todo=#
		end
		=#

		@show op x s
		todo

		# x.L < x < x.R
		#          [--- y ---]


		# x.L < y   forall y
		# x < allRight(y)
		# for no y: y == x 
	end

	# TODO: currently required
	@assert isFiniteStructure(x)

	local xVar = symbols("x")


	# ignores previous assumptions, but returns consistent results and all results (unlike solve)
	# https://docs.sympy.org/latest/modules/solvers/solveset.html
	local f = getCompOperation(op)(toR(x), sideToF(s, xVar))
	#display(f)
	local res = solveset(f, xVar, domain = sympy.S.Naturals)
	#display(res)
	#@show containsNaturals(res, xVar)

	return containsNaturals(res, xVar)


end


function compareAll(x::Side, y::Surreal, op::Symbol)
	return compareAll(y, x, invertOp(op))
end

function proofLess(x::Surreal, s::Side)
	# TODO
	return compareAll(x, s, :le)
end

function proofLess(s::Side, x::Surreal)
	# TODO
	return compareAll(x, s, :ge)
end

function compareAllSympyFallback(x, y, op)
	@assert op == :le

	begin
		local xVar = symbols("x")
		local yVar = symbols("y")

		# use yVar if xVar is never used
		local testVar = x == SSetLit ? yVar : xVar

		local f = StrictLessThan(sideToF(x, xVar), sideToF(y, yVar))
		#display(f)
		local res = solveset(f, testVar, domain = sympy.S.Naturals)
		#display(res)

		local r = containsNaturals(res, xVar, yVar)
		typeof(r) == Bool && return r
	end

	local yVar = symbols("y", real = true, nonnegative = true, integer = true)

	function tryFindCounterexample(yVar)
		#try
		local xVar = symbols("x", real = true, nonnegative = true, integer = true)
		#local slackVar = symbols("s", real = true, nonnegative = true)
		local f = GreaterThan(sideToF(x, xVar + 1), sideToF(y, yVar + 1))
		#local f = Eq(sideToF(x, xVar + 1) - sideToF(y, yVar + 1) + slackVar, 0)

		f = sympy.simplify(f)

		# this is always the other way around. stop now.
		f == true && return false
		#display(f)
		if f != false

			local res = solve(f, xVar)
			#display(res)

			# always satisfied
			res == true && return false

			containsAnyNatural(res) && return false

			#display(res)
		end
		#catch err
		#	@show err
		# skip due to error
		#end
		return nothing
	end

	tryFindCounterexample(yVar) == false && return false
	for arbitraryFixedValue in [1, 2, 3, 4, 5, 10, 10000, 1000000]
		tryFindCounterexample(arbitraryFixedValue) == false && return false
	end


	return nothing
end

function compareAll(x::Side, y::Side, op::Symbol = :le)::Union{Nothing, Bool}
	# all left are strictly less than all right

	#@show x y

	isempty(y) && return true
	isempty(x) && return true

	myProof(x, y, op)

	@assert op == :le
	return compareAllSympyFallback(x, y, op)
end



function sympyIsEmpty(x)::Bool
	# TODO: does this work?
	return x == sympy.S.EmptySet
end

function isIntersecting(a, b)::Bool
	# TODO: does this work?
	return !sympyIsEmpty(a.intersect(b))
end

function isUnlimited(s::Side, pos::Bool)::Bool
	s == SSetLit && return isUnlimited(pos ? value(s).L : value(s).R, pos)
	s == SSetNeg && return isUnlimited(left(s), !pos)

	myProof(Side(SSetId), s, :le)

	local xVar = symbols("x", real = true, nonnegative = true)
	#local yVar = symbols("y")

	begin
		# absolut convergence is sufficient
		res = limit(abs(sideToF(s, xVar + 1)), xVar => oo)
		res < oo && return false

		# strict divergence
		res = limit(sideToF(s, xVar + 1), xVar => oo)
		if pos
			res == oo && return true
			res == -oo && return false
		else
			res == oo && return false
			res == -oo && return true
		end
	end

	for boundary in [1000000, big(10)^20, big(10)^1000]
		local res = solveset(
			pos ? StrictGreaterThan(sideToF(s, xVar), boundary)
			: StrictLessThan(sideToF(s, xVar), -boundary),
			xVar, domain = sympy.S.Naturals)
		#display(res)
		local hasI = isIntersecting(sympy.S.Naturals, res)
		hasI || return false
	end

	# probably true
	return true
end
