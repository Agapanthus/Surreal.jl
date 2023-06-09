
Surreal(L::Surreal, R::SS) = Surreal(SSS(SSetLit, ∅, ∅, L), R)
Surreal(L::SS, R::Surreal) = Surreal(L, SSS(SSetLit, ∅, ∅, R))
Surreal(L::Surreal, R::Surreal) = Surreal(SSS(SSetLit, ∅, ∅, L), SSS(SSetLit, ∅, ∅, R))

const S0 = Surreal(∅, ∅)
Surreal() = S0
const S1 = Surreal(S0, ∅)

function Surreal(n::Integer)
    local s = S0
    for i in 1:n
        s = Surreal(s, ∅)
    end
    for i in 1:(-n)
        s = Surreal(∅, s)
    end
    s
end

@assert Surreal(6) >= Surreal(3)