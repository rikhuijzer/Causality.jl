
function _stuck!(seen, G::SimpleGraph, node, target)
    seen = copy(seen)
    if node == target
        return false
    end
    for neighbor in neighbors(G, node)
        if !(neighbor in seen)
            push!(seen, neighbor)
            if !(_stuck!(seen, G, neighbor, target))
                return false
            end
        end
    end
    return true
end

function _search!(paths, path, G::SimpleGraph, seen, node, target)
    if node == target
        push!(seen, target)
        seen = sort(collect(seen))
        push!(paths, seen)
        return nothing
    end
    seen = Set(path)
    if _stuck!(seen, G, node, target)
        return nothing
    end
    for neighbor in neighbors(G, node)
        if !(neighbor in path)
            push!(path, neighbor)
            i = length(path)
            _search!(paths, path, G, seen, neighbor, target)
            deleteat!(path, i)
        end
    end
end

"""
    undirected_paths(G::SimpleGraph, source, target)

Return all the paths that connect from and to in the undirected graph G.

Credits to @rgrig at https://mathoverflow.net/questions/18603.
"""
function undirected_paths(G::SimpleGraph, source, target)
    paths = []
    path = [source]
    seen = Set()

    node = source
    _search!(paths, path, G, seen, node, target)
    return paths
end
