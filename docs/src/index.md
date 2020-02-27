# ValueHistoriesLH

```@meta
CurrentModule = ValueHistoriesLH
```

This is a minor modification of `ValueHistories.jl`. The main purpose is to keep the package up to date.

Important note: When using `push` to add entries to the stored histories, users must make a *deep copy* of mutable objects to be stored. Otherwise, the same object is stored in each iteration.

Additions are:

* `isempty` for [`MVHistory`] objects
* [`retrieve`](@ref)

# Function Reference

```@autodocs
Modules = [ValueHistoriesLH]
```

