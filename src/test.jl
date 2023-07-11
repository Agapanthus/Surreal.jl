isSorted(v) = sort(v, lt = (x, y) -> confident(x < y), rev = true) == v



function runTests()
	@assert Bool(0 ≅ S0)

	@assert isSorted([omega, Surreal(10), Surreal(1), Surreal(0), Surreal(-1 // 2), Surreal(-1), -omega])

	@assert simplify(Surreal([1, 2], [3, 4])) ⊜ Surreal(2, 3)
	@assert simplify(Surreal([1, 2], [3, 4])) ⦷ Surreal(2, [3, 4])
	@assert confident(simplify(Surreal([1, 2], [3, 4])) ≅ Surreal(2, [3, 4]))

	@assert all(f -> toFrac(Surreal(f)) == f, [1 // 2, 1 // 8, 3 // 4, 1 // 1, 4 // 1, -4 // 1, 0 // 1, 13311 // 32])
	@assert all(f -> toFrac(Surreal(f)) == f, [n // 32 for n in -10:40])

	@assert all(x -> confident(Surreal(x, nil) ≅ Surreal(x + 1)), 0:4)
	@assert all(x -> confident(Surreal(x + 1) ≅ Surreal(x) + Surreal(1)), 0:4)

	@assert confident(Surreal([2, 3], nil) + Surreal(3) ≅ Surreal(7))
	@assert confident(Surreal([2, [2, 3]], nil) + Surreal(3) ≅ Surreal(7))
	@assert confident(Surreal([2, [[[3]]]], nil) + Surreal([2, 1], nil) ≅ Surreal(7))

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
		@assert confident(s ≅ Surreal(r)) (s, r)
		@assert toFrac(s) == r (s, r)
		@assert confident(simplify(s) ≅ s) (s, r)
	end

	local randDyads(n, x = 5, y = 5) = Set([MyRational(rand(-x:x), rand([2^k for k in 0:y])) for _ in 1:n])

	for x in randDyads(1000)
		@assert toFrac(Surreal(x)) == x x
	end

	for x in randDyads(30), y in randDyads(5)
		@assert toFrac(Surreal(x + y)) == toFrac(Surreal(x) + Surreal(y))
	end

	for x in randDyads(5, 2, 3), y in randDyads(5, 2, 3), z in randDyads(5, 2, 3)
		@assert confident(Surreal(y) + Surreal(x) ≅ Surreal(x) + Surreal(y))
		local s0 = (Surreal(x) + Surreal(y)) + Surreal(z)
		local s1 = Surreal(x) + (Surreal(y) + Surreal(z))
		@assert toFrac(s0) == toFrac(s1)
	end

	@assert lca(41 // 8, 6 // 1) == (6 // 1, 11 // 2)
	@assert lca(-41 // 8, -6 // 1) == (-6 // 1, -11 // 2)
	@assert lca(1 // 1, 4 // 1) == (1 // 1, 2 // 1)

	@assert simplify(Surreal([1, 2, [3, 4]], 5)) ⊜ Surreal(4, 5)

	@assert Surreal(1) + omega ⊜ omega + Surreal(1)
	@assert simplify(Surreal(0) + omega) ⊜ omega

	for n in [Surreal(0), Surreal(4), Surreal(3 // 8), Surreal(-1 // 8)]
		@assert confident(isFinite(n)) n
	end

	for n in [omega, omega + 3, -omega, omega - 1, simplify(omega - 1)]
		@assert confident(isInfinite(n)) n
	end

	@assert simplify(1 // 2 * omega) == Surreal(n_s, omega_s - n_s)

	@assert omega * S0 == S0
	
	#@assert confident(equiv(-omega + 1 // 2 - 1 // 2, -omega))

	#@assert isSorted([-omega - 3, -omega - 1 // 2, -omega, -omega + 1 // 4, -omega + 1, 0, simplify(omega - 1), omega, omega + 1 // 2, omega + 1])
	
end

@time runTests()
