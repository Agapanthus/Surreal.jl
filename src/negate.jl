
Base.:-(::Nothing) = nothing
function Base.:-(x::Side)::Side
	isempty(x) && return ∅
	x == SSetLit && return Side(-value(x))
	x == SSetId && return Side(SSetNeg, Side(SSetId))
	x == SSetNeg && return left(x)

	@show x
	todo
end
Base.:-(x::Surreal)::Surreal = Surreal(-x.R, -x.L)

@assert Surreal(Surreal(-1, 0), ∅) == -Surreal(Surreal(-1, 0), ∅)
