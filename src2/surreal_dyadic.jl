const MyRational = Rational{Int64}


autoSurrealSet(n::Int64) = SingularSurrealSet(Surreal(n))
autoSurrealSet(x::MyRational) = SingularSurrealSet(Surreal(x))

function Surreal(n::Int64)
	if n == 0
		return S0
	elseif n > 0
		return Surreal(SingularSurrealSet(Surreal(n - 1)), nil, false)
	end
	@assert n < 0
	return Surreal(nil, SingularSurrealSet(Surreal(n + 1)), false)
end

@inline function dyadicParent(x::MyRational)::MyRational
	# TODO: don't use rationals here; could be faster when Julia wasn't trying to simplify the fractions

	@assert numerator(x) != 0

	x < 0 && return -dyadicParent(-x)
	denominator(x) == 1 && return (numerator(x) - 1) // 1
	local n2 = div(numerator(x) - 1, 2)
	local d2 = div(denominator(x), 2)
	if d2 > 1 && n2 % 2 == 1
		return MyRational(n2, d2)
	else
		return MyRational(n2 + 1, d2)
	end
end

"return the parent and grandparent from the binary tree"
function dyadicParents(x::MyRational)::Tuple{MyRational, MyRational}
	@assert denominator(x) >= 2
	@assert ispow2(denominator(x))
	@assert numerator(x) % 2 == 1

	local parent = dyadicParent(x)
	local p = dyadicParent(parent)
	while (p > x) == (parent > x)
		p = dyadicParent(p)
	end
	@assert (p < x < parent || parent < x < p) (p, x, parent)
	parent, p
end

function Surreal(x::MyRational)
	if x == MyRational(0)
		return S0
	elseif x < 0
		return -(Surreal(-x))
	end

	# natural number
	denominator(x) == 1 && return Surreal(numerator(x))

	local p1, p2 = dyadicParents(x)
	if p1 < p2
		return Surreal(Surreal(p1), Surreal(p2), false)
	else
		@assert p2 < p1
		return Surreal(Surreal(p2), Surreal(p1), false)
	end
end

"return the lowest common ancestor of the dyadic numbers and also the child of the lca used to reach it from the number with the larger denominator"
function lca(x::MyRational, y::MyRational)::Tuple{MyRational, MyRational}
	@assert denominator(y) >= 1
	@assert denominator(x) >= 1

	# different sides => 0
	if (x >= 0) != (y >= 0)
		return 0, 0
	end

	# make the x denominator larger
	if denominator(x) < denominator(y)
		x, y = y, x
	end
	# bring to the same denominator
	@assert denominator(x) >= denominator(y)
	local preLCA = x
	while denominator(x) > denominator(y)
		preLCA = x
		x = dyadicParent(x)
	end


	# decrease both denominators simultaneously until reaching 1
	while true
		x == y && return x, preLCA
		preLCA = x
		denominator(x) > 1 && (x = dyadicParent(x))
		denominator(y) > 1 && (y = dyadicParent(y))
		if denominator(x) == 1 && denominator(y) == 1
			if abs(numerator(x)) < abs(numerator(y))
				return x, preLCA
			else
				return y, preLCA
			end
		end
	end
end

"Convert a dyadic surreal number to a fraction"
function toFrac(x::Surreal, check::Bool = true)::MyRational
	# Idea: use the fact that z=(x,y) is the earliest born surreal number with x < z < y

	check && @assert isDyadic(x)

	if isEmpty(x.L)
		isEmpty(x.R) && return MyRational(0)
		local r = min(1, toFrac(minimum(x.R).s, false))
		return MyRational(div(numerator(r), denominator(r)) - 1, 1)
	end
	if isEmpty(x.R)
		local l = max(-1, toFrac(maximum(x.L).s, false))
		return MyRational(div(numerator(l), denominator(l)) + 1, 1)
	end

	@assert maximum(x.L) isa SingularSurrealSet
	@assert maximum(x.R) isa SingularSurrealSet
	local l = maximum(x.L).s
	local r = minimum(x.R).s

	if isNegative(l)
		# different sides -> zero!
		isPositive(r) && return 0

		# TODO: don't recurse with (-), but do this directly for efficiency
		# both non-positive:
		return -toFrac(-x, false)
	end

	local lf = toFrac(l, false)
	local rf = toFrac(r, false)

	local a, preLCA = lca(lf, rf)
	if a == lf || a == rf
		if lf < preLCA < rf
			return preLCA
		else
			return (lf + rf) // 2
		end
	else
		return a
	end
end
