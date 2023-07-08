

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
function sc(f = identity)
    return x -> begin
       if f isa Surreal
        return se(f)(x)
       else 
        return false
       end
    end
end


function createRewriters()
    simplificationRules = [
        @rule ~x::sc() => simplify(~x)
    ]
    
    additionRules = [
        @rule (~x::sc(isZeroFast) + ~y) => ~y
        @rule (~y + ~x::sc(isZeroFast)) => ~y
    
        @rule ~x::sc() + ~y::sc() => ~x + ~y
    
        #  @rule add(~x, S(∅, ∅)) => ~x
        #  @rule add(SSS(~x), ~y) => SSS(~x ⊕ ~y)
    
        # @rule (S(∅, ∅) ⊕ ~y) => ~y
        # @rule (~x ⊕ S(∅, ∅)) => ~x
        # @rule (S(~XL, ~XR) ⊕ S(~YL, ~YR)) =>  S(maxUnion(add(~XL, S(~YL, ~YR)), add(~YL, S(~XL, ~XR))), minUnion(add(~XR, S(~YL, ~YR)), add(~YR, S(~XL, ~XR))))
    ]
    
    luRules = [
   
        # ignore finite additions to infinite stuff
        @rule lu_s(n_s + ~x::sc(isFinite), ~y) => lu_s(n_s, ~y)
        @rule lu_s(~x::sc(isFinite)+ n_s, ~y) => lu_s(n_s, ~y)
        @rule lu_s(~y, n_s + ~x::sc(isFinite)) => lu_s(n_s, ~y)
        @rule lu_s(~y, ~x::sc(isFinite) + n_s) => lu_s(n_s, ~y)
    
        # ignore merging smaller stuff (TODO: how to use acrule here?)
        @rule lu_s(n_s, ~x::sc(isInfinite)) => ~x
        #@rule lu_s(-n_s, ~x::sc(isInfinite)) => ~x

        # same on both sides is irrelevant
        @rule lu_s(~x, ~x) => ~x
    
    ]

    uuRules = [
        # ignore merging smaller stuff (TODO: how to use acrule here?)
        @rule lu_s(-n_s, ~x::sc(isInfinite)) => ~x

        # same on both sides is irrelevant
        @rule uu_s(~x, ~x) => ~x
    
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
        luRules...,
        uuRules...,
        omegaRules...,
    ))

    simplifyRewriter
end

#simplifyRewriter = createRewriters()