
Base.:-(::Nothing) = nothing
function Base.:-(x::Side)::Side
	isempty(x) && return ∅
	x == SSetLit && return Side(-value(x))
	x == SSetNeg && return left(x)
	x == SSetAdd && return Side(SSetAdd, -left(x), -right(x))
	return Side(SSetNeg, x)
end
Base.:-(x::Surreal)::Surreal = Surreal(-x.R, -x.L)

#@assert Surreal(Surreal(-1, 0), ∅) == -Surreal(Surreal(-1, 0), ∅)
