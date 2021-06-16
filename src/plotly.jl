function Base.merge!(trace::GenericTrace, db)
    for pair in db # pairs
        trace[pair[1]] = pair[2]
    end
end

function wbhp_trace(;alpha=0.2, db...)
    trace = scatter(
        mode = "lines",
        line = Dict(
            :color => "rgba(0,0,0,$alpha)",
        ),
        yaxis = "y3",
    )

    merge!(trace, db)

    return trace
end