import Base.(>=), Base.(==), Base.(<=), Base.(<), Base.(>), Base.isless


function <(x::SS, y::Surreal)
    isempty(x) && return true

    if x.t == SSetLit
        return x.v < y
    elseif x.t == SSetId
        # is it greater than any natural number?
        isPositive(y) || return false
        return !isFinite(y)
    end

    todo
end

function <(x::Surreal, y::SS)
    isempty(y) && return true

    if y.t == SSetLit
        return x < y.v
    end

    @show x y
    todo
end

>=(x::Surreal, y::Surreal) = y <= x
<=(x::Surreal, y::Surreal) = x.L < y && x < y.R # !any(l -> l >= y, x.L) && !any(r -> x >= r, y.R)
==(x::Surreal, y::Surreal) = y <= x && x <= y
<(x::Surreal, y::Surreal) = x <= y && !(y <= x)
>(x::Surreal, y::Surreal) = y < x

function <=(x::SS, y::SS)
    isempty(x) && return true
    isempty(y) && return true
    x.t == SSetLit && y.t == SSetLit && return x.v <= y.v

    todo
end

>=(x::SS, y::SS) = y <= x
==(x::SS, y::SS) = y <= x && x <= y
<(x::SS, y::SS) = isempty(x) || isempty(y) || (x <= y && !(y <= x))
