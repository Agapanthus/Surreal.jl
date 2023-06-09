import Base.isempty

@enum SSetType begin
	SSetMul
	SSetInv
	SSetAdd
	SSetNeg
	#SSetPow
	SSetLit
	SSetId
end

struct SSet{T}
	t::SSetType
	l::Union{Nothing, SSet{T}}
	r::Union{Nothing, SSet{T}}
	v::T

	function SSet{T}(t::SSetType, l::Union{Nothing, SSet{T}} = nothing, r::Union{Nothing, SSet{T}} = nothing, v::T = T()) where {T}

		if t == SSetMul || t == SSetAdd # || t == SSetPow
			@assert !isnothing(l)
			@assert !isnothing(r)
			@assert isempty(v)
		elseif t == SSetInv || t == SSetNeg
			@assert !isnothing(l)
			@assert isnothing(r)
			@assert isempty(v)
		elseif t == SSetId || t == SSetLit
			@assert isnothing(l)
			@assert isnothing(r)
			(t != SSetLit) && @assert isempty(v)
		end

		new(t, l, r, v)
	end
end

struct SideT{T}
	x::Union{Nothing, SSet{T}}
end
struct Surreal
	L::SideT{Surreal}
	R::SideT{Surreal}

	function Surreal(L::SideT{Surreal}, R::SideT{Surreal})
		@assert L < R
		new(L, R)
	end
end

const Side = SideT{Surreal}
const ∅ = Side(nothing)
isempty(x::Side) = isnothing(x.x)
isempty(x::Surreal) = isempty(x.L) && isempty(x.R)

Side(t::SSetType, l::Side = ∅, r::Side = ∅, v::Surreal = S0) = Side(SSet{Surreal}(t, l.x, r.x, v))
Side(s::Surreal) = Side(SSetLit, ∅, ∅, s)

function value(s::Side)::Surreal
	@assert !isnothing(s.x)
	s.x.v
end