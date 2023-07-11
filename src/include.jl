using Match

include("rule.jl")

import Base.(<=), Base.isequal, Base.(<), Base.(^), Base.(+), Base.(-), Base.(*), Base.(/)

include("surreal_abstract.jl")
include("surreal.jl")
include("surreal_empty.jl")
include("surreal_singular.jl")
include("surreal_vector.jl")
include("surreal_dyadic.jl")

#using Symbolics
using SymbolicUtils: SymbolicUtils, Symbolic, @syms, @rule, @acrule
using SymbolicUtils: nameof, symtype, exprtype, operation, arguments
using SymbolicUtils: Add, Mul, Pow, Div, isadd, isdiv, ispow, ismul, _merge as symUtil_merge, mapvalues

include("SurrealExpression/syms.jl")
include("SurrealExpression/build.jl")
include("SurrealExpression/limits.jl")
include("SurrealExpression/rules.jl")
include("surreal_counted.jl")


include("constants_simple.jl")