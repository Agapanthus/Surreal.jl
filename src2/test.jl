

@assert Surreal(0) == S0
@assert Surreal(10) > Surreal(1) > Surreal(0) > Surreal(-1 // 2) > Surreal(-1)

@assert all(f -> toFrac(Surreal(f)) == f, [1 // 2, 1 // 8, 3 // 4, 1 // 1, 4 // 1, -4 // 1, 0 // 1])
@assert all(f -> toFrac(Surreal(f)) == f, [n // 32 for n in -10:40])

@assert all(x -> Surreal(x, nil) == Surreal(x + 1) == Surreal(x) + Surreal(1), 0:4)

@assert Surreal([2, 3], nil) + Surreal(3) == Surreal(7)
@assert Surreal([2, [2, 3]], nil) + Surreal(3) == Surreal(7)
@assert Surreal([2, [[[3]]]], nil) + Surreal([2, 1], nil) == Surreal(7)


@assert all(x -> x[1] == Surreal(x[2]) && toFrac(x[1]) == x[2], [
	(Surreal(1 // 4, 1), 1 // 2),
	(Surreal(-2, 21//8), 0),
	(Surreal([-2, -1], nil), 0),
	(Surreal(1, 8), 2),
	(Surreal(-4, -3), -7//2),
	(Surreal(-5, -3), -4),
])
