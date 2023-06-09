
function finiteSupremum(x::SS)
    isempty(x) && return true
    x.t == SSetLit && isFinite(x.v) && return true
    x.t == SSetId && return false
    todo
end

function finiteInfimum(x::SS)
    isempty(x) && return true

    todo
end

function isFinite(x::Surreal)
    isempty(x) && return true
    finiteSupremum(x.L) && finiteInfimum(x.R) && return true
    !finiteSupremum(x.L) && return false
    !finiteInfimum(x.R) && return false

    todo
end

isInfinite(x::Surreal) = !isFinite(x)
