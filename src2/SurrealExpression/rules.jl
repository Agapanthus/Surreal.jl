

"show errors"
function se(f)
	return x -> try
		return f(x)
	catch err
		showerror(stdout, err)
		#display(stacktrace(catch_backtrace()))
		Base.show_backtrace(stdout, Base.catch_backtrace())
	end
end

seNot(f) = se(x -> !f(x))

"surreal check"
function sc(f)
	return x -> begin
		x isa Surreal && return se(f)(x)
		return false
	end
end


notUB(x) = !(x isa SubSe && isTerm(x) && operation(x) == ub_s)
notLB(x) = !(x isa SubSe && isTerm(x) && operation(x) == lb_s)

isSurreal(x) = x isa Surreal
isPositiveDyadic(x) = isDyadic(x) && isPositive(x)
isNegativeDyadic(x) = isDyadic(x) && isNegative(x)

notTrivialZero(x) = !(x isa Surreal && isZeroFast(x))

function createRewriters()
	simplificationRules = [
		@rule ~x::se(isSurreal) => se(simplify)(~x)
	]

	additionRules = [
        @rule -(~x) => -1(~x)
        @rule -(~x, ~y) => ~x + -1(~y)

	#  @rule add(~x, S(∅, ∅)) => ~x
	#  @rule add(SSS(~x), ~y) => SSS(~x ⊕ ~y)

	# @rule (S(∅, ∅) ⊕ ~y) => ~y
	# @rule (~x ⊕ S(∅, ∅)) => ~x
	# @rule (S(~XL, ~XR) ⊕ S(~YL, ~YR)) =>  S(maxUnion(add(~XL, S(~YL, ~YR)), add(~YL, S(~XL, ~XR))), minUnion(add(~XR, S(~YL, ~YR)), add(~YR, S(~XL, ~XR))))
	]

	# upper bound focused (left side)
	ubRules = [
		# remove around single values
		@rule ub_s(~x::se(isSurreal)) => (~x)
		@rule ub_s(n_s) => n_s
		@rule ub_s(ub_s(~x)) => ub_s(~x)
		@rule ub_s(omega_s) => omega_s

		# transport into union        
		@rule ub_s(uu_s(~x, ~y)) => uu_s(ub_s(~x), ub_s(~y))

		# ignore finite additions to unlimited stuff  # TODO: acrule?
		@rule ub_s(~x::sc(isFinite) + n_s) => n_s

		# ignore finite multiplications of unlimited stuff
		@rule ub_s(~x::sc(isPositiveDyadic) * n_s) => n_s

	]

	# lower bound focused (right side)
	lbRules = [
		# remove around single values        
		@rule lb_s(~x::se(isSurreal)) => (~x)
		@rule lb_s(-1(n_s)) => -1(n_s)
		@rule lb_s(lb_s(~x)) => lb_s(~x)
		@rule lb_s(omega_s) => omega_s

		# transport into union     
		@rule lb_s(lu_s(~x, ~y)) => lu_s(lb_s(~x), lb_s(~y))

		# ignore finite additions to infinite stuff  # TODO: acrule? apparently only works when addition at base-level
		@rule lb_s(~x::sc(isFinite) + (-1(n_s))) => -1(n_s)
		
		# ignore finite multiplications of unlimited stuff
		@rule lb_s(~x::sc(isNegativeDyadic) * n_s) => -n_s

		# LAST RULE (everything else tried before!): move lb_s inwards
		@rule lb_s(~x + ~y) => lb_s(~x) + lb_s(~y)

	]

	# upper union
	uuRules = [
		# ignore merging smaller stuff
		@rule uu_s(n_s, ~x::sc(isPosInfinite)) => ~x
		@rule uu_s(~x::sc(isPosInfinite), n_s) => ~x

		# merge comparable values # TODO: could be problem if causing recursion
		@rule uu_s(~x::se(isSurreal), ~y::se(isSurreal)) => max(~x, ~y)

		# same on both sides is irrelevant
		@rule uu_s(~x, ~x) => ~x
	]

	# lower union
	luRules = [
		# ignore merging smaller stuff 
		@rule lu_s(-1(n_s), ~x::sc(isNegInfinite)) => ~x
		@rule lu_s(~x::sc(isNegInfinite), -1(n_s)) => ~x

		# merge comparable values # TODO: could be problem if causing recursion
		@rule lu_s(~x::se(isSurreal), ~y::se(isSurreal)) => min(~x, ~y)

		# same on both sides is irrelevant
		@rule lu_s(~x, ~x) => ~x
	]


	# is positive
	isPosRules = [
		# try to postpone the problem
		@rule isPos_s(~x::se(isSurreal)) => isPositive(~x)
		@rule isPos_s(~y) => allPositive(~y)

		#=
		@rule le_s(~x::seNot(hasInfiniteElements), ~y::sc(isPosInfinite)) => true
		@rule le_s(~x::seNot(hasUpperLimit), ~y::se(hasFiniteElements)) => false

		@rule le_s(~x::sc(isNegInfinite), ~y::seNot(hasInfiniteElements)) => true
		@rule le_s(~x::se(hasFiniteElements), ~y::seNot(hasLowerLimit)) => false

		@rule le_s(ub_s(~x::se(notTrivialZero)), lb_s(~y)) => le_s(S0, ~y - ~x)
		@rule le_s(ub_s(~x::se(notTrivialZero)), ~y) => le_s(S0, ~y - ~x)
		@rule le_s(~x::se(notTrivialZero), ~y) => le_s(S0, ~y - ~x)
		=#

		@rule le_s(n_s, ~y::sc(isPosInfinite)) => true
	]


	de_prettify = [
		@rule omega_s => omega
	]

	# interferes with other rules since numbers aren't of type Surreal anymore
	prettify = [
		@rule ~x::sc(isOmegaFast) => omega_s
		@rule ~x::sc(isMinusOmegaFast) => -1(omega_s)

		@rule ub_s(~x) => ~x
		@rule lb_s(~x) => ~x
	]

	prepareChain(cas) = x -> SymbolicUtils.simplify(x;
		threaded = true,
		rewriter = (cas |>
					SymbolicUtils.RestartedChain |>
					SymbolicUtils.Prewalk),
	)

	simplifyRewriter = prepareChain(vcat(
		de_prettify...,
		simplificationRules...,
		additionRules...,
		ubRules...,
		lbRules...,
		luRules...,
		isPosRules...,
		uuRules...,
	))
	
	prettifyRewriter = prepareChain(vcat(
		prettify...,
	))

	simplifyRewriter, prettifyRewriter
end

simplifyRewriter, prettifyRewriter = createRewriters()
