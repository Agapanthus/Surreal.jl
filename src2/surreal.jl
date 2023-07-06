struct Surreal
	L::SurrealSet
	R::SurrealSet

	function Surreal(L, R, check::Bool = true)
		local l = autoSurrealSet(L)
		local r = autoSurrealSet(R)
		# TODO: make a macro like "@inbounds" to turn this off
		check && @assert l < r "rule 1: l < r violated by $(l) an $(r)"
		new(l, r)
	end
end

<=(x::Surreal, y::Surreal) = x.L < y && x < y.R
Base.:(>=)(x::Surreal, y::Surreal) = y <= x
Base.:(==)(x::Surreal, y::Surreal) = y <= x && x <= y
Base.isequal(x::Surreal, y::Surreal) = x == y
Base.:(!=)(x::Surreal, y::Surreal) = !(x == y)
Base.:(<)(x::Surreal, y::Surreal) = x <= y && !(y <= x)
Base.isless(x::Surreal, y::Surreal) = x < y
Base.:(>)(x::Surreal, y::Surreal) = y < x

Base.show(io::IO, x::Surreal) = print(io, "(", x.L, "|", x.R, ")")
isDyadic(x::Surreal) = isDyadic(x.L) && isDyadic(x.R)

+(x::Surreal, y::Surreal)::Surreal = Surreal(lowerUnion(x.L + y, y.L + x), upperUnion(y + x.R, x + y.R))
-(x::Surreal) = Surreal(-x.R, -x.L)
-(x::Surreal, y::Surreal)::Surreal = x + (-y)
*(x::Surreal, y::Surreal)::Surreal = begin
	local xly = x.L * y
	local ylx = y.L * x
	local ll = x.L * y.L
	local xry = x.R * y
	local yrx = y.R * x
	local rr = x.R * y.R
	local lr = x.L * y.R
	local rl = x.R * y.L
	local l = lowerUnion(xly + ylx - ll, xry + yrx - rr)
	local r = upperUnion(xly + yrx - lr, ylx + xry - rl)
	Surreal(l, r)
end

"calculate 1/y for y a dyadic fraction"
function invDyadic(y::Surreal)::Surreal
	TODO
end

"calculate 1/y for any surreal y"
function inv(y::Surreal)::Surreal
	@assert y != 0
	isDyadic(y) && return invDyadic(y)
	isNegative(y) && (return neg(inv(neg(y))))

	TODO
	# requires infinite recursion with pattern detection 
end

/(x::Surreal, y::Surreal)::Surreal = x * inv(y)

"strictly negative"
isNegative(x::Surreal) = x < S0

"strictly positive"
isPositive(x::Surreal) = x > S0 # TODO: more efficient recursion: isPositive(x.L)

"convert to the first representation generated for this number"
function simplify(x::Surreal)
	if isDyadic(x)
		# TODO: is there a more efficient way to do this?
		return Surreal(toFrac(x))
	else
		TODO
	end
end

"birthday of this representation (not the representant of the equivalence group)"
birthday(x::Surreal) = max(birthday(x.L), birthday(x.R)) + 1

Base.length(x::Surreal) = 1
Base.iterate(x::Surreal) = (x, nothing)
Base.iterate(x::Surreal, ::Nothing) = nothing
