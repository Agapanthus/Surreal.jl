using Match

include("rule.jl")

include("surreal_abstract.jl")
include("surreal.jl")
include("surreal_empty.jl")
include("surreal_singular.jl")
include("surreal_vector.jl")
include("constants_simple.jl")
include("surreal_dyadic.jl")

#using Symbolics
using SymbolicUtils: SymbolicUtils, Symbolic, @syms, @rule, nameof, symtype, exprtype, operation, arguments

include("surrealExpression.jl")
include("surreal_counted.jl")