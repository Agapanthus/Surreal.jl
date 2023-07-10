

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


function createRewriters()
	simplificationRules = [
		@rule ~x::se(isSurreal) => se(simplify)(~x)
	]

	additionRules = [

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
		@rule ub_s(omega_s) => omega_s

		# transport into union        
		@rule ub_s(uu_s(~x, ~y)) => uu_s(ub_s(~x), ub_s(~y))

		# ignore finite additions to infinite stuff  # TODO: acrule?
		@acrule ub_s(~x::sc(isFinite) + n_s) => n_s
	]

	# lower bound focused (right side)
	lbRules = [
		# remove around single values        
		@rule lb_s(~x::se(isSurreal)) => (~x)
		@rule lb_s(n_s) => n_s
		@rule lb_s(omega_s) => omega_s

		# transport into union     
		@rule lb_s(lu_s(~x, ~y)) => lu_s(lb_s(~x), lb_s(~y))

		# ignore finite additions to infinite stuff  # TODO: acrule?
		@acrule lb_s(~x::sc(isFinite) - n_s) => -n_s]

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
		@rule lu_s(-n_s, ~x::sc(isNegInfinite)) => ~x
		@rule lu_s(~x::sc(isNegInfinite), -n_s) => ~x

		# merge comparable values # TODO: could be problem if causing recursion
		@rule lu_s(~x::se(isSurreal), ~y::se(isSurreal)) => min(~x, ~y)

		# same on both sides is irrelevant
		@rule lu_s(~x, ~x) => ~x
	]

	# less than
	leRules = [
		# try to postpone the problem
		@rule le_s(~x::se(isSurreal), ~y::se(isSurreal)) => ~x < ~y

		@rule le_s(~x::se(hasUpperLimit), ~y::sc(isPosInfinite)) => true
		@rule le_s(~x::se(x -> !hasUpperLimit(x)), ~y::se(hasFiniteElements)) => false

		@rule le_s(~x::sc(isNegInfinite), ~y::se(hasLowerLimit)) => true
		@rule le_s(~x::se(hasFiniteElements), ~y::se(x -> !hasLowerLimit(x))) => false

		@rule le_s(n_s, ~y::sc(isPosInfinite)) => true
	]

	# less than or equal
	leqRules = [
		# try to postpone the problem
		@rule leq_s(~x::se(isSurreal), ~y::se(isSurreal)) => ~x <= ~y

		@rule leq_s(~x::se(hasUpperLimit), ~y::sc(isPosInfinite)) => true
	]


	omegaRules = [
		@rule ~x::sc(isOmegaFast) => omega_s
		@rule ~x::sc(isMinusOmegaFast) => -omega_s
	]

	prepareChain(cas) = x -> SymbolicUtils.simplify(x;
		threaded = true,
		rewriter = (cas |>
					SymbolicUtils.RestartedChain |>
					SymbolicUtils.Prewalk),
	)

	simplifyRewriter = prepareChain(vcat(
		simplificationRules...,
		additionRules...,
		ubRules...,
		lbRules...,
		luRules...,
		leRules...,
		leqRules...,
		uuRules...,
		# interferes with other rules since numbers aren't of type Surreal anymore
		#omegaRules...
	))

	simplifyRewriter
end

simplifyRewriter = createRewriters()
