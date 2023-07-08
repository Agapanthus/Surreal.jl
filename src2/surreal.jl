
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

@inline Surreal(x::Surreal) = x

<=(x::Surreal, y::Surreal) = x.L < y && x < y.R
Base.:(>=)(x::Surreal, y::Surreal) = y <= x
Base.:(<)(x::Surreal, y::Surreal) = x <= y && !(y <= x)
Base.isless(x::Surreal, y::Surreal) = x < y
Base.:(>)(x::Surreal, y::Surreal) = y < x

"same equivalence class"
equiv(x::Surreal, y::Surreal) = y <= x && x <= y
"same equivalence class"
≅(x::Surreal, y::Surreal) = equiv(x, y)
"not same equivalence class"
≇(x::Surreal, y::Surreal) = !(x ≅ y)

Base.:(==)(x::Surreal, y) = @assert false "use equiv or isequal"
Base.:(==)(x, y::Surreal) = @assert false "use equiv or isequal"
Base.:(==)(x::Surreal, y::Surreal) = isequal(x, y) # @assert false "use equiv or isequal" 
Base.:(!=)(x::Surreal, y) = @assert false "use equiv or isequal"
Base.:(!=)(x, y::Surreal) = @assert false "use equiv or isequal"
Base.:(!=)(x::Surreal, y::Surreal) = @assert false "use equiv or isequal" # !isequal(x, y)

"same representation"
Base.isequal(x::Surreal, y::Surreal) = typeof(x.L) === typeof(y.L) && typeof(x.R) === typeof(y.R) && isequal(x.L, y.L) && isequal(x.R, y.R)
"same representation"
⊜(x::Surreal, y::Surreal) = isequal(x, y)
"not same representation"
⦷(x::Surreal, y::Surreal) = !(x ⊜ y)

⊜(x::Surreal, y) = @assert false "wrong type"
⊜(x, y::Surreal) = @assert false "wrong type"
⦷(x::Surreal, y) = @assert false "wrong type"
⦷(x, y::Surreal) = @assert false "wrong type"

show2(io::IO, x::Surreal) = print(io, "(", x.L, "|", x.R, ")")

function Base.show(io::IO, x::Surreal)
	if isDyadic(x)
		local f = toFrac(x)
		if denominator(f) == 1
			print(io, numerator(f))
		else
			print(io, numerator(f), "/", denominator(f))
		end
	else
		show2(io, x)
	end
end

"whether it is a finite representation of dyadic fraction. A simplify could transform a representation to a finite dyadic"
isDyadic(x::Surreal) = isDyadic(x.L) && isDyadic(x.R)

"convert to the first representation generated for this number"
function simplify(x::Surreal)
	x = Surreal(simplify(x.L, false), simplify(x.R, true))

	# TODO: that's inefficient
	isDyadic(x) && return Surreal(toFrac(x))

	# TODO: more?
	return x
end


+(x::Surreal, y::Surreal)::Surreal = Surreal(lowerUnion(x.L + y, y.L + x), upperUnion(y + x.R, x + y.R))
+(x::Surreal) = x
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

for f in [:+, :*, :-, :<, :<=, :≅, :≇, :equiv]
	eval(quote
		@passDownType Surreal Int64 Surreal false ($f(x, y) = $f(x, y))
		@passDownType Surreal MyRational Surreal false ($f(x, y) = $f(x, y))
	end)
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

# TODO: make this more efficient
isZero(x::Surreal) = equiv(x, S0)

isZeroFast(x::Surreal) = isDyadic(x) && toFrac(x) == 0
isOneFast(x::Surreal) = isDyadic(x) && toFrac(x) == 1

function isFinite(x::Surreal)
	isDyadic(x) && return true
	return (isPositive(x) && hasUpperLimit(x.L)) || (isNegative(x) && hasLowerLimit(x.R))
end
isInfinite(x::Surreal) = !isFinite(x)

"birthday of this representation (not the representant of the equivalence group)"
birthday(x::Surreal) = max(birthday(x.L), birthday(x.R)) + 1

Base.length(x::Surreal) = 1
Base.iterate(x::Surreal) = (x, nothing)
Base.iterate(x::Surreal, ::Nothing) = nothing

"true if it is omega, false if not sure"
function isOmegaFast(x::Surreal)
	x == omega && return true
	isInfinite(x) || return false
	#isPositive(x) || return false

	return false
end

"true if it is -omega, false if not sure"
function isMinusOmegaFast(x::Surreal)
	x == -omega && return true
	isInfinite(x) || return false
	#isNegative(x) || return false

	return false
end

