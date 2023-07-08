# based on SymbolicUtils/types.jl

"""
	makeadd(sign, coeff::Surreal, xs...)

Any Muls inside an Add should always have a coeff of 1
and the key (in Add) should instead be used to store the actual coefficient
"""
function makeadd(sign, coeff::Surreal, xs...)
	local d = Dict{SubSe, Surreal}()
	for x in xs
		if isadd(x)
			coeff += x.coeff
			symUtil_merge!(+, d, x.dict, filter = _iszero)
			continue
		end

		if x isa Surreal
			coeff += x
			continue
		elseif isTerm(x) && operation(x) == X_s
			coeff += left(x)
			continue
		end

		if ismul(x)
			k = Mul(SurrealExpression, S1, x.dict)
			v = sign * x.coeff + get(d, k, S0)
		else
			k = x
			v = sign + get(d, x, S0)
		end
		if iszero(v)
			delete!(d, k)
		else
			d[k] = v
		end
	end
	coeff, d
end

_iszero(x) = x isa Surreal && isZeroFast(x)
_isone(x) = x isa Surreal && isOneFast(x)
SymbolicUtils._iszero(x::Surreal) = _iszero(x)
SymbolicUtils._isone(x::Surreal) = _isone(x)

function +(a::SubSe, b::SubSe)
	if isadd(a) && isadd(b)
		return Add(SurrealExpression,
			a.coeff + b.coeff,
			symUtil_merge(+, a.dict, b.dict, filter = _iszero))
	elseif isadd(a)
		coeff, dict = makeadd(1, S0, b)
		return Add(SurrealExpression, a.coeff + coeff, symUtil_merge(+, a.dict, dict, filter = _iszero))
	elseif isadd(b)
		return b + a
	end
	coeff, dict = makeadd(1, S0, a, b)
	Add(SurrealExpression, coeff, dict)
end

@commu +(a::Surreal, b::SubSe) = begin
	if isadd(b)
		Add(SurrealExpression, a + b.coeff, b.dict)
	else
		Add(SurrealExpression, makeadd(1, a, b)...)
	end
end

function -(a::SubSe)
	isadd(a) ? Add(SurrealExpression, -a.coeff, mapvalues((_, v) -> -v, a.dict)) :
	Add(SurrealExpression, makeadd(-1, S0, a)...)
end

function -(a::SubSe, b::SubSe)
	isadd(a) && isadd(b) ? Add(SurrealExpression,
		a.coeff - b.coeff,
		symUtil_merge(-, a.dict,
			b.dict,
			filter = _iszero)) : a + (-b)
end

-(a::Surreal, b::SubSe) = a + (-b)
-(a::SubSe, b::Surreal) = a + (-b)

for f in [:+, :*, :-, :/], T in [Integer, MyRational]
	eval(quote
		$f(a::$T, b::SubSe) = $f(Surreal(a), b)
		$f(a::SubSe, b::$T) = $f(a, Surreal(b))
	end)
end



###
### Pow
###

function ^(a::SubSe, b::Surreal)
	if b isa Number && iszero(b)
		# fast path
		1
	elseif b isa Number && b < 0
		Div(S1, a^(-b))
	elseif ismul(a) && b isa Number
		coeff = SymbolicUtils.unstable_pow(a.coeff, b)
		Mul(SurrealExpression, coeff, mapvalues((k, v) -> b * v, a.dict))
	else
		Pow(a, b)
	end
end

^(a::Surreal, b::SubSe) = Pow(a, b)
^(a::SubSe, b::Integer) = a^Surreal(b)
