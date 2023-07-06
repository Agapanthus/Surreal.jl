
function runTests()
	@assert Surreal(0) ⊜ S0
	@assert Surreal(10) > Surreal(1) > Surreal(0) > Surreal(-1 // 2) > Surreal(-1)

	@assert all(f -> toFrac(Surreal(f)) == f, [1 // 2, 1 // 8, 3 // 4, 1 // 1, 4 // 1, -4 // 1, 0 // 1, 13311 // 32])
	@assert all(f -> toFrac(Surreal(f)) == f, [n // 32 for n in -10:40])

	@assert all(x -> Surreal(x, nil) ⊜ Surreal(x + 1) ⊜ Surreal(x) + Surreal(1), 0:4)

	@assert Surreal([2, 3], nil) + Surreal(3) ⊜ Surreal(7)
	@assert Surreal([2, [2, 3]], nil) + Surreal(3) ⊜ Surreal(7)
	@assert Surreal([2, [[[3]]]], nil) + Surreal([2, 1], nil) ⊜ Surreal(7)

	for (s, r) in [
		(Surreal(1 // 4, 1), 1 // 2),
		(Surreal(-2, 21 // 8), 0),
		(Surreal([-2, -1], nil), 0),
		(Surreal(1, 8), 2),
		(Surreal(-4, -3), -7 // 2),
		(Surreal(-5, -3), -4),
		(Surreal(3) + Surreal(5), 8),
		(Surreal(Surreal(1 // 128), nil), 1),
		(Surreal(3) - Surreal(5) + Surreal(1 // 2), -3 // 2),
	]
		@assert s ⊜ Surreal(r) (s, r)
		@assert toFrac(s) == r (s, r)
		@assert simplify(s) ⊜ s (s, r)
	end

	local randDyads(n, x = 5, y = 5) = Set([MyRational(rand(-x:x), rand([2^k for k in 0:y])) for _ in 1:n])

	for x in randDyads(1000)
		@assert toFrac(Surreal(x)) == x x
	end

	for x in randDyads(30), y in randDyads(5)
		@assert toFrac(Surreal(x + y)) == toFrac(Surreal(x) + Surreal(y))
	end

	for x in randDyads(5, 2, 3), y in randDyads(5, 2, 3), z in randDyads(5, 2, 3)
		@assert Surreal(y) + Surreal(x) ⊜ Surreal(x) + Surreal(y)
		local s0 = (Surreal(x) + Surreal(y)) + Surreal(z)
		local s1 = Surreal(x) + (Surreal(y) + Surreal(z))
		@assert toFrac(s0) == toFrac(s1)
	end

	@assert lca(41 // 8, 6 // 1) == (6 // 1, 11 // 2)
	@assert lca(-41 // 8, -6 // 1) == (-6 // 1, -11 // 2)
	@assert lca(1 // 1, 4 // 1) == (1 // 1, 2 // 1)

end

@time runTests()
