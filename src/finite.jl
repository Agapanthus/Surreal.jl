
function finiteSupremum(x::Side)::Bool
    isempty(x) && return true
    x == SSetLit && (isNegative(value(x)) || isFinite(value(x))) && return true
    x == SSetId && return false
    
    todo
end

function finiteInfimum(x::Side)::Bool
    isempty(x) && return true
    x == SSetLit && (isPositive(value(x)) || isFinite(value(x))) && return true
    x == SSetId && return true
    
    @show x
    todo
end

function isFinite(x::Surreal)::Bool
    isempty(x) && return true
    finiteSupremum(x.L) && finiteInfimum(x.R) && return true
    !finiteSupremum(x.L) && return false
    !finiteInfimum(x.R) && return false

    todo
end

isInfinite(x::Surreal) = !isFinite(x)
