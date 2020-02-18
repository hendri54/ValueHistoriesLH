using Documenter, ValueHistoriesLH

makedocs(
    modules = [ValueHistoriesLH],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "hendri54",
    sitename = "ValueHistoriesLH.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/hendri54/ValueHistoriesLH.jl.git",
    push_preview = true
)
