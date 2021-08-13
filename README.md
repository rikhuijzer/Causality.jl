# Causality.jl

Automatically determine whether a causal effect is identifiable.

[![CI Testing](https://github.com/rikhuijzer/Causality.jl/workflows/CI/badge.svg)](https://github.com/rikhuijzer/Causality.jl/actions?query=workflow%3ACI+branch%3Amain)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## Status

This package is work in progress.
Applying the rules is going to be possible (see proof of concept below), but this is not going to be enough for all cases.
In some cases, it is necessary to apply a rule in the opposite direction to be able to rewrite successfully.
I was advised to look into [Metatheory.jl](https://github.com/0x0f0f0f/Metatheory.jl) and/or backtracking to solve that problem.

## Example

As a proof of concept, below is a valid application of the second rule of do-calculus.
Note that `P(y, x + Do(z))` is just another way of writing `P(y | x, Do(z))`.
The notation used in this package is a bit weird, but should, for now, be good enough.
The examples are taken from Section 3.4.3 (Pearl, 2009).

```julia
julia> using Causality, SymbolicUtils;

julia> @syms u x z y;

julia> edges = [
            :U => :X,
            :U => :Y,
            :X => :Z,
            :Z => :Y
        ];

julia> G = graph(edges);

julia> r = rule2(G);

julia> r(P(y, x + Do(z)))
P(y, x + z)

julia> r(P(z, Do(x)))
P(z, x)
```
