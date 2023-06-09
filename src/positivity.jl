
function isPositive(x::Surreal)
    # strictly positive

    isempty(x) && return false

    # TODO: is this correct?
    isempty(x.R) && !isempty(x.L) && return true

    @show x
    todo
end

