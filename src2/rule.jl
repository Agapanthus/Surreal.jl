
function commuInnerCheck(e)
	@assert e.head == :call
	@assert e.args |> length == 3
	local name, arg1, arg2 = e.args
	@assert typeof(name) === Symbol
	@assert arg1.head == :(::)
	@assert arg2.head == :(::)
	return name, arg1, arg2
end

macro commu(f)
	@assert f.head == :(=)

	if f.args[1].head == :where
		# with where block
		local wBody, wHead = f.args[1].args

		# skip function return type annotation
		if wBody.head == :(::)
			wBody = wBody.args[1]
		end

		local name, arg1, arg2 = commuInnerCheck(wBody)
		return quote
			@inline function $(esc(name))($(esc(arg2)), $(esc(arg1))) where $(esc(wHead))
				$name($(esc(arg1.args[1])), $(esc(arg2.args[1])))
			end
			$(esc(f))
		end
	else
		# without where block
		local name, arg1, arg2 = commuInnerCheck(f.args[1])
		return quote
			@inline function $(esc(name))($arg2, $arg1)
				$name($(arg1.args[1]), $(arg2.args[1]))
			end
			$(esc(f))
		end
	end
end

"""
@injectType modify T S both (f(x, y) = x + y)

becomes

f(x::T, y::S) = modify(x) + y
f(x::S, y::T) = x + modify(y)
if both
	f(x::T, y::T) = modify(x) + modify(y)
end

notice, that f(::S, ::S) is not defined!
"""
macro passDownType(modify, T, S, both, f)
	@assert f.head == :(=)
	local defi, body = f.args
	local name, n1, n2 = defi.args

	return quote
		function $(esc(name))(v1::$T, v2::$S)
			local $(esc(n1)) = $(esc(modify))(v1)
			local $(esc(n2)) = v2
			$(esc(body))
		end
		function $(esc(name))(v1::$S, v2::$T)
			local $(esc(n1)) = v1
			local $(esc(n2)) = $(esc(modify))(v2)
			$(esc(body))
		end
		if $(both)
			function $(esc(name))(v1::$T, v2::$T)
				local $(esc(n1)) = $(esc(modify))(v1)
				local $(esc(n2)) = $(esc(modify))(v2)
				$(esc(body))
			end
		end
	end
end
