# Surreal.jl
Surreal Numbers in julia - even the non-finite ones!

This is highly experimental. Contact [Eric](https://github.com/Agapanthus) if you have questions.


This is based on a symbolic representation of the (infinite) tree of each number. The heart of most algorithms is context-sensitive simplification using SymbolicUtils.jl. It can solve some non-trivial cases already:

```
> omega + 3
(((ω|∅)|∅)|∅)

> 1//2 - omega
(-ω|(-ω|-n))

> simplify(1//2 * omega)
(n|(ω-n))

> isFinite(-omega)
No::MaybeBool = 0

> birthday(Surreal(3//8) + 1)
5

```

# TODO

goals of v0.0.3:

 - don't use recursion and multiple dispatch, but iterate directly
 - same surreal number = same memory location (within context). Simplifies type checks.
 - maximum type stability
 - cache everything (comparison, etc...) in ctx
   - ctx should be contiguous!
 - don't rely too much on omega-vs-dyadic properties like "isFinite" in rewriting - find more general concepts, i.e, compare archimedean classes!
 - be consistent with Julia naming, i.e., isfinite instead of isFinite