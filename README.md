# Surreal.jl
Surreal Numbers in julia - even the non-finite ones!

This is highly experimental. Contact [Eric](https://github.com/Agapanthus) if you have questions.


```julia
> Surreal(1) + 1
2

> Surreal(2,3) == 5//2
true

> Surreal(0, Surreal(0,1))
1//4

> Surreal(1//4, 1//2)
3//8

> ω > 42
true

> isFinite(ω)
false

> min(ω, Surreal(2))
2
```