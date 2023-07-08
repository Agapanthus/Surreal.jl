
function commuInnerCheck(e)
	@assert e.head == :call
	@assert e.args |> length == 3
	local name, arg1, arg2 = e.args
	@assert typeof(name) === Symbol
	@assert arg1.head == :(::)
	@assert arg2.head == :(::)
	return name, arg1, arg2
end

"""
generates an additional

f(y::S, x::T) = f(x, y)

for your f(x::T, y::S), i.e., uses commutativity.
"""
macro commu(f)
	@assert f.head == :(=)
	# without where block
	local name, arg1, arg2 = commuInnerCheck(f.args[1])
	return quote
		@inline function $(esc(name))($arg2, $arg1)
			$name($(arg1.args[1]), $(arg2.args[1]))
		end
		$(esc(f))
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
