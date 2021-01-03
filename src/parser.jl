import Dates

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
function add_day(start::Dates.DateTime, duration::AbstractFloat)
    d = start + Dates.Millisecond(Int(duration*86400*1000)) # convert days to ms
    return d
end