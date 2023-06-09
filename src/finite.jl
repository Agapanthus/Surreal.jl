
function finiteSupremum(s::Side)::Bool
	isempty(s) && return true
	s == SSetLit && (isNegative(value(s)) || isFinite(value(s))) && return true
	s == SSetId && return false
	return !isPosUnlimited(s)
end

function finiteInfimum(s::Side)::Bool
	isempty(s) && return true
	s == SSetLit && (isPositive(value(s)) || isFinite(value(s))) && return true
	s == SSetId && return true

	return !isPosUnlimited(Side(SSetNeg, s))
end

function isFinite(x::Surreal)::Bool
	isempty(x) && return true
	!finiteSupremum(x.L) && return false
	!finiteInfimum(x.R) && return false
    return true
end

isInfinite(x::Surreal) = !isFinite(x)
