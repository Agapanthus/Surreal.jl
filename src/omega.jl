

const ω = Surreal(Side(SSetId), ∅)

@assert Surreal(42) < ω
@assert !(Surreal(42) > ω)

@assert isInfinite(ω)

#@assert isInfinite(-ω)

const ϵ = Surreal(S0, Side(SSetInv, Side(SSetId)))