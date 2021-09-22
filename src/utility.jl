"""
    find_integers(in_values)

Find indices and values in `values` that are integer.  This is more for
practice than practical purpose, because it is so simple.
"""
function find_integers(values)
    inds = findall(x->trunc(x) == x, values)
    return (inds, values[inds])
end


function find_indices(filter, values)
    inds = findall(x-> x in filter, values)
    return inds
end

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
"""

# Arguments
- `selected_times`: Smoothed to these selected times
- `time_col`: Name of time column
- `cols`: Names of the columns to be smoothed

"""
function smooth_production(df::DataFrame, selected_times, time_col, cols)
    times = df[!, time_col]
    #@show times
    selected_indices = findall(x->x in selected_times, times)
    #@show selected_times
    if length(selected_times) != length(selected_indices)
        @show length(selected_indices)
        @show length(selected_times)
        #@show selected_indices
        for t in selected_indices
            
                #@show times[t]
            
        end
    end
    @assert length(selected_times) == length(selected_indices) "Not all selected times found"

    selected_count = length(selected_times) # No. of selected times
    # DataFrame for selected values
    sdf = DataFrame(time_col => selected_times) 

    for col_name in cols # column names
        col = df[!, col_name]

        new_col = Float64[]
        push!(new_col, col[1]) # backward time difference so 1st is the same
        for i in 1:selected_count-1 # Each interval between selected times
            ind1  = selected_indices[i]
            time1 =   selected_times[i]
            ind2  = selected_indices[i+1]
            time2 =   selected_times[i+1]
            
            if time1 == time2
                @show time1
            end
            # Cal average
            # This method is mass conservative.
            total = 0.0
            for ind = ind1+1 : ind2 # Each interval between a pair of selected times
                # backward finite-difference in time
                total += col[ind] * (times[ind] - times[ind-1])
            end
            total /= (time2-time1)
            if isnan(total)
                @show total
            end
            push!(new_col, total)
        end

        sdf[:,col_name] = new_col
    end

    return sdf
end