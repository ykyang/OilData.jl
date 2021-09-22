"""
    find_integer_times(times)

Find time steps that are integer.  Return the indices and values found
as `(inds,vals)` where `inds` are the indices of `vals` in `times`.  Throw exception if there are duplicated integers in
`times`.  The unit of `times` in reservoir simulation is usually in days.
"""
function find_integer_times(times)
    integer_time_inds = findall(x->trunc(x) == x, times)
    integer_times = times[integer_time_inds]

    # Check for uniqueness
    if length(integer_times) != length(unique(integer_times))
        # This is caused by small time steps, and simulator
        # does not print all digits.
        throw(ErrorException("Non-unique integer times detected"))
    end

    return (integer_time_inds, integer_times)
end

"""
    find_indices(filter, values)

Find the indices of `filter` in `values`.  Throw exception if there is 
duplication in `values`.
"""
function find_indices(filter, values)
    if length(values) != length(unique(values))
        # This is caused by small time steps, and simulator
        # does not print all digits.
        throw(ErrorException("Non-unique values detected"))
    end

    inds = findall(x-> x in filter, values)

    return inds
end

"""

Repair 
`[1, 1.5, 2, 2, 2, 2, 3]` to [1, 1.5, 2, 2.25, 2.50, 2.75, 3].
Notice the last time step cannot be duplicated.
"""
function repair_times(times)
    # Last time step cannot be duplicated
    if length(times) > 1 && times[end-1] == times[end]
        throw(ErrorException("Last time step is duplicated"))
    end

    # eltype(times) -> Float64 for example
    ret = eltype(times)[]
    
    ind = 1
    while (ind <= length(times))
        push!(ret, times[ind])
        
        ind_end = find_last_duplication(ind, times)
        
        if ind_end == ind # no duplication
            ind += 1
            continue
        end

        # Duplication detected
        # Add delta to all the duplicated value except the first one

        # Example
        # [1, 1.5, 2, 2, 2, 2, 3]
        # ind     = 3
        # ind_end = 6
        # delta = (3-2)/(6+1-3) = 0.25
        delta = (times[ind_end+1] - times[ind])/(ind_end+1-ind)
        for i in ind:ind_end-1
            push!(ret, ret[i] + delta)
        end

        ind = ind_end + 1
    end

    return ret
end

"""

Find the index to the last duplication in the ordered list `values`,
starting from `values[ind]`.  


Return `6` for `ind=3` and `values=[1, 1.5, 2, 2, 2, 2, 3]` 

# Examples
```julia-repl
julia> find_last_duplication(3, [1, 1.5, 2, 2, 2, 2, 3])
6
```
"""
function find_last_duplication(ind, values)
    value = values[ind]
    for i = ind+1:length(values)
        if values[i] != value
            return i-1
        end
    end

    return ind # == length(values)
end


"""

Deprecated
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
function smooth_production(df::DataFrame, times, selected_times, cols)
    #times = df[!, time_col]
    #@show times
    selected_indices = find_indices(selected_times, times) #findall(x->x in selected_times, times)
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
    sdf = DataFrame("TIME" => selected_times) 

    for col_name in cols # column names
        col = df[!, col_name]
        @show col_name
        @show length(col)
        new_col = Float64[]
        push!(new_col, col[1]) # backward time difference so 1st is the same
        for i in 1:selected_count-1 # Each interval between selected times
            ind1  = selected_indices[i]
            time1 =   selected_times[i]
            ind2  = selected_indices[i+1]
            time2 =   selected_times[i+1]
            
            # if time1 == time2
            #     @show time1
            # end
            # Cal average
            # This method is mass conservative.
            total = 0.0
            #@show time1
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