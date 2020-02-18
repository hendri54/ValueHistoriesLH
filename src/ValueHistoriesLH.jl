module ValueHistoriesLH

using DataStructures
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

include("abstract.jl")
include("history.jl")
include("qhistory.jl")
include("mvhistory.jl")
# include("recipes.jl")

end # module
