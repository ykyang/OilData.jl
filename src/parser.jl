import Dates
# """
#     add_day()

# Return DateTime that is one day from now.
# """
# function add_day()
#     return add_day(now(), 1.0)
# end

"""
add_day(start, duration)

Add `duration` number of days to the `start` date.  Number of days could be
decimal.

# Examples
```julia-repl
julia> start = Dates.DateTime(Dates.now())
2021-01-01T15:41:31.91

julia> later = add_day(start, 1.50)
2021-01-03T03:41:31.91
```
"""
function add_day(start, duration)
    d = start + Dates.Millisecond(Int(duration*86400*1000)) # convert days to ms
    return d
end
"""
    find_prt_start_date(io; to_datetime = true)

Find simulation start date from a PRT file.  Return `DateTime` if `to_datetime`
is true otherwise a string in the "d-u-Y" format such as "01-Feb-2019".

# Examples
```julia-repl
julia> start_datetime = find_prt_start_date(prt_file)
2019-02-01T00:00:00
```
"""
function find_prt_start_date(io::IOStream; to_datetime = true)
    for line in eachline(io)
        if !startswith(line, "SECTION  Starting the simulation on")
            continue
        end
        line = strip(line)
        #tokens = split(line, x -> x in [' ', '.'], keepempty=false)
        tokens = split(line, [' ', '.'], keepempty=false)
        
        startdate_token = tokens[6] # "01-Feb-2019"
        if to_datetime
            return Dates.DateTime(startdate_token, Dates.dateformat"d-u-Y")
        else
            return startdate_token
        end
        
    end

    nothing
end
function find_prt_start_date(path::String; to_datetime = true)
    open(path, "r") do io
        return find_prt_start_date(io, to_datetime=to_datetime)
    end
end