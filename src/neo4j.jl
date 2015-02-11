using Requests
using JSON

function toneo4j(
    g::AbstractGraph;
    url::AbstractString="http://localhost:7474",
    vdict::Array{Dict{AbstractString, AbstractString}, 1} = Dict{AbstractString, AbstractString}[],
    etype::AbstractString="edge"

    )

    v_to_n = []
    jsonheaders = Dict(
        "Content-Type"  => "application/json",
        "Accept"        => "application/json; charset=UTF-8"
    )
    nodeurl = string(url, "/db/data/node")
    n_v = nv(g)
    usevdict = length(vdict) == n_v
    z = []
    # create nodes
    for i in 1:n_v

        if usevdict
            props = vdict[i]
        else
            props = Dict("id"=>i)
        end
        res = post(nodeurl, json=props, headers=jsonheaders)
        if parseint(res.headers["status_code"]) != 201
            g = res.headers["status_code"]
            warn("got status code $g for vertex $i")
        end
        n = int(split(res.headers["Location"],"/")[end])
        push!(v_to_n, n)
    end

    # create edges
    for e in edges(g)
        se = src(e)
        de = dst(e)
        sn = v_to_n[se]
        dn = v_to_n[de]
        edgeurl = string(nodeurl,"/",sn,"/relationships")
        # dir = isdirected(g)? "all" : "out"
        tos = string(nodeurl,"/",dn)


        props = Dict("to"=>tos, "type"=>etype)
        res = post(edgeurl, json=props, headers=jsonheaders)
        if parseint(res.headers["status_code"]) != 201
            g = res.headers["status_code"]
            warn("got status code $g for $e")
        end
    end
end
