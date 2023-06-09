

const ω = Surreal(SSS(SSetId), ∅)

@assert Surreal(42) < ω
@assert !(Surreal(42) > ω)

@assert isInfinite(ω)

#@assert isInfinite(-ω)