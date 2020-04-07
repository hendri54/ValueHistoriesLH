## -----------  Test setup

# Make a univalued history for testing.
# Key spacing governed by `keySpacing`.
function make_test_history(n :: Integer, dimV; 
    offSet :: Float64 = 0.0, keySpacing :: Int = 1)

    h = History(Array{Float64});
    nEl = prod(dimV);
    idx = 1;
    for j = 1 : n
        v = reshape(1 : nEl, dimV...) .+ offSet .+ j;
        push!(h, idx, v);
        idx += keySpacing;
    end
    return h
end

function make_test_mvhistory(n :: Integer)
    h = MVHistory();
    nameV = Symbol.(collect('d' : ('d' + (n-1))));
    offSetV = 1.0 : n;
    for j = 1 : n
        sHist = make_test_history(4, [3,1]; offSet = offSetV[j], keySpacing = j);
        ValueHistoriesLH.add_series!(h, nameV[j], sHist);
    end
    return h
end


test_dir() = joinpath(@__DIR__, "test_files");

mkpath(test_dir());

# ---------------