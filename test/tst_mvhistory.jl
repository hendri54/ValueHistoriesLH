function dict_test()
    @testset "Dict" begin
        h = make_test_mvhistory(3);
        idxV, valueV = get(h, :d);
        d = history_to_dict(h, :d);
        for j = 1 : length(idxV)
            @test isapprox(valueV[j],  d[string(j)])
        end
    end
end

function retrieve_test()
    @testset "Retrieve" begin
        h = MVHistory();
        n = 7;
        for j = 1 : n
            push!(h, :x, j,  j*j);
        end
        for j = 1 : n
            @test retrieve(h, :x, j) == j*j
        end
        @test isnothing(retrieve(h, :x, n+1))
        @test_throws ErrorException retrieve(h, :x, n+1; notFoundError = true)
    end
end


@testset "MVHistory: Basic functions" begin
    _history = MVHistory()
    @test isempty(_history)

    function f(i, b; muh=10)
        @test b == "yo"
        @test muh == .3
        i
    end

    numbers = collect(-10:2:100)
    for i = numbers
        @test push!(_history, :myf, i, f(i + 1, "yo", muh = .3)) == i + 1
        if i % 11 == 0
            @test push!(_history, :myint, i, i - 1) == i - 1
            @test push!(_history, :myint2, i - 1) == i - 1
        end
    end

    println(_history)
    show(_history); println()

    @test_throws AssertionError push!(_history, :myf, 200, "test")

    for k in keys(_history)
        @test k in [:myf, :myint, :myint2]
    end
    @test values(_history, :myf) == numbers .+ 1
    @test_throws KeyError values(_history, :abc)
    @test first(_history, :myf) == (-10, -9)
    @test last(_history, :myf) == (100, 101)
    @test first(_history, :myint) == (0, -1)
    @test last(_history, :myint) == (88, 87)
    @test first(_history, :myint2) == (1, -1)
    @test last(_history, :myint2) == (5, 87)

    for (i, v) in enumerate(_history, :myf)
        @test in(i, numbers)
        @test i + 1 == v
    end

    for (i, v) in enumerate(_history, :myint)
        @test in(i, numbers)
        @test i % 11 == 0
        @test i - 1 == v
    end

    @test typeof(_history[:myf]) <: History

    a1, a2 = get(_history, :myf)
    @test typeof(a1) <: Vector && typeof(a2) <: Vector
    @test length(a1) == length(a2) == length(numbers) == length(_history, :myf)
    @test a1 .+ 1 == a2

    @test_throws ArgumentError push!(_history, :myf, 10, f(10, "yo", muh = .3))
    @test_throws KeyError enumerate(_history, :sign)
    @test_throws KeyError length(_history, :sign)
end

@testset "MVHistory: Storing arbitrary types" begin
    _history = MVHistory(QHistory)

    for i = 1:100
        @test push!(_history, :mystring, i % UInt8, string("i=", i + 1)) == string("i=", i+1)
        @test push!(_history, :myfloat, i % UInt8, Float32(i + 1)) == Float32(i+1)
    end

    @test typeof(_history[:mystring]) <: QHistory

    a1, a2 = get(_history, :mystring)
    @test typeof(a1) <: Vector{UInt8}
    @test typeof(a2) <: Vector{String}

    a1, a2 = get(_history, :myfloat)
    @test typeof(a1) <: Vector{UInt8}
    @test typeof(a2) <: Vector{Float32}
end


@testset "MVHistory: @trace" begin
    _history = MVHistory()
    n = 2
    x = [0.0, 1.0]
    for i = 1:n
        xi = x[i]
        @test @trace(_history, i, xi, round(Int,xi)) == round(Int,xi)
    end

    @test has_series(_history, :xi)
    a1, a2 = get(_history, :xi)
    @test length(a1) == n
    @test length(a2) == n
    @test typeof(a1) <: Vector{Int}
    @test typeof(a2) <: Vector{Float64}

    @test has_series(_history, Symbol("round(Int, xi)"))
    a1, a2 = get(_history, Symbol("round(Int, xi)"))
    @test length(a1) == n
    @test length(a2) == n
    @test typeof(a1) <: Vector{Int}
    @test typeof(a2) <: Vector{Int}
end

@testset "Increment!" begin
    _history = MVHistory()
    key = :test
    val = 1
    @test increment!(_history, key, 1, val) == val
    @test increment!(_history, key, 1, val) == 2val
    @test increment!(_history, key, 2, 4val) == 4val
    @test increment!(_history, key, 10, 5val) == 5val
    _history2 = MVHistory(QHistory)
    @test_throws MethodError increment!(_history2, key, 1, val) == val
end

retrieve_test();
dict_test();

# --------------