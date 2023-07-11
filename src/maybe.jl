@enum MaybeBool begin
	No
	Maybe
	Yes
end

function (&)(x::MaybeBool, y::MaybeBool)::MaybeBool
	(x == Yes && y == Yes) && return Yes
	(x == No && y == No) && return No
	return Maybe
end

function (|)(x::MaybeBool, y::MaybeBool)::MaybeBool
	(x == Yes || y == Yes) && return Yes
	(x == No && y == No) && return No
	return Maybe
end

#convert(::Type{MaybeBool}, x::Bool) = x ? Yes : No
#convert(::Type{Bool}, x::MaybeBool) = x == Yes
Base.Bool(x::MaybeBool)::Bool = x == Yes

macro and(x, y)
	quote
		let res = $(esc(x))
			res == No && return No
			local res2 = $(esc(y))
			res2 == No && return No
			res == Yes && res2 == Yes && return Yes
			return Maybe
		end
	end
end

macro or(x, y)
	quote
		let res = $(esc(x))
			res == Yes && return Yes
			local res2 = $(esc(y))
			res2 == Yes && return Yes
			res == No && res2 == No && return No
			return Maybe
		end
	end
end

macro trif(o, x, y, z)
	quote
		let res = $(esc(o))
			if res == Yes
				$(esc(x))
			elseif res == No
				$(esc(z))
			else
				$(esc(y))
			end
		end
	end
end

function Base.:(!)(x::MaybeBool)::MaybeBool
	x == Yes && return No
	x == No && return Yes
	return Maybe
end

Base.:(+)(x::MaybeBool)::Bool = Bool(x)

all2(f, v::AbstractVector) = all2(map(f, v)::Vector{MaybeBool})
function all2(v)::MaybeBool
	local finalRes = Yes
	for res in v
		res == No && return No
		res == Maybe && (finalRes = Maybe)
	end
	return finalRes
end

any2(f, v::AbstractVector) = any2(map(f, v)::Vector{MaybeBool})
function any2(v)::MaybeBool
	local finalRes = No
	for res in v
		res == Yes && return Yes
		res == Maybe && (finalRes = Maybe)
	end
	return finalRes
end

"assumes the MaybeBool is Yes or No and is casted to a Bool"
confident(x::MaybeBool)::Bool = @trif x true (@assert false "expected not maybe") false