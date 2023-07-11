
"whether is a finite upper and lower limit, i.e., |N is not finite"
isLimited(e::SubSe)::Bool = hasUpperLimit(e) && hasLowerLimit(e)

#=
"surreal least upper bound (larger or equal)"
function getLUB(e::SubSe)::Surreal
	@match typeofSubSe(e) begin
		:n_s => return omega
		:omega_s => return omega
		#:neg_s => -getGLB(left(e))
		_ => @assert false typeofSubSe(e)
	end
end

"surreal greatest lower bound (smaller or equal)"
function getGLB(e::SubSe)::Surreal
	@match typeofSubSe(e) begin
		:n_s => return Surreal(1) # 1 is considered the smallest n
		:omega_s => return omega
		#:neg_s => -getLUB(left(e))
		_ => @assert false typeofSubSe(e)
	end
end
=#

function assertSimpleFactors(e)
	for (factor, v) in iterateAdd(e)
		@assert isDyadic(factor)
		@assert isPositive(factor) == Yes
		@assert isZero(factor) == No
	end
	return last.(iterateAdd(e))
end

"true, iff there is a finite number larger or equal to every element in e"
function hasUpperLimit(e::SubSe)::MaybeBool
	
	@match typeofSubSe(e) begin
		:add => begin
			local vs = assertSimpleFactors(e)

			# all limited -> definitely a limit
			+all2(hasUpperLimit, vs) && return Yes

			# all are positively infinite or have limited elements -> no limit
			+all2(x -> !hasUpperLimit(x) | hasFiniteElements(x), vs) && return No

			@warn "hasUpperLimit" e
			return Maybe
		end
		:mul => begin
			local fs = iterateMul(e)
			isNeg(e) && return hasLowerLimit(fs[2][2])

			if length(fs) == 2 && all(x -> first(x) == 1, fs)
				# no exponents, just two factors
				local x, y = fs[1][2], fs[2][2]
				if isDyadic(x) && +!isZero(x)
					return @trif isPositive(x) hasUpperLimit(y) Maybe hasLowerLimit(y)
				end
			end

			@warn "hasUpperLimit" fs
			return Maybe
		end

		:n_s => return No
		:omega_s => return No
		:uu_s => return @and hasUpperLimit(left(e)) hasUpperLimit(right(e))
		:ub_s => return hasUpperLimit(left(e))
		_ => @assert false typeofSubSe(e)
	end
end

hasPosInfinite(x) = @and hasLowerLimit(x) hasInfiniteElements(x)
hasNegInfinite(x) = @and hasUpperLimit(x) hasInfiniteElements(x)
hasntPosInfinite(x) = @or hasUpperLimit(x) !hasInfiniteElements(x)
hasntNegInfinite(x) = @or hasLowerLimit(x) !hasInfiniteElements(x)
allPosInfinite(x) = @and allPositive(x) !hasFiniteElements(x)


function allNegative(e::SubSe)::MaybeBool
	@match typeofSubSe(e) begin
		:add => begin
			local vs = assertSimpleFactors(e)
			+all2(allNegative, vs) && return Yes

			@warn e
			return Maybe
		end
		:mul => begin
			local fs = iterateMul(e)
			isNeg(e) && return allPositive(fs[2][2])

			@warn fs
			return Maybe
		end
		:n_s => return No
		:omega_s => return No
		:lb_s => return allNegative(left(e))
		:ub_s => return allNegative(left(e))
		_ => @assert false typeofSubSe(e)
	end
end

hasNegative(s::SubSe)::MaybeBool = @and !allPositive(s) !allZero(s)
hasPositive(s::SubSe)::MaybeBool = @and !allNegative(s) !allZero(s)

function allZero(e::SubSe)::MaybeBool
	@match typeofSubSe(e) begin
		:mul => begin
			local fs = iterateMul(e)
			for (exponent, value) in fs
				@trif (@and !isZero(exponent) isZero(value)) (return Yes) (return Maybe) continue
			end
			return No
		end
		:n_s => return No
		:omega_s => return No
		:lb_s => return allZero(left(e))
		:ub_s => return allZero(left(e))
		_ => @assert false typeofSubSe(e)
	end
end

