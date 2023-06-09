import Base.(>=), Base.(==), Base.(<=), Base.(<)

==(s::Side, t::SSetType) = !isempty(s) && s.x.t == t



function <(x::Side, y::Surreal)
	isempty(x) && return true

	if x == SSetLit
		return value(x) < y
	elseif x == SSetId
		# is it greater than any natural number?
		isPositive(y) || return false
		return !isFinite(y)
	else

		return compareAll(x, y, :le)
	end

	todo
end

function <(x::Surreal, y::Side)

	isempty(y) && return true
	#isempty(x) && return isPositive(y)
	y == SSetLit && return x < value(y)

	return compareAll(x, y, :le)

	@show x y
	todo
end

>=(x::Surreal, y::Surreal) = y <= x
<=(x::Surreal, y::Surreal) = x.L < y && x < y.R # !any(l -> l >= y, x.L) && !any(r -> x >= r, y.R)
==(x::Surreal, y::Surreal) = y <= x && x <= y
<(x::Surreal, y::Surreal) = x <= y && !(y <= x)

==(x::Surreal, y) = x == Surreal(y)
==(x, y::Surreal) = Surreal(x) == y
<(x::Surreal, y) = x < Surreal(y)
<(x, y::Surreal) = Surreal(x) < y
<=(x::Surreal, y) = x <= Surreal(y)
<=(x, y::Surreal) = Surreal(x) <= y
>=(x::Surreal, y) = x >= Surreal(y)
>=(x, y::Surreal) = Surreal(x) >= y

function <=(x::Side, y::Side)::Union{Nothing, Bool}
	# everything in x <= y
	# might return "unsure"

	isempty(x) && return true
	isempty(y) && return true
	x == SSetLit && y == SSetLit && return value(x) <= value(y)
	structEq(x, y) && return true

	if y == SSetLit
		local res = compareAll(value(y), x, :geq)
		res == true && return true
		res == false && return false
	end

	@show x y
	todo

	return nothing
end

>=(x::Side, y::Side) = y <= x
==(x::Side, y::Side) = structEq(x, y) || (y <= x && x <= y)

function structEq(a::Side, b::Side)
	# sufficient but not necessary for equality

	isempty(a) && isempty(b) && return true
	(isempty(a) || isempty(b)) && return false
	a.x.t == b.x.t || return false
	a.x.t == SSetLit && return value(a) == value(b)
	a.x.t == SSetId && return true
	(a.x.t == SSetAdd || a.x.t == SSetMul) && return structEq(left(a), left(b)) && structEq(right(a), right(b))
	(a.x.t == SSetInv || a.x.t == SSetNeg) && return structEq(left(a), left(b))

	# todo
	return false
end

function <(x::Side, y::Side)::Union{Nothing, Bool}
	# everything in x < y
	# optimized, since used very often

	isempty(x) && return true
	isempty(y) && return true

	y == SSetLit && return x < value(y)
	x == SSetLit && return value(x) < y

	local res = compareAll(x, y)
	typeof(res) == Bool && return res

	return (x <= y && !(y <= x))
end
