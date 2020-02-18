module ValueHistoriesLH

using DataStructures, DocStringExtensions
# using RecipesBase

import Base: isempty

export
    ValueHistory,
      UnivalueHistory,
        History,
        QHistory,
      MultivalueHistory,
        MVHistory,
        increment!,
    @trace

export retrieve

include("abstract.jl")
include("history.jl")
include("qhistory.jl")
include("mvhistory.jl")
# include("recipes.jl")

end # module
