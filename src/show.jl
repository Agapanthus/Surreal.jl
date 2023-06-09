
function showStruct(s::Side)::String
	isempty(s) && return "∅"
	s == SSetId && return "n"
	s == SSetInv && return "1 / " * showStruct(left(s))
	s == SSetAdd && return showStruct(left(s)) * " + " * showStruct(right(s))
	s == SSetMul && return showStruct(left(s)) * " * " * showStruct(right(s))
	s == SSetNeg && return "- " * showStruct(left(s))
	s == SSetLit && return showStruct(value(s))
	@assert false "not found $(s)"
end

function addPad(s::String)::String
	replace(s, "\n" => "\n   ")
end

function showStruct(s::Surreal)::String
	isFiniteStructure(s) && return string(toR(s))
	local sL = addPad(showStruct(s.L))
	local sR = addPad(showStruct(s.R))
	return "Surreal\n   $sL\n   $sR"
end

Base.show(io::IO, s::Side) = println(io, showStruct(s))

function Base.show(io::IO, s::Surreal)
	if isFiniteStructure(s)
		show(io, toR(s))
	else
		println(io, showStruct(s))
	end
end
