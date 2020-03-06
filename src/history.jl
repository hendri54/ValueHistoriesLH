#=
Stores a single object of type `V` for each iteration.
`iterations` keep track of the indices (e.g. times) of the iterations.
=#
mutable struct History{I,V} <: UnivalueHistory{I}
    lastiter::I
    iterations::Vector{I}
    values::Vector{V}

    function History(::Type{V}, ::Type{I} = Int) where {I,V}
        new{I,V}(typemin(I), Array{I}(undef, 0), Array{V}(undef, 0))
    end
end

Base.length(history::History) = length(history.iterations)
Base.enumerate(history::History) = zip(history.iterations, history.values)
Base.first(history::History) = history.iterations[1], history.values[1]
Base.last(history::History) = history.iterations[end], history.values[end]
Base.get(history::History) = history.iterations, history.values


"""
	$(SIGNATURES)

Make a history into a `Dict{String,ValueType}`.
The purpose is mainly to represent the history in a format that can be encoded as JSON.
"""
function history_to_dict(h :: History{I, V}) where {I, V}
    d = Dict{String, V}();
    n = length(h);
    idxV, valueV = get(h);
    for j = 1 : n
        d[string(idxV[j])] = valueV[j]
    end
    return d
end


"""
	$(SIGNATURES)

Make a `UnivalueHistory` from a vector of values.

test this +++++
"""
function make_history(valueV :: Vector)
    h = History(eltype(valueV));
    for (j, v) in valueV
        push!(h, j, v);
    end
    return h
end


function Base.push!(
        history::History{I,V},
        iteration::I,
        value::V) where {I,V}
    lastiter = history.lastiter
    iteration > lastiter || throw(ArgumentError("Iterations must increase over time"))
    history.lastiter = iteration
    push!(history.iterations, iteration)
    push!(history.values, value)
    value
end

# Add a history entry. Simply increment iteration counter by 1.
function Base.push!(
        history::History{I,V},
        value::V) where {I,V}
    lastiter = history.lastiter == typemin(I) ? zero(I) : history.lastiter
    iteration = lastiter + one(history.lastiter)
    history.lastiter = iteration
    push!(history.iterations, iteration)
    push!(history.values, value)
    value
end

Base.print(io::IO, history::History{I,V}) where {I,V} = print(io, "$(length(history)) elements {$I,$V}")

function Base.show(io::IO, history::History{I,V}) where {I,V}
    println(io, "History")
    println(io, "  * types: $I, $V")
    print(io,   "  * length: $(length(history))")
end

"""
    increment!(trace, iter, val)

Increments the value for a given iteration if it exists, otherwise adds the iteration with an ordinary push.
"""
function increment!(trace::History{I,V}, iter::Number, val)  where {I,V}
    if !isempty(trace.iterations)
        if trace.lastiter == iter # Check most common case to make it faster
            i = length(trace.iterations)
        else
            i = findfirst(isequal(iter), trace.iterations)
        end
        if i != nothing
            return (trace.values[i] += val)
        end
    end
    push!(trace, iter, val)
end
