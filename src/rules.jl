"""
    NodeSet

A set of `nodes` in a causal DAG.
The fields `incoming` and `outgoing` express whether there are, respectively, incoming or
outgoing arrows pointing towards this set of nodes.

!!
    When using a NodeSet in a rule, ensure to avoid overlap between the sets.
"""
struct NodeSet
    nodes::Set{Symbol}
    incoming::Bool
    outgoing::Bool

    function NodeSet(nodes; incoming::Bool=true, outgoing::Bool=true)
        nodes = length(nodes) == 1 ? [Symbol(nodes)] : Symbol.(nodes)
        return new(Set(nodes), incoming, outgoing)
    end
    function NodeSet(nodes::Set{Symbol}, incoming::Bool=true, outgoing::Bool=true)
        return new(nodes, incoming, outgoing)
    end
    function NodeSet(nodes::Set, incoming::Bool=true, outgoing::Bool=true)
        nodes = Set(Symbol.(nodes))
        return new(nodes, incoming, outgoing)
    end
end

function Base.:(==)(a::NodeSet, b::NodeSet)
    nodes_equal = a.nodes == b.nodes
    incoming_equal = a.incoming == b.incoming
    outgoing_equal = a.outgoing == b.outgoing
    return nodes_equal && incoming_equal && outgoing_equal
end

