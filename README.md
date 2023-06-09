# Surreal.jl
Surreal Numbers in julia - even the non-finite ones!

This is highly experimental. Contact [Eric](https://github.com/Agapanthus) if you have questions.


Comparisons are based on the heuristic `sympy.solveset` so they can be wrong in complicated situations... (though, `sympy.solveset` is designed to be a robust solver that indicates when the result is unsure)

```julia
> Surreal(1) + 1
2

> Surreal(2,3) == 5//2
true

> Surreal(0, Surreal(0,1))
1//4

> Surreal(1//4, 1//2)
3//8

> Surreal(3,4) - Surreal(1//8)
27//8

> ω > 42
true

> isFinite(-ω)
false

> min(ω, Surreal(2))
2

> Surreal(-ω, 0)
-1

> 0 < ϵ < 1
true

> ϵ < ω
true


```