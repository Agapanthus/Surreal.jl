
Surreal(L::Surreal, R::Side) = Surreal(Side(L), R)
Surreal(L::Side, R::Surreal) = Surreal(L, Side(R))
Surreal(L::Surreal, R::Surreal) = Surreal(Side(L), Side(R))

const S0 = Surreal(∅, ∅)
Surreal() = S0
const S1 = Surreal(S0, ∅)
Base.iszero(x::Surreal) = x == S0

function Surreal(n::Integer)
	local s = S0
	for i in 1:n
		s = Surreal(s, ∅)
	end
	for i in 1:(-n)
		s = Surreal(∅, s)
	end
	s
end

#@assert Surreal(6) >= Surreal(3)
#@assert Surreal(1) == Surreal(0, 2)
#@assert Surreal(Surreal(-1, 0), ∅) == S0