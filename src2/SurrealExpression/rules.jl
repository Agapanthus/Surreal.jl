

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


function createRewriters()
    simplificationRules = [
        @rule X_s(~x) => X_s(simplify(~x))
    ]
    
    additionRules = [
        @rule add_s(X_s(~x::se(isZeroFast)), ~y) => ~y
        @rule add_s(~y, X_s(~x::se(isZeroFast))) => ~y
    
        @rule add_s(X_s(~x), X_s(~y)) => X_s(~x + ~y)
    
        #  @rule add(~x, S(∅, ∅)) => ~x
        #  @rule add(SSS(~x), ~y) => SSS(~x ⊕ ~y)
    
        # @rule (S(∅, ∅) ⊕ ~y) => ~y
        # @rule (~x ⊕ S(∅, ∅)) => ~x
        # @rule (S(~XL, ~XR) ⊕ S(~YL, ~YR)) =>  S(maxUnion(add(~XL, S(~YL, ~YR)), add(~YL, S(~XL, ~XR))), minUnion(add(~XR, S(~YL, ~YR)), add(~YR, S(~XL, ~XR))))
    ]
    
    luRules = [
        #@rule lu_s(add_s(n_s, X_s(~x::(isFinite))), ) =>
    
        # ignore finite additions to infinite stuff
        @rule lu_s(add_s(n_s, X_s(~x::se(isFinite))), ~y) => lu_s(n_s, ~y)
        @rule lu_s(add_s(X_s(~x::se(isFinite)), n_s), ~y) => lu_s(n_s, ~y)
        @rule lu_s(~y, add_s(n_s, X_s(~x::se(isFinite)))) => lu_s(n_s, ~y)
        @rule lu_s(~y, add_s(X_s(~x::se(isFinite)), n_s)) => lu_s(n_s, ~y)
    
        # ignore merging smaller stuff (TODO: how to use acrule here?)
        @rule lu_s(n_s, X_s(~x::se(isInfinite))) => X_s(~x)
        #@rule lu_s(neg_s(n_s), X_s(~x::se(isInfinite))) => X_s(~x)

        # same on both sides is irrelevant
        @rule lu_s(~x, ~x) => ~x
    
    ]

    uuRules = [
        #@rule lu_s(add_s(n_s, X_s(~x::(isFinite))), ) =>
    
        # ignore finite additions to infinite stuff
        @rule uu_s(add_s(n_s, X_s(~x::se(isFinite))), ~y) => uu_s(n_s, ~y)
        @rule uu_s(add_s(X_s(~x::se(isFinite)), n_s), ~y) => uu_s(n_s, ~y)
        @rule uu_s(~y, add_s(n_s, X_s(~x::se(isFinite)))) => uu_s(n_s, ~y)
        @rule uu_s(~y, add_s(X_s(~x::se(isFinite)), n_s)) => uu_s(n_s, ~y)
    
        # ignore merging smaller stuff (TODO: how to use acrule here?)
        #@rule uu_s(n_s, X_s(~x::se(isInfinite))) => X_s(~x)
        @rule uu_s(neg_s(n_s), X_s(~x::se(isInfinite))) => X_s(~x)

        # same on both sides is irrelevant
        @rule uu_s(~x, ~x) => ~x
    
    ]
    
    omegaRules = [
        @rule X_s(~x::se(isOmegaFast)) => omega_s
        @rule X_s(~x::se(isMinusOmegaFast)) => neg_s(omega_s)
    
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
        luRules...,
        uuRules...,
        omegaRules...,
    ))

    simplifyRewriter
end

#simplifyRewriter = createRewriters()