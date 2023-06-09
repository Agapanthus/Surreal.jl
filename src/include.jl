using SymPy

#@vars xVar real=true
#@vars wVar
#solveset(LessThan(-xVar, 1), xVar, domain=sympy.S.Reals)

include("sset.jl")
include("compare.jl")
include("positivity.jl")
include("finite.jl")
include("minmax.jl")

include("fromInt.jl")
include("dyadic.jl")

include("toRational.jl")
include("show.jl")


include("negate.jl")
include("add.jl")
include("omega.jl")