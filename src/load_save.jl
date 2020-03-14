"""
	$(SIGNATURES)

Save an optimization history. 
Since serialization is flaky, it is safest to save each "series" in a separate file. If one file cannot be read, the rest of the history may still be readable.
Since binary saving does not work reliably, use JSON.
"""
function save_mvhistory(histS :: MVHistory, fPath :: AbstractString)
    # Save the series that are available
    sNameV = save_meta(histS, fPath);

    # Save each series
    for sName in sNameV
        # d = ValueHistoriesLH.history_to_dict(histS, sName);
        sPath = series_path(fPath, sName);
        save_history(get_series(histS, sName), sPath);
    end
    return nothing
end


"""
	$(SIGNATURES)

Load MVHistory.
"""
function load_mvhistory(fPath :: AbstractString; notFoundError :: Bool = true)
    sNameV = load_meta(fPath; notFoundError = notFoundError);
    if isnothing(sNameV)
        return nothing
    end

    histS = MVHistory();
    for sName in sNameV
        h = load_history(fPath, sName; notFoundError = notFoundError);
        if isnothing(h)
            if notFoundError
                error("Series $sName not found");
            end
        else
            add_series!(histS, sName, h);
        end
    end
    return histS :: MVHistory
end


function save_meta(h :: MVHistory, fPath :: AbstractString)
    sNameV = collect(keys(h));
    d = vector_to_dict(sNameV);
    metaPath = meta_path(fPath);
    save_dict(d, metaPath);
    return sNameV
end


function load_meta(fPath :: AbstractString; notFoundError :: Bool = true)
    metaPath = meta_path(fPath);
    if !isfile(metaPath)
        if notFoundError
            showPath = path_to_show(fPath);
            error("Not found: $showPath");
        else
            return nothing
        end
    end
    d = load_dict(metaPath);
    v = dict_to_vector(d);
    v = Symbol.(v);
    return v :: Vector{Symbol}
end


meta_path(fPath :: AbstractString) = series_path(fPath, :meta);
file_ext() = ".json3";


function series_path(fPath :: AbstractString, sName :: Symbol)
    fDir, fName = splitdir(fPath);
    baseName, fExt = splitext(fName);
    return joinpath(fDir,  baseName * "_$sName" * file_ext())
end


function path_to_show(fPath :: AbstractString)
    fDir, fName = splitdir(fPath);
    v = splitpath(fDir);
    n = length(v);
    if n < 3
        return fPath
    else
        idxV = (n-1) : n;
        return joinpath(v[idxV]..., fName)
    end
end


function vector_to_dict(vVec :: Vector)
	d = Dict{String, eltype(vVec)}();
	for j = 1 : length(vVec)
		d[string(j)] = vVec[j];
	end
	return d
end


## ------------  Save uni values history


"""
	$(SIGNATURES)

Save a uni-value history.
"""
function save_history(h :: History, fPath :: AbstractString;  showMsg :: Bool = true)
    d = ValueHistoriesLH.history_to_dict(h);
    save_dict(d, fPath);
    if showMsg
        showPath = path_to_show(fPath);
        println("Saved history $showPath");
    end
    return nothing
end


# Save a `Dict` to a JSON file
function save_dict(d, fPath :: AbstractString)
    open(fPath, "w") do io
        JSON3.write(io, d);
    end
    return nothing
end


function load_dict(fPath :: AbstractString)
    @assert isfile(fPath)
    d = try
        open(fPath, "r") do io
            # This loads the `Dict` that was saved
            JSON3.read(io);
        end
    catch
        error("Could not open $fPath")
    end
    return d
end


"""
	$(SIGNATURES)

Load a uni-value history.
Due to a JSON limitation, matrices are flattened into Vectors.
"""
function load_history(fPath)
    d = load_dict(fPath);
    valueV = dict_to_vector(d);
    h = make_history(valueV);
    return h
end

function load_history(fPath :: AbstractString, sName :: Symbol; notFoundError :: Bool = true)
    sp = series_path(fPath, sName);
    if !isfile(sp)
        if notFoundError
            showPath = path_to_show(sp);
            error("Not found: $showPath");
        else
            return nothing
        end
    else
        return load_history(sp);
    end
end


# Convert a loaded `Dict` into a `Vector`.
# Assumes keys are sequential integers.
# JSON arrays are made into ordinary arrays.
function dict_to_vector(d :: T1) where T1 <: AbstractDict
    n = length(keys(d));
    # Because each value can be stored as a different type, start with `Vector{Any}`.
    v = Vector{Any}(undef, n);
    for j = 1 : n
        v[j] = d[string(j)];
    end
    
    # Promote to common type
    vOut = collect(promote(v...));
    # Make JSON3 arrays into ordinary arrays
    vOut = convert_json_array(vOut);
	return vOut
end


# Make JSON array into ordinary array
function convert_json_array(x :: JSON3.Array; vType = Float64)
    y = similar(x, vType);
    for j in 1 : length(x)
        y[j] = x[j];
    end
    return y
end

# Make Array{JSON3.Array} into ordinary Arrays
function convert_json_array(x :: Array{T1}; vType = Float64) where T1 <: JSON3.Array
    y1 = convert_json_array(x[1]);
    y = similar(x, typeof(y1));
    for j = 1 : length(x)
        y[j] = convert_json_array(x[j]; vType = vType);
    end
    return y
end

convert_json_array(x) = x;


# -------------