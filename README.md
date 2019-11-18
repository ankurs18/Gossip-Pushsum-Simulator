# Gossip Pushsum Simulator

A simulator in Elixir for these communication algorithms for aggregating Information: Gossip and Push-sum. 
The goal of the simulator is to determine the convergence time and ratio for a given number of nodes, and judge the performance for the different topologies. 
The simulator can run following topologies: 2D Grid, 3D Torus Grid, Honeycomb, Full, Line. 
Also provided is the simulation and testing of node failure conditions.
Implementation is done as described in this publication: https://www.cs.cornell.edu/johannes/papers/2003/focs2003-gossip.pdf

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gossip_pushsum_simulator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gossip_pushsum_simulator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gossip_pushsum_simulator](https://hexdocs.pm/gossip_pushsum_simulator).

