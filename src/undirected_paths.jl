
function _stuck(G::SimpleGraph, seen, node, target)
    if node == target
        return false
    end
    for neighbor in neighbors(G, node)
        push!(seen, neighbor)
        if !(_stuck(neighbor))
            return false
        end
    end
    return true
end

# TODO: if error then probably need to do deepcopy somewhere.

function _search!(paths, path, G::SimpleGraph, seen, node, target)
    if node == target
        push!(paths, path)
        return nothing
    end
    seen = Set(path)
    if _stuck!(G, seen, node, target)
        return nothing
    end
    for neighbor in neighbors(G, node)
        if !(neighbor in path)
            push!(path, neighbor)
            i = length(path)
            _search(paths, path, G, seen, node, target)
            deleteat!(path, i)
        end
    end
end

"""
    undirected_paths_search(...

Return all the paths that connect from and to in the undirected graph G.

Credits to @rgrig at https://mathoverflow.net/questions/18603.
"""
function undirected_paths_search(G::SimpleGraph, source, target)
    paths = []
    path = []
    seen = Set()

    node = source
    _search!(paths, path, G, seen, node, target)
    return paths
end