function allPositive(e::SubSe)::MaybeBool
	@match typeofSubSe(e) begin
		:add => begin
			local vs = assertSimpleFactors(e)

			+all2(allPositive, vs) && return Yes

			+any2(allPosInfinite, vs) && +all2(hasntNegInfinite, vs) && return Yes

			+all2(hasNegative, vs) && return No

			@warn vs
			return Maybe
		end
		:mul => begin
			local fs = iterateMul(e)
			isNeg(e) && return allNegative(fs[2][2])

			if length(fs) == 2 && fs[1][1] == S1 && isDyadic(fs[1][2]) && fs[2][1] == S1
				+isPositive(fs[1][2]) && return allPositive(fs[2][2])
				+isNegative(fs[1][2]) && return allNegative(fs[2][2])
			end

			@warn fs
			return Maybe
		end
		:n_s => return Yes
		:omega_s => return Yes
		:lb_s => return allPositive(left(e))
		:ub_s => return allPositive(left(e))
		_ => @assert false typeofSubSe(e)
	end
end


"true, iff there is a finite number smaller than every element in e"
function hasLowerLimit(e::SubSe)::MaybeBool
	@match typeofSubSe(e) begin
		:add => begin
			local vs = assertSimpleFactors(e)

			# all limited -> definitely a limit
			+all2(hasLowerLimit, vs) && return Yes

			# all are negatively infinite or have limited elements -> no limit
			+all2(x -> !hasLowerLimit(x) | hasFiniteElements(x), vs) && return No

			# there is a pos infinite and others aren't negative infinite
			+any2(hasPosInfinite, vs) && +all2(hasntNegInfinite, vs) && return Yes

			@warn vs, iterateAdd(e)
			return Maybe
		end
		:mul => begin
			local fs = iterateMul(e)
			isNeg(e) && return hasUpperLimit(fs[2][2])

			if length(fs) == 2 && all(x -> first(x) == 1, fs)
				# no exponents, just two factors
				local x, y = fs[1][2], fs[2][2]
				if isDyadic(x) && +!isZero(x)
					return @trif isPositive(x) hasLowerLimit(y) Maybe hasUpperLimit(y)
				end
			end

			@warn fs
			return Maybe
		end

		:n_s => return Yes
		:omega_s => return Yes
		:lb_s => return hasLowerLimit(left(e))

		_ => @assert false typeofSubSe(e)
	end
end

"true, iff the set contains finite elements"
function hasFiniteElements(e::SubSe)::MaybeBool
	@match typeofSubSe(e) begin
		#:neg_s => return hasFiniteElements(left(e))
		:n_s => return Yes
		:omega_s => return No
		:add => begin
			local vs = assertSimpleFactors(e)

			# all have finite elements -> definitely still have those
			all2(hasFiniteElements, vs) && return Yes

			# exactly one has no finite elements
			sum(map(x -> @trif hasFiniteElements(x) 0 10 1), vs) == 1 && return No

			@warn iterateAdd(e)
			return Maybe
		end

		:mul => begin
			local fs = iterateMul(e)
			isNeg(e) && return hasFiniteElements(fs[2][2])

			if length(fs) == 2 && all(x -> first(x) == 1, fs)
				# no exponents, just two factors
				local x, y = fs[1][2], fs[2][2]
				+isFinite(x) && return hasFiniteElements(y)
			end

			@warn e
			return Maybe
		end

		# can be ignored; they are only hints
		:ub_s => return hasFiniteElements(left(e))
		:lb_s => return hasFiniteElements(left(e))

		_ => @assert false typeofSubSe(e)
	end
end


"true, iff the set contains infinite elements"
function hasInfiniteElements(e::SubSe)::MaybeBool
	@match typeofSubSe(e) begin
		:n_s => return No
		:omega_s => return Yes
		:add => begin
			local vs = assertSimpleFactors(e)

			# exactly one has infinite elements -> definitely still have those
			(sum(map(x -> (@trif hasInfiniteElements(x) 1 10 0), vs)) == 1) && return Yes

			# none has infinite elements -> still none
			+all2(x -> !hasInfiniteElements(x), vs) && return No

			@warn e
			return Maybe
		end

		:mul => begin
			local fs = iterateMul(e)
			isNeg(e) && return hasInfiniteElements(fs[2][2])

			if length(fs) == 2 && all(x -> first(x) == 1, fs)
				# no exponents, just two factors
				local x, y = fs[1][2], fs[2][2]
				isDyadic(x) && +!isZero(x) && return hasInfiniteElements(y)
			end

			@warn e
			return Maybe
		end

		# can be ignored; they are only hints
		:ub_s => return hasInfiniteElements(left(e))
		:lb_s => return hasInfiniteElements(left(e))

		_ => @assert false typeofSubSe(e)
	end
end
