
"whether is a finite upper and lower limit, i.e., |N is not finite"
isLimited(e::SubSe)::Bool = hasUpperLimit(e) && hasLowerLimit(e)

"surreal least upper bound (larger or equal)"
function getLUB(e::SubSe)::Surreal
	@match typeofSubSe(e) begin
		:n_s => return omega
		:omega_s => return omega
		:neg_s => -getGLB(left(e))
		:X_s => return left(e)
		_ => @assert false typeofSubSe(e)
	end
end

"surreal greatest lower bound (smaller or equal)"
function getGLB(e::SubSe)::Surreal
	@match typeofSubSe(e) begin
		:n_s => return Surreal(1) # 1 is considered the smallest n
		:omega_s => return omega
		:neg_s => -getLUB(left(e))
		:X_s => return left(e)
		_ => @assert false typeofSubSe(e)
	end
end

"true, iff there is a finite number larger or equal to every element in e"
function hasUpperLimit(e::SubSe)
	@match typeofSubSe(e) begin
		:add_s => begin
			local fu1 = hasUpperLimit(left(e))
			local fu2 = hasUpperLimit(right(e))
			# exactly one unlimited: definitely no limit
			xor(fu1, fu2) && return false
			# both limited: definitely a limit
			fu1 && fu2 && return true

			# both unlimited...

			local fe1 = hasFiniteElements(left(e))
			local fe2 = hasFiniteElements(right(e))

			# one unlimited and the other one has finite elements -> still unlimited
			((!fu1 && fe2) || (!fu2 && fe1)) && return false

			TODO
		end
		:neg_s => return hasLowerLimit(left(e))
		:X_s => return isNegative(left(e)) || isFinite(left(e))
		:n_s => return false
		:omega_s => return false
		:lu_s => return hasUpperLimit(left(e)) && hasUpperLimit(right(e))
		_ => @assert false typeofSubSe(e)
	end
end

"true, iff there is a finite number smaller than every element in e"
function hasLowerLimit(e::SubSe)
	@match typeofSubSe(e) begin
		:add_s => begin
			local fl1 = hasLowerLimit(left(e))
			local fl2 = hasLowerLimit(right(e))
			# exactly one unlimited: definitely no limit
			xor(fl1, fl2) && return false
			# both limited: definitely a limit
			fl1 && fl2 && return true

			# both unlimited...

			local fe1 = hasFiniteElements(left(e))
			local fe2 = hasFiniteElements(right(e))

			# one unlimited and the other one has finite elements -> still unlimited
			((!fl1 && fe2) || (!fl2 && fe1)) && return false

			TODO
		end
		:neg_s => return hasUpperLimit(left(e))
		:X_s => return isPositive(left(e)) || isFinite(left(e))
		:n_s => return true
		:omega_s => return true
		_ => @assert false typeofSubSe(e)
	end
end

"true, iff the set contains finite elements"
function hasFiniteElements(e::SubSe)
	@match typeofSubSe(e) begin
		:neg_s => return hasFiniteElements(left(e))
		:X_s => return isFinite(left(e))
		:n_s => return true
		:omega_s => return false
		_ => @assert false typeofSubSe(e)
	end
end
