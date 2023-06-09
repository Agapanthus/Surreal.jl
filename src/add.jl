
function Base.:+(x::Side, y::Surreal)::Side
	isempty(x) && return ∅
	iszero(y) && return x
	x == SSetLit && return Side(value(x) + y)
	return Side(SSetAdd, x, Side(y))
end
Base.:+(x::Surreal, y::Side)::Side = y + x


Base.:+(x::Surreal, y::Surreal)::Surreal =
	Surreal(max(x.L + y, x + y.L), min(x.R + y, x + y.R))

Base.:+(x::Surreal, y) = x + Surreal(y)
Base.:+(x, y::Surreal) = Surreal(x) + y

Base.:-(x::Surreal, y::Surreal)::Surreal = x + (-y)
Base.:-(x::Surreal, y) = x + (-Surreal(y))
Base.:-(x, y::Surreal) = Surreal(x) - y

@assert Surreal(0, 1) + Surreal(2, 3) == Surreal(3)
@assert iszero(Surreal(0, 1) - Surreal(0, 1))
