# Load / save test

using ValueHistoriesLH, Test


function load_uni_test()
    @testset "Univalue history" begin
        h = make_test_history(3, [2,3]);
        fPath = joinpath(test_dir(),  "save_history_test");

        sName = :test1;
        sp = ValueHistoriesLH.series_path(fPath, sName);
        @test endswith(sp, "_test1.json3")

        if isfile(sp)
            rm(sp);
        end
        save_history(h, sp; showMsg = true);
        @test isfile(sp)

        # Remember that loaded history makes matrices into vectors
        h2 = load_history(sp);
        @test length(h) == length(h2)
        for j = 1 : length(h)
            v1 = values(h)[j];
            v2 = values(h2)[j];
            @test isapprox(v1,  reshape(v2, size(v1)))
        end
    end
end


function load_mv_test()
    @testset "MV History" begin
        h = make_test_mvhistory(3);
        fPath = joinpath(test_dir(),  "save_mvhistory_test");
        if isfile(fPath)
            rm(fPath);
        end
        save_mvhistory(h, fPath);
        @test isfile(ValueHistoriesLH.meta_path(fPath))
        v = ValueHistoriesLH.load_meta(fPath);
        @test isa(v, Vector{Symbol})

        h2 = load_mvhistory(fPath);
        @test isa(h2, MVHistory);

        for key in keys(h)
            v1 = values(h, key);
            v2 = values(h2, key);
            @test isapprox(v1, reshape(v2, size(v1)))
        end
    end
end


@testset "Load / save" begin
    load_uni_test();
    load_mv_test();
end

# ------------