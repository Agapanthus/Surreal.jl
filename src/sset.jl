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
    l::Union{Nothing,SSet{T}}
    r::Union{Nothing,SSet{T}}
    v::T

    function SSet{T}(t::SSetType, l::Union{Nothing,SSet{T}}=nothing, r::Union{Nothing,SSet{T}}=nothing, v::T=T()) where {T}

        if t == SSetMul || t == SSetAdd # || t == SSetPow
            @assert !isempty(l)
            @assert !isempty(r)
            @assert isempty(v)
        elseif t == SSetInv || t == SSetNeg
            @assert !isempty(l)
            @assert isempty(r)
            @assert isempty(v)
        elseif t == SSetId || t == SSetLit
            @assert isempty(l)
            @assert isempty(r)
            (t != SSetLit) && @assert isempty(v)
        end

        new(t, l, r, v)
    end
end

struct Surreal
    L::Union{Nothing,SSet{Surreal}}
    R::Union{Nothing,SSet{Surreal}}

    function Surreal(L::Union{Nothing,SSet{Surreal}}, R::Union{Nothing,SSet{Surreal}})
        @assert L < R
        new(L, R)
    end
end

const ∅ = nothing # SSet{Surreal}() 
const SSS = SSet{Surreal}
const SS = Union{Nothing,SSS}
isempty(x::SS) = isnothing(x) #x.t == SSetEmp
isempty(x::Surreal) = isempty(x.L) && isempty(x.R)
