
"whether is a finite upper and lower limit, i.e., |N is not finite"
isLimited(e::SubSe)::Bool = hasUpperLimit(e) && hasLowerLimit(e)

"surreal least upper bound (larger or equal)"
function getLUB(e::SubSe)::Surreal
	@match typeofSubSe(e) begin
		:n_s => return omega
		:omega_s => return omega
		#:neg_s => -getGLB(left(e))
		:X_s => return left(e)
		_ => @assert false typeofSubSe(e)
	end
end

"surreal greatest lower bound (smaller or equal)"
function getGLB(e::SubSe)::Surreal
	@match typeofSubSe(e) begin
		:n_s => return Surreal(1) # 1 is considered the smallest n
		:omega_s => return omega
		#:neg_s => -getLUB(left(e))
		:X_s => return left(e)
		_ => @assert false typeofSubSe(e)
	end
end

"negation, i.e., -1 * x"
isNeg(fs) = length(fs) == 2 && fs[1] == (S1, SM1) && fs[2][1] == S1


"true, iff there is a finite number larger or equal to every element in e"
function hasUpperLimit(e::SubSe)::Bool
	@match typeofSubSe(e) begin
		:add => begin
			local ul = map(iterateAdd(e)) do (factor, v)
				@assert isFinite(factor)
				@assert isPositive(factor)
				@assert !isZeroFast(factor)
				return hasUpperLimit(v), hasFiniteElements(v)
			end
			# all limited -> definitely a limit
			all(first, ul) && return true

			# all are positively infinite or have limited elements -> no limit
			all(x -> !first(x) || last(x), ul) && return false

			TODO
		end
		:mul => begin
			local fs = iterateMul(e)
			isNeg(fs) && return hasLowerLimit(fs[2][2])

			TODO
		end

		:X_s => return isNegative(left(e)) || isFinite(left(e))
		:n_s => return false
		:omega_s => return false
		:uu_s => return hasUpperLimit(left(e)) && hasUpperLimit(right(e))
		:ub_s => return hasUpperLimit(left(e))
		_ => @assert false typeofSubSe(e)
	end
end

"true, iff there is a finite number smaller than every element in e"
function hasLowerLimit(e::SubSe)::Bool
	@match typeofSubSe(e) begin
		:add => begin
			local ul = map(iterateAdd(e)) do (factor, v)
				@assert isFinite(factor)
				@assert isPositive(factor)
				@assert !isZeroFast(factor)
				return hasLowerLimit(v), hasFiniteElements(v)
			end
			# all limited -> definitely a limit
			all(first, ul) && return true

			# all are negatively infinite or have limited elements -> no limit
			all(x -> !first(x) || last(x), ul) && return false

			TODO
		end
		:mul => begin
			local fs = iterateMul(e)
			isNeg(fs) && return hasUpperLimit(fs[2][2])

			TODO
		end

		:n_s => return true
		:omega_s => return true
		:lb_s => return hasLowerLimit(left(e))

		_ => @assert false typeofSubSe(e)
	end
end

"true, iff the set contains finite elements"
function hasFiniteElements(e::SubSe)
	@match typeofSubSe(e) begin
		#:neg_s => return hasFiniteElements(left(e))
		:X_s => return isFinite(left(e))
		:n_s => return true
		:omega_s => return false
		:add => begin
			local ul = map(iterateAdd(e)) do (factor, v)
				@assert isFinite(factor)
				@assert isPositive(factor)
				@assert !isZeroFast(factor)
				return hasFiniteElements(v)
			end
			# all have finite elements -> definitely still have those
			all(ul) && return true

			TODO
		end

		:mul => begin
			local fs = iterateMul(e)
			isNeg(fs) && return hasFiniteElements(fs[2][2])

			TODO
		end

		# can be ignored; they are only hints
		:ub_s => return hasFiniteElements(left(e))
		:lb_s => return hasFiniteElements(left(e))

		_ => @assert false typeofSubSe(e)
	end
end


"true, iff the set contains infinite elements"
function hasInfiniteElements(e::SubSe)
	@match typeofSubSe(e) begin
		#:neg_s => return hasFiniteElements(left(e))
		:X_s => return isInfinite(left(e))
		:n_s => return false
		:omega_s => return true
		:add => begin
			local ul = map(iterateAdd(e)) do (factor, v)
				@assert isFinite(factor)
				@assert isPositive(factor)
				@assert !isZeroFast(factor)
				return hasInfiniteElements(v)
			end
			# exactly one has infinite elements -> definitely still have those
			(sum(ul) == 1) && return true

			# none has infinite elements -> still none
			all(not, ul) && return false


			TODO
		end

		:mul => begin
			local fs = iterateMul(e)
			isNeg(fs) && return hasInfiniteElements(fs[2][2])

			TODO
		end

		# can be ignored; they are only hints
		:ub_s => return hasInfiniteElements(left(e))
		:lb_s => return hasInfiniteElements(left(e))

		_ => @assert false typeofSubSe(e)
	end
end
