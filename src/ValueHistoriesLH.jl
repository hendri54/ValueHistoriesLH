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


# MVHistory
export has_series, series_names    
export history_to_dict, retrieve, load_history, save_history, load_mvhistory, save_mvhistory
# Single valued histories
export indices

include("abstract.jl")
include("history.jl")
include("qhistory.jl")
include("mvhistory.jl")
include("load_save.jl")
# include("recipes.jl")

end # module
