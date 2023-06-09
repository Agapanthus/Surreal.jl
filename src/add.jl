
function Base.:+(x::SSS, y::Surreal)::SSS

	todo
end
Base.:+(x::Surreal, y::SSS)::SSS = y + x

function union(x::SSS, y::SSS)::SSS
	todo
end
Base.:+(x::Surreal, y::Surreal)::Surreal =
	Surreal(union(x.L + y, x + y.L), union(x.R + y, x + y.R))
