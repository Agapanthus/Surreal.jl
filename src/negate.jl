
Base.:-(::Nothing) = nothing
function Base.:-(x::SSS)::SSS
    isempty(x) && return ∅
    x.t == SSetLit && return SSS(SSetLit, ∅, ∅, -x.v)
    x.t == SSetId && return SSS(SSetNeg, SSS(SSetId))
    
    todo
end
Base.:-(x::Surreal)::Surreal = Surreal(-x.R, -x.L)
