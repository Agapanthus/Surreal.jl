

const ω = Surreal(Side(SSetId), ∅)

#@assert Surreal(42) < ω
#@assert !(Surreal(42) > ω)
#@assert isInfinite(ω)
#@assert isInfinite(-ω)

const ϵ = Surreal(S0, Side(SSetInv, Side(SSetId)))

#@assert Surreal(-ω, 0) == -1
#@assert 0 < ϵ < 1//8
#@assert ϵ < ω
#@assert -ϵ != -1//2
#@assert isFinite(-ϵ)