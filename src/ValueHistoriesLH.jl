module ValueHistoriesLH

using DataStructures, DocStringExtensions, JSON3
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

export history_to_dict, retrieve, load_history, save_history, load_mvhistory, save_mvhistory

include("abstract.jl")
include("history.jl")
include("qhistory.jl")
include("mvhistory.jl")
include("load_save.jl")
# include("recipes.jl")

end # module
