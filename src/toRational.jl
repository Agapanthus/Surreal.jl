function toRNaive(s::Surreal)
	isempty(s.L) && isempty(s.R) && return 0
	local msr = minimum(s.R)
	local msl = maximum(s.L)
	isempty(s.L) && return toRNaive(msr) - 1
	isempty(s.R) && return toRNaive(msl) + 1
	return (toRNaive(minimum(s.R)) + toRNaive(msl)) // 2
end

function simplify(s::Surreal, lo::Surreal, hi::Surreal)
	lo == s && return lo
	hi == s && return hi
	local m = Surreal(lo, hi)
	m >= s && return simplify(s, lo, m)
	@assert m <= s
	return simplify(s, m, hi)
end

function simplify(s::Surreal)
	if s <= Surreal(0)
		local highestLeq = -findfirst(x -> Surreal(x) <= s, -1:-1:-10000)
		return simplify(s, Surreal(highestLeq), Surreal(highestLeq + 1))
	else
		@assert s >= Surreal(0)
		local lowestGeq = findfirst(x -> Surreal(x) >= s, 1:10000)
		return simplify(s, Surreal(lowestGeq - 1), Surreal(lowestGeq))
	end
end

function toR(s::Surreal)
	@assert isFinite(s)
	local t = toRNaive(simplify(s))
	denominator(t) == 1 && return numerator(t)
	t
end


function Surreal(r::Rational, n::Integer=7)
    function approx(lo::Surreal, hi::Surreal, q::Integer)
        toRNaive(lo) >= r && return lo
        toRNaive(hi) <= r && return hi
        local m = Surreal(lo, hi)
        q < 0 && return m
        toRNaive(m) >= r && return approx(lo, m, q-1)
        return approx(m, hi, q-1)
    end
    return approx(
        Surreal(convert(Integer,floor(r))), 
        Surreal(convert(Integer, ceil(r))), n)
end