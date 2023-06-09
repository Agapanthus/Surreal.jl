
function isPositive(x::Surreal)::Bool
	# strictly positive

	iszero(x) && return false

	# TODO: is this correct?
	#isempty(x.R) && !isempty(x.L) && return true

    return x >= S0
end


function isNegative(x::Surreal)::Bool
	iszero(x) && return false


    return x <= S0
	#return isPositive(-x)
end
