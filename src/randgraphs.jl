# These are test functions only, used for consistent centrality comparisons.
function Graph(nv::Integer, ne::Integer)
    g = Graph(nv)

    i = 1
    while i <= ne
        source = rand(1:nv)
        dest = rand(1:nv)
        e = (source, dest)
        if (source != dest) && !(has_edge(g,source,dest))
            i+= 1
            add_edge!(g,source,dest)
        end
    end
    return g
end

function DiGraph(nv::Integer, ne::Integer)
    g = DiGraph(nv)

    i = 1
    while i <= ne
        source = rand(1:nv)
        dest = rand(1:nv)
        e = (source, dest)
        if (source != dest) && !(has_edge(g,source,dest))
            i+= 1
            add_edge!(g,source,dest)
        end
    end
    return g
end

function erdos_renyi(n::Integer, p::Real; is_directed=false)
    if is_directed
        g = DiGraph(n)
    else
        g = Graph(n)
    end

    for i = 1:n
        jstart = is_directed? 1 : i
        for j = jstart : n
            if i != j && rand() <= p
                add_edge!(g, i, j)
            end
        end
    end
    return g
end

function watts_strogatz(n::Integer, k::Integer, β::Real; is_directed=false)
    @assert k < n/2
    if is_directed
        g = DiGraph(n)
    else
        g = Graph(n)
    end
    for s in 1:n
        for i in 1:(floor(Integer, k/2))
            target = ((s + i - 1) % n) + 1
            if rand() > β && !has_edge(g,s,target)
                add_edge!(g, s, target)
            else
                while true
                    d = target
                    while d == target
                        d = rand(1:(n-1))
                        if s < d
                            d += 1
                        end
                    end
                    if !has_edge(g, s, d) && s != d
                        add_edge!(g, s, d)

                        break
                    end
                end
            end
        end
    end
    return g
end

function random_regular_graph(n::Integer, k::Integer, seed=-1)
    @assert(n * k % 2 == 0, "n * k must be even")
    @assert(0 <= k < n, "the 0 <= k < n inequality must be satisfied")
    if k == 0
        return Graph(n)
    end
    if seed >= 0
        srand(seed)
    end
    
    function suitable(edges, potential_edges)
        if isempty(potential_edges)
            return true
        end
        ends = collect(keys(potential_edges))
        for i in 1:length(ends)
            for j in i+1:length(ends)
                s1, s2 = ends[i:i+1]
                if s1 > s2
                    s1, s2 = s2, s1
                end
                if ∉((s1, s2), edges)
                    return true
                end
            end
        end
        return false
    end
    
    function try_creation()
        edges = Set()
        stubs = []
        for _ in 1:k
            stubs = vcat(stubs, [1:n])
        end
        
        while !isempty(stubs)
            potential_edges =  Dict{Int,Int}()
            shuffle!(stubs)
            for i in 1:2:length(stubs)
                s1,s2 = stubs[i:i+1]
                if s1 > s2
                    s1, s2 = s2, s1
                end
                if s1 != s2 && ∉((s1, s2), edges)
                    union!(edges, [(s1, s2)])
                else
                    potential_edges[s1] = get(potential_edges, s1, 0) + 1
                    potential_edges[s2] = get(potential_edges, s2, 0) + 1
                end
            end
            
            if !suitable(edges, potential_edges)
                return Set()
            end
            
            stubs = []
            for (e, ct) in potential_edges
                stubs = vcat(stubs, fill(e, ct))
            end
        end
        return edges
    end
    
    edges = try_creation()
    while isempty(edges)
        edges = try_creation()
    end
    
    G = Graph(n)
    for edge in edges
        add_edge!(G, edge...)
    end
    
    return G
end
