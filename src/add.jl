
function Base.:+(x::Side, y::Surreal)::Side
	isempty(x) && return ∅
	y == S0 && return x
	x == SSetLit && return Side(value(x) + y)

	dump(x)
	dump(y)
	todo
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
