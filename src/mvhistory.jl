#=
Each key is one "series" to be saved; say the function value in an optimization.
=#
struct MVHistory{H<:UnivalueHistory} <: MultivalueHistory
    storage::Dict{Symbol, H}
end

function MVHistory(::Type{H} = History) where {H<:UnivalueHistory}
    MVHistory{H}(Dict{Symbol, H}())
end

# ====================================================================
# Functions

Base.isempty(h :: MVHistory)  =  isempty(h.storage);


## ---------  Retrieve one series

Base.length(history::MVHistory, key::Symbol) = length(history.storage[key])
Base.enumerate(history::MVHistory, key::Symbol) = enumerate(history.storage[key])
Base.first(history::MVHistory, key::Symbol) = first(history.storage[key])
Base.last(history::MVHistory, key::Symbol) = last(history.storage[key])

"""
	$(SIGNATURES)

Returns the names of the "series" that are saved in the history as a vector.
"""
Base.keys(history::MVHistory) = keys(history.storage);

series_names(history :: MVHistory) = keys(history.storage);

# Base.haskey(h :: MVHistory) = Base.haskey(h.storage);

"""
	$(SIGNATURES)

Returns the values for a specific "series" in the history as a vector.
"""
Base.values(history::MVHistory, key::Symbol) = values(get_series(history, key));
# get(history, key)[2]

# Retrieve a univalue history
get_series(h :: MVHistory, key :: Symbol) = h.storage[key];


# Returns a univalue history for a given key
# So we can write h[:key]
Base.getindex(history::MVHistory, key::Symbol) =  history.storage[key]

# Does a given series exist?
# Base.haskey(history::MVHistory, key::Symbol) = haskey(history.storage, key);

# The same with a better name
has_series(h :: MVHistory, sName :: Symbol) = haskey(h.storage, sName);


"""
	$(SIGNATURES)

Retrieve the indices and values for a key as vectors.
"""
function Base.get(history::MVHistory, key::Symbol)
    l = length(history, key)
    k, v = first(history.storage[key])
    karray = Array{typeof(k)}(undef, l)
    varray = Array{typeof(v)}(undef, l)
    i = 1
    for (k, v) in enumerate(history, key)
        karray[i] = k
        varray[i] = v
        i += 1
    end
    karray, varray
end


"""
	$(SIGNATURES)

Retrieve the value for a key for a given index.
Return `nothing` if not found, unless `notFoundError == true`.
"""
function retrieve(h :: MVHistory, key :: Symbol, idx;
    notFoundError :: Bool = false)

    idxV, valueV = get(h, key);
    matchIdx = findfirst(x -> isequal(x, idx),  idxV);
    if isnothing(matchIdx)
        if notFoundError
            error("Index $idx not found in key $key");
        else
            return nothing
        end
    else
        return valueV[matchIdx]
    end
end



## ------------  Adding to a history

"""
	$(SIGNATURES)

Add an entire univariate history to a `MultivalueHistory`.
"""
function add_series!(h :: MVHistory, key :: Symbol, sHist :: History)
    @assert !has_series(h, key)  "Series $key already exists"
    h.storage[key] = sHist;
    return nothing
end


function Base.push!(
        history::MVHistory{H},
        key::Symbol,
        iteration::I,
        value::V) where {I,H<:UnivalueHistory,V}

    if !has_series(history, key)
        _hist = H(V, I)
        push!(_hist, iteration, value)
        history.storage[key] = _hist
    else
        @assert isa(value,  eltype(history.storage[key]))  """
            Unexpected type: $(eltype(value)) 
            in history $key of type $(eltype(history.storage[key]))
            """
        push!(history.storage[key], iteration, value)
    end
    value
end

function Base.push!(
        history::MVHistory{H},
        key::Symbol,
        value::V) where {H<:UnivalueHistory,V}

    if !has_series(history, key)
        _hist = H(V, Int)
        push!(_hist, value)
        history.storage[key] = _hist
    else
        push!(history.storage[key], value)
    end
    value
end


## --------------  Other

"""
	$(SIGNATURES)

Return one history (for one series) as a `Dict{String, V}`.
"""
function history_to_dict(h :: MVHistory, key :: Symbol)
    return history_to_dict(get_series(h, key))
end



function Base.show(io::IO, history::MVHistory{H}) where {H}
    print(io, "MVHistory{$H}")
    for (key, val) in history.storage
        print(io, "\n", "  :$(key) => $(val)")
    end
end

using Base.Meta

"""
Easily add to a MVHistory object `tr`.

Example:

```julia
using ValueHistories, OnlineStats
v = Variance(BoundedEqualWeight(30))
tr = MVHistory()
for i=1:100
    r = rand()
    fit!(v,r)
    μ,σ = mean(v),std(v)

    # add entries for :r, :μ, and :σ using their current values
    @trace tr i r μ σ
end
```
"""
macro trace(tr, i, vars...)
    block = Expr(:block)
    for v in vars
        push!(block.args, :(push!($(esc(tr)), $(quot(Symbol(v))), $(esc(i)), $(esc(v)))))
    end
    block
end

"""
    increment!(trace, key, iter, val)

Increments the value for a given key and iteration if it exists, otherwise adds the key/iteration pair with an ordinary push.
"""
function increment!(trace::MVHistory{<:History}, key::Symbol, iter::Number, val)
    if has_series(trace, key)
        i = findfirst(isequal(iter), trace.storage[key].iterations)
        if !isnothing(i)
            return trace[key].values[i] += val
        end
    end
    push!(trace, key, iter, val)
end

# ------------