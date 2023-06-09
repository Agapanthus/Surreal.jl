

function Base.maximum(s::Side)::Union{Surreal, Nothing}
	isempty(s) && return nothing
	s == SSetLit && return value(s)
	s == SSetId && return ω

	todo
end


function Base.minimum(s::Side)::Union{Surreal, Nothing}
	isempty(s) && return nothing
	s == SSetLit && return value(s)
	s == SSetId && return S1
	
	@show s
	todo
end

function max(x::Surreal, y::Surreal)::Surreal
	x >= y && return x
	y >= x && return y
	fuzzy
end

function min(x::Surreal, y::Surreal)::Surreal
	x >= y && return y
	y >= x && return x
	fuzzy
end

function max(x::Side, y::Side)::Side
	isempty(x) && return y
	isempty(y) && return x

	local r = x <= y
	r == true && return y
	r == false && return x

	# they overlap...
	@show x y
	todo
end

function min(x::Side, y::Side)::Side
	isempty(x) && return y
	isempty(y) && return x
	
	local r = x <= y
	r == true && return x
	r == false && return y

	# they overlap...
	@show x y
	todo
end
