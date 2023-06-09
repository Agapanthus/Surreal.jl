import Base.(>=), Base.(==), Base.(<=), Base.(<)

==(s::Side, t::SSetType) = !isempty(s) && s.x.t == t
function ==(a::Side, b::Side) 
	isempty(a) && isempty(b) && return true
	(isempty(a) || isempty(b)) && return false
	a.x.t == b.x.t || return false
	a.x.t == SSetLit && return value(a) == value(b)
	a.x.t == SSetId && return true
	todo
end


function <(x::Side, y::Surreal)
	isempty(x) && return true

	if x == SSetLit
		return value(x) < y
	elseif x == SSetId
		# is it greater than any natural number?
		isPositive(y) || return false
		return !isFinite(y)
	end

	todo
end

function <(x::Surreal, y::Side)
	isempty(y) && return true

	if y == SSetLit
		return x < value(y)
	end

	@show x y
	todo
end

>=(x::Surreal, y::Surreal) = y <= x
<=(x::Surreal, y::Surreal) = x.L < y && x < y.R # !any(l -> l >= y, x.L) && !any(r -> x >= r, y.R)
==(x::Surreal, y::Surreal) = y <= x && x <= y
<(x::Surreal, y::Surreal) = x <= y && !(y <= x)

function <=(x::Side, y::Side)
	isempty(x) && return true
	isempty(y) && return true
	x == SSetLit && y == SSetLit && return value(x) <= value(y)

	todo
end

>=(x::Side, y::Side) = y <= x
==(x::Side, y::Side) = y <= x && x <= y
<(x::Side, y::Side) = isempty(x) || isempty(y) || (x <= y && !(y <= x))
