
"""

Smooth production data
Backward integration
"""
function smooth_production(df::DataFrame, time_col_name, col_names)
    times = df[!,time_col_name]

    # Find times at integer
    # TODO: User array operation
    int_times = Int64[] # values of times where time is int
    ind_times = Int64[] # index into times where time is int
    for (ind,time) in enumerate(times)
       if trunc(time) == time
            push!(int_times, time)
            push!(ind_times, ind)
       end
    end

    count = length(ind_times)
    rdf = DataFrame(
        "TIME" => int_times
    )
    #@show ind_times
    for col_name in col_names # each column
        col = df[!,col_name]

        new_col = Float64[]
        push!(new_col, col[1])        
        # For each integration interval, i.e., time = 0-1, 1-2, 2-3, 3-4 ...
        for (first_ind, last_ind, first_time, last_time) in zip(ind_times[1:end-1], ind_times[2:end], int_times[1:end-1], int_times[2:end])
            
            #@show first_ind, last_ind
            total = 0.0
            # index into the data within an interval,
            # backward integration
            for ind = first_ind+1:last_ind 
                total += col[ind] * (times[ind] - times[ind-1])
            end
            total /= (last_time - first_time)
            push!(new_col, total)
        end
        rdf[:,col_name] = new_col
        #@show rdf[!,col_name]
    end


    return rdf
end