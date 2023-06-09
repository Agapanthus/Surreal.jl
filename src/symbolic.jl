using SymPy
using PyCall
using Symbolics
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
		@assert isFiniteStructure(value(s))
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

getPyType(x::PyObject)::String = pycall(pybuiltin("type"), PyObject, x).__name__


function sympyGetNumeric(x)
	try
		x + 0
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


function compareAll(x::Surreal, y::Side, op::Symbol)::Union{Nothing, Bool}
	isempty(y) && return true

	if !isFiniteStructure(x)

		if op == :geq && x == ω && structEq(y, Side(SSetAdd, Side(SSetId), Side(S1)))
			return true
		end

		@show op x y
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
	local f = getCompOperation(op)(toR(x), sideToF(y, xVar))
	#display(f)
	local res = solveset(f, xVar, domain = sympy.S.Naturals)
	#display(res)
	#@show containsNaturals(res, xVar)

	if showDebug
		@show x
		display(sideToF(y, xVar))
	end


	return containsNaturals(res, xVar)
end


function compareAll(x::Side, y::Side, op::Symbol = :le)::Union{Nothing, Bool}
	# all left are strictly less than all right

	@assert op == :le
	isempty(y) && return true
	isempty(x) && return true

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
		try
			local xVar = symbols("x", real = true, nonnegative = true, integer = true)
			#local slackVar = symbols("s", real = true, nonnegative = true)
			local f = GreaterThan(sideToF(x, xVar + 1), sideToF(y, yVar + 1))
			#local f = Eq(sideToF(x, xVar + 1) - sideToF(y, yVar + 1) + slackVar, 0)

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
		catch err
			# skip due to error
		end
		return nothing
	end

	tryFindCounterexample(yVar) == false && return false
	for arbitraryFixedValue in [1, 2, 3, 4, 5, 10, 10000, 1000000]
		tryFindCounterexample(arbitraryFixedValue) == false && return false
	end


	return nothing
end



function compareAll(x::Side, y::Surreal, op::Symbol)
	return compareAll(y, x, invertOp(op))
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
