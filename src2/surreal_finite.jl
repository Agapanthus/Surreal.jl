import Base.(>=), Base.(==), Base.(<)

#=

struct FiniteSurreal <: AbstractSurreal
	L::Vector{FiniteSurreal}
	R::Vector{FiniteSurreal}

	function FiniteSurreal(L, R)
		local l = finiteSurreal(L)
		local r = finiteSurreal(R)
		@assert l < r
		new(l, r)
	end
end

finiteSurreal(x::Vector{FiniteSurreal}) = x
finiteSurreal(x::FiniteSurreal) = [x]
finiteSurreal(::Nothing) = []

=#