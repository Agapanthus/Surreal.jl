

function Base.maximum(s::Side)::Union{Surreal, Nothing}
    isempty(s) && return nothing
	s == SSetLit && return value(s)
	s == SSetId && return ω

	todo
end


function Base.minimum(s::Side)::Union{Surreal, Nothing}
    isempty(s) && return nothing
	s == SSetLit && return value(s)
	s == SSetId && return S1
    @show s
	todo
end
