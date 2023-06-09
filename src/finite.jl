
function finiteSupremum(s::Side)::Bool
	isempty(s) && return true
	s == SSetLit && (isNegative(value(s)) || isFinite(value(s))) && return true
	s == SSetId && return false
	return !isUnlimited(s, true)
end

function finiteInfimum(s::Side)::Bool
	isempty(s) && return true
	s == SSetLit && (isPositive(value(s)) || isFinite(value(s))) && return true
	s == SSetId && return true
	return !isUnlimited(s, false)
end

function isFinite(x::Surreal)::Bool
	isempty(x) && return true
	!finiteSupremum(x.L) && return false
	!finiteInfimum(x.R) && return false
	return true
end

function isFiniteStructure(x::Surreal)::Bool
	isempty(x) && return true
	isempty(x.L) || (x.L == SSetLit && isFinite(value(x.L))) || return false
	isempty(x.R) || (x.R == SSetLit && isFinite(value(x.R))) || return false
	return true
end

isInfinite(x::Surreal) = !isFinite(x)
