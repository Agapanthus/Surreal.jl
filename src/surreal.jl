
struct Surreal <: SurrealExpression
	L::SurrealSet
	R::SurrealSet

	function Surreal(L, R, check::Bool = true)
		local l = autoSurrealSet(L)
		local r = autoSurrealSet(R)
		# TODO: make a macro like "@inbounds" to turn this off
		if check
			local res = l < r
			if res == No
				error("rule 1: l < r violated by $(l) and $(r)")
			elseif res == Maybe
				warn("_Possibly_ rule 1: l < r violated by $(l) and $(r)")
			end
		end

		new(l, r)
	end
end

@inline Surreal(x::Surreal) = x

<=(x::Surreal, y::Surreal)::MaybeBool = @and (x.L < y) (x < y.R)
Base.:(>=)(x::Surreal, y::Surreal)::MaybeBool = y <= x
Base.:(<)(x::Surreal, y::Surreal)::MaybeBool = @and (x <= y) (!(y <= x))
Base.isless(x::Surreal, y::Surreal)::MaybeBool = x < y
Base.:(>)(x::Surreal, y::Surreal)::MaybeBool = y < x

"same equivalence class"
equiv(x::Surreal, y::Surreal)::MaybeBool = @and (y <= x) (x <= y)
"same equivalence class"
≅(x::Surreal, y::Surreal) = equiv(x, y)
"not same equivalence class"
≇(x::Surreal, y::Surreal) = !(x ≅ y)

function Base.:(==)(x::Surreal, y::Int64)
	# TODO: fishy. This shouldn't exist, but is called while rewriting -omega + 1//2
	return isequal(x, Surreal(y))
end
Base.:(==)(x::Surreal, y) = @assert false ("use equiv or isequal", x, y)
Base.:(==)(x, y::Surreal) = @assert false ("use equiv or isequal", x, y)
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
	elseif isOmegaFast(x)
		print(io, "ω")
	elseif isMinusOmegaFast(x)
		print(io, "-ω")
	else
		show2(io, x)
	end
end

"whether it is a finite representation of dyadic fraction. A simplify could transform a representation to a finite dyadic"
isDyadic(x::Surreal)::Bool = isDyadic(x.L) && isDyadic(x.R)

"convert to the first representation generated for this number"
function simplify(x::Surreal)
	x = Surreal(simplify(x.L, false), simplify(x.R, true))

	# TODO: that's inefficient
	isDyadic(x) && return Surreal(toFrac(x))

	# TODO: more?
	return x
end


"add, only using the naive defintion"
function addDirect(x::Surreal, y::Surreal)::Surreal
	local l = leftUnion(x.L + y, y.L + x)
	local r = rightUnion(y + x.R, x + y.R)
	return Surreal(l, r)
end

"add, but try to use tricks to be fast"
function add(x::Surreal, y::Surreal)::Surreal
	if isDyadic(x) && isDyadic(y)
		return Surreal(toFrac(x) + toFrac(y))
	end

	addDirect(x, y)
end

"multiply, only using the naive defintion"
function mulDirect(x::Surreal, y::Surreal)::Surreal
	local xly = x.L * y
	local ylx = y.L * x
	local ll = x.L * y.L
	local xry = x.R * y
	local yrx = y.R * x
	local rr = x.R * y.R
	local lr = x.L * y.R
	local rl = x.R * y.L
	local l = leftUnion(xly + ylx - ll, xry + yrx - rr)
	local r = rightUnion(xly + yrx - lr, ylx + xry - rl)
	return Surreal(l, r)
end

function tryMulByAdding(x::Surreal, y::Surreal)
	if isDyadic(x)
		local n = toFrac(x)
		if denominator(n) == 1 && abs(numerator(n)) < 10
			local res = Surreal(0)
			for _ in 1:abs(numerator(n))
				res += y
			end
			if numerator(n) < 0
				res = -res
			end
			return res
		end
	end
	return nothing
end

"multiply, try to use tricks to be fast"
function mul(x::Surreal, y::Surreal)::Surreal
	isDyadic(x) && isDyadic(y) && return Surreal(toFrac(x) * toFrac(y))
	isequal(x, SM1) && return -y
	isequal(y, SM1) && return -x
	isequal(x, S1) && return y
	isequal(y, S1) && return x
	isequal(y, S0) && return S0
	isequal(x, S0) && return S0

	local res = tryMulByAdding(x, y)
	isnothing(res) || return res
	res = tryMulByAdding(y, x)
	isnothing(res) || return res

	return mulDirect(x, y)
end

+(x::Surreal, y::Surreal) = add(x, y)
+(x::Surreal) = x
-(x::Surreal) = Surreal(-x.R, -x.L)
-(x::Surreal, y::Surreal)::Surreal = x + (-y)
*(x::Surreal, y::Surreal)::Surreal = mul(x, y)

Base.max(x::Surreal, y::Surreal) = @trif x > y x error("max not possible") y
Base.min(x::Surreal, y::Surreal) = @trif x < y x error("min not possible") y

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
isNegative(x::Surreal)::MaybeBool = x < S0

"strictly positive"
isPositive(x::Surreal)::MaybeBool = x > S0 # TODO: more efficient recursion: isPositive(x.L)

# TODO: make this more efficient
isZero(x::Surreal)::MaybeBool = equiv(x, S0)

isZeroFast(x::Surreal)::Bool = isDyadic(x) && toFrac(x) == 0
isOneFast(x::Surreal)::Bool = isDyadic(x) && toFrac(x) == 1

function isFinite(x::Surreal)::MaybeBool
	isDyadic(x) && return Yes
	return @or (@and isPositive(x) hasUpperLimit(x.L)) (@and isNegative(x) hasLowerLimit(x.R))
end
isInfinite(x::Surreal)::MaybeBool = !isFinite(x)
isPosInfinite(x::Surreal)::MaybeBool = @and isInfinite(x) isPositive(x)
isNegInfinite(x::Surreal)::MaybeBool = @and isInfinite(x) isNegative(x)
hasLowerLimit(x::Surreal)::MaybeBool = @or isPositive(x) isFinite(x)
hasUpperLimit(x::Surreal)::MaybeBool = @or isNegative(x) isFinite(x)
hasFiniteElements(x::Surreal)::MaybeBool = isFinite(x)
hasInfiniteElements(x::Surreal)::MaybeBool = isInfinite(x)
allPositive(x::Surreal)::MaybeBool = isPositive(x)
allNegative(x::Surreal)::MaybeBool = isNegative(x)
hasPositive(x::Surreal)::MaybeBool = isNegative(x)
hasNegative(x::Surreal)::MaybeBool = isNegative(x)
allZero(x::Surreal)::MaybeBool = isZero(x)

"birthday of this representation (not the representant of the equivalence group)"
birthday(x::Surreal) = max(birthday(x.L), birthday(x.R)) + 1

Base.length(x::Surreal) = 1
Base.iterate(x::Surreal) = (x, nothing)
Base.iterate(x::Surreal, ::Nothing) = nothing

"true if it is omega, false if not sure"
function isOmegaFast(x::Surreal)::Bool
	x == omega && return true
	#isInfinite(x) || return false
	#isPositive(x) || return false

	return false
end

"true if it is -omega, false if not sure"
function isMinusOmegaFast(x::Surreal)::Bool
	x == -omega && return true
	#isInfinite(x) || return false
	#isNegative(x) || return false

	return false
end

