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
function add_day(start::Dates.DateTime, duration)
    #d = start + Dates.Millisecond(Int(duration*86400*1000)) # convert days to ms

    d = start + Dates.Millisecond( # convert days to ms
            convert(Int64, round(duration*86400*1000, digits=4)) # 4 is from trial&error, no idea why
        )
    return d
end

# PRT file has the following lines
#
#SECTION  Starting the simulation on 01-Feb-2019.
#SECTION  The simulation has reached 27-Feb-2024 1852 d.
#SECTION  The simulation has reached 28-Feb-2024 1853 d.
#SECTION  Simulation complete.

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

function find_prt_current_time(io::IOStream, pos::Int64)
    seek(io, pos) # re-position, used skip(io, pos) before

    # Find the following line to get TIME and TSTEP:
    #
    #LOG                    TIME  TSTEP       GOR      WCT      OPR      WPR      GPR      FPR      WIR      GIR  ITER  IMPL 
    #                          d      d  MSCF/STB  STB/STB    STB/d    STB/d   MSCF/d      psi    STB/d   MSCF/d           % 
    #          -------------------------------------------------------------------------------------------------------------- 
    #          SCT    ;   16.450  0.450      1.37    0.950   17.116  323.707   23.449  6102.16    0.000    0.000     6   100

    time_token  = nothing
    tstep_token = nothing
    code_token  = nothing
    for line in eachline(io)
        # Check if we are at the right place
        if !startswith(line, "LOG") continue end
        if length(line) < 34        continue end
        tokens = split(line, [' '], keepempty=false)
        if !((tokens[1] == "LOG") && (tokens[2] == "TIME") && (tokens[3] == "TSTEP")) 
            continue
        end

        # skip 2 lines
        # "" == readline(io) when reach EOF
        if "" == readline(io) continue end
        if "" == readline(io) continue end
        
        # Read this line
        #          SCT    ;   16.450  0.450      1.37    0.950   17.116  323.707   23.449  6102.16    0.000    0.000     6   100
        line = readline(io)
        if "" == line continue end
        tokens = split(line, [' '], keepempty=false)
        code_token  = tokens[1] # Time step code, see IX pp 1315, Reporting node reference | Reporting property identifiers | Simulation engine properties | Simulation engine properties requiring special description | TIMESTEP_CONTROL_MODE
        time_token  = tokens[3] # 16.450 Days
        tstep_token = tokens[4] # 0.450 Days
    end

    if isnothing(time_token)
        return nothing
    end

    time = parse(Float64, time_token)
    tstep = parse(Float64, tstep_token)

    return (time=time, tstep=tstep, code=code_token)
end
function find_prt_current_time(path::String)
    open(path, "r") do io
        return find_prt_current_time(io)
    end
end


function find_prt_current_date(io::IOStream, pos::Int64; to_datetime = true)
    seek(io, pos) # re-position, used skip(io, pos) before

    # Possible SECTION lines:
    #
    #SECTION  Starting the simulation on 18-Jan-2020
    #SECTION  The simulation has reached 26-Jan-2021 374 d. ...
    #SECTION  Simulation complete.    

    date_token = nothing
    for line in eachline(io)
        if !startswith(line, "SECTION")
            continue
        end
        if length(line) < 48
            continue
        end
        if startswith(line, "SECTION  The simulation has reached")
            tokens = split(line, [' '], keepempty = false)
            date_token = tokens[6]
            
            #days = convert(Day, datetime - start_datetime)
        end
    end

    if isnothing(date_token)
        #throw(ErrorException("No DATE found"))
        return nothing
    end

    if to_datetime
        return Dates.DateTime(date_token, Dates.dateformat"d-u-Y")
    else
        return date_token
    end
end
function find_prt_current_date(path::String, to_datetime = true)
    open(path, "r") do io
        return find_prt_current_date(io, to_datetime=to_datetime)
    end
end


function find_schedule_end_date(io::IOStream; to_datetime=true)
    date_token = nothing
    for line in eachline(io)
        # DATE "04-Feb-2021" 
        if !startswith(line, "DATE")
            continue
        end

        line = strip(line)
        tokens = split(line, [' ', '"'], keepempty=false)
        date_token = tokens[2]
    end

    if isnothing(date_token)
        #throw(ErrorException("No DATE found"))
        return nothing
    end

    if to_datetime
        return Dates.DateTime(date_token, Dates.dateformat"d-u-Y")
    else
        return date_token
    end

end
function find_schedule_end_date(path::String; to_datetime = true)
    open(path, "r") do io
        return find_schedule_end_date(io, to_datetime=to_datetime)
    end
end

# RSM file
# "1" marks the beginning of a section of data and starts at column 1.
# Data starts at column 2
#
# Use index to access headers.  There are 10 or less columns.  Only the first batch has YEARS column.
# Column indices are [2, 17, 32, 47, 62, 77, 92, 107, 122, 137]
# if the first blank is removed the indices are [1, 16, 31, 46, 61, 76, 91, 106, 121, 136]
# add 14 to reach the end of column so grep [2, 2+14].
# 1st row of header is unique and can be used as column names in DataFrame.
# 2nd row is the unit.
# 3rd and 4th row just call them 3rd and 4th rows.
#
# Use split to read body.
# 
# 
#1
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# SUMMARY OF RUN Pad-X_51_19 :: Run Date and Time : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# TIME           YEARS          FPPW           FPPO           FPPG           FNQT           FNQR           FEIP           FWIT           FWIR           
# DAYS           YEARS          PSIA           PSIA           PSIA           STB            STB/DAY        BTU            STB            STB/DAY        
#                               FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          
#                               1              1              1                                            1                                            
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# 0              0              5316.56        6415.72        7839.82        0              0              0              0              0              
# 1              0.00273785     5316.56        6415.62        7839.75        0              0              0              0              0              
# 4              0.0109514      5316.68        6420.9         7843.84        0              0              0              1.20911        0.403038       
#1
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# SUMMARY OF RUN Pad-X_51_19 :: Run Date and Time : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# TIME           WOPR           WOPR           WOPT           WOPT           WOPT           WOPT           
# DAYS           STB/DAY        STB/DAY        STB            STB            STB            STB            
#                ADA-1763       ADA-1764       ADA-1761       ADA-1762       ADA-1763       ADA-1764       
#                                                                                                          
# ---------------------------------------------------------------------------------------------------------
# 0              0              0              0              0              0              0              
# 1              0              0              0              0              0              0              
# 4              0              0              0              0              0              0              
"""
    read_rsm(io::IOStream)
    read_rsm(filename::String)

Parse RSM file and return (body=DataFrame, meta=DataFrame).

Parse
```
1
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 SUMMARY OF RUN Pad-X_51_19 :: Run Date and Time : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 TIME           YEARS          FPPW           FPPO           FPPG           FNQT           FNQR           FEIP           FWIT           FWIR           
 DAYS           YEARS          PSIA           PSIA           PSIA           STB            STB/DAY        BTU            STB            STB/DAY        
                               FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          
                               1              1              1                                            1                                            
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 0              0              5316.56        6415.72        7839.82        0              0              0              0              0              
 1              0.00273785     5316.56        6415.62        7839.75        0              0              0              0              0              
 4              0.0109514      5316.68        6420.9         7843.84        0              0              0              1.20911        0.403038       
1
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 SUMMARY OF RUN Pad-X_51_19 :: Run Date and Time : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 TIME           WOPR           WOPR           WOPT           WOPT           WOPT           WOPT           
 DAYS           STB/DAY        STB/DAY        STB            STB            STB            STB            
                ADA-1763       ADA-1764       ADA-1761       ADA-1762       ADA-1763       ADA-1764       
                                                                                                          
 ---------------------------------------------------------------------------------------------------------
 0              0              0              0              0              0              0              
 1              0              0              0              0              0              0              
 4              0              0              0              0              0              0              
```

and return a named tuple (body=DataFrame, meta=DataFrame)

`body`
```  
  Row │ TIME       YEARS       FPPW     FPPO     FPPG     
      │ Float64    Float64     Float64  Float64  Float64  
──────┼───────────────────────────────────────────────────
    1 │   0.0      0.0         5316.25  6415.77  7839.76  
    2 │   1.0      0.00273785  5316.22  6415.66  7839.66  
    3 │   1.35154  0.00370032  5322.81  6434.31  7855.26  
    4 │   1.66463  0.0045575   5326.12  6446.29  7865.1   
    5 │   2.30742  0.00631736  5331.27  6462.0   7878.14
```

`meta`
```
 Row │ column       1         2         3         4          
     │ String       String    String    String    String     
─────┼───────────────────────────────────────────────────────
   1 │ TIME         TIME      DAYS
   2 │ YEARS        YEARS     YEARS
   3 │ FPPW         FPPW      PSIA      FIELD     1
   4 │ FPPO         FPPO      PSIA      FIELD     1
 ...  
 199 │ WOPR         WOPR      STB/DAY   ADA-1761
 200 │ WOPR_3       WOPR      STB/DAY   ADA-1762
 201 │ WOPR_1       WOPR      STB/DAY   ADA-1763
 202 │ WOPR_2       WOPR      STB/DAY   ADA-1764
```

 where
 * `column` is the unique column name in `body`
 * "1" is the first row in RSM header
 * "2" is the second row in RSM header
 * "3" is the third row in RSM header
 * "4" is the fourth row in RSM header
"""
function read_rsm(io::IOStream)
    line = readline(io) # 1

    # Read first SUMMARY
    nt = read_rsm_section(io) # (body = df_body, meta = df_meta)
    df_body = nt.body
    df_meta = nt.meta

    # Append the rest of SUMMARY
    while !eof(io)
        nt = read_rsm_section(io)

        # Must have the same number or rows
        @assert size(df_body)[1] == size(nt.body)[1] "SUMMARY sections has different number of rows"
        
        # skip the first column which is DAYS again
        df_body = hcat(df_body, nt.body[!,2:end], makeunique=true)
        df_meta = hcat(df_meta, nt.meta[!,2:end], makeunique=true)
    end

    # assert
    @assert names(nt.meta) == names(nt.body) "DataFrame generates different column names?"

    # Transpose meta table
    # https://stackoverflow.com/questions/37668312/transpose-of-julia-dataframe
    df = df_meta
    df_meta = DataFrame([[names(df)]; collect.(eachrow(df))], [:column; Symbol.(axes(df, 1))])
    
    return (body = df_body, meta = df_meta)
end
function read_rsm(filename)
    nt = nothing
    open(filename, "r") do io
        nt = read_rsm(io)
    end

    return nt
end

"""
    read_rsm_section(io::IOStream)

Reads a section of RSM file.

A section could end with "1"
```
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 SUMMARY OF RUN Pad-X_51_19 :: Run Date and Time : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 TIME           YEARS          FPPW           FPPO           FPPG           FNQT           FNQR           FEIP           FWIT           FWIR           
 DAYS           YEARS          PSIA           PSIA           PSIA           STB            STB/DAY        BTU            STB            STB/DAY        
                               FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          
                               1              1              1                                            1                                            
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 0              0              5316.56        6415.72        7839.82        0              0              0              0              0              
 1              0.00273785     5316.56        6415.62        7839.75        0              0              0              0              0              
 4              0.0109514      5316.68        6420.9         7843.84        0              0              0              1.20911        0.403038       
1
```

or `eof`

```
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 SUMMARY OF RUN Pad-X_51_19 :: Run Date and Time : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 TIME           YEARS          FPPW           FPPO           FPPG           FNQT           FNQR           FEIP           FWIT           FWIR           
 DAYS           YEARS          PSIA           PSIA           PSIA           STB            STB/DAY        BTU            STB            STB/DAY        
                               FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          
                               1              1              1                                            1                                            
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 0              0              5316.56        6415.72        7839.82        0              0              0              0              0              
 1              0.00273785     5316.56        6415.62        7839.75        0              0              0              0              0              
 4              0.0109514      5316.68        6420.9         7843.84        0              0              0              1.20911        0.403038       
```
"""
function read_rsm_section(io::IOStream)
    # starts right after "1"
    # ends with "1" or eof
    
    colinds = [2, 17, 32, 47, 62, 77, 92, 107, 122, 137]
    delta = 14
    delimiters = [' ']
    #delimiters = [' ', ',', '\t']

    readline(io) # ---------------...
    readline(io) # SUMMARY OF RUN ...
    readline(io) # ---------------...

    # Column name:  TIME           YEARS          FPPW           FPPO           FPPG           FNQT           FNQR           FEIP           FWIT           FWIR           
    line = readline(io)
    tokens = split(line , delimiters, keepempty=false)
    col_count = length(tokens)
    row_1 = tokens

    # Create DataFrame
    df_body = DataFrame(fill(Float64[], col_count), row_1, makeunique=true)
    df_meta = DataFrame(fill(String[],  col_count), row_1, makeunique=true)

    push!(df_meta, row_1)

    # units:  DAYS           YEARS          PSIA           PSIA           PSIA           STB            STB/DAY        BTU            STB            STB/DAY        
    line = readline(io)
    tokens = String[]
    for colind in colinds
        if colind > length(line)
            break
        end
        token = strip(line[colind:colind+delta])
        push!(tokens, token)
    end
    row_2 = tokens
    push!(df_meta, row_2)

    # 3rd row: 
    line = readline(io)
    tokens = String[]
    for colind in colinds
        if colind > length(line)
            break
        end
        token = strip(line[colind:colind+delta])
        push!(tokens, token)
    end
    row_3 = tokens
    push!(df_meta, row_3)

    # 4th row: 
    line = readline(io)
    tokens = String[]
    for colind in colinds
        if colind > length(line)
            break
        end
        token = strip(line[colind:colind+delta])
        push!(tokens, token)
    end
    row_4 = tokens
    push!(df_meta, row_4)

    readline(io) # ---------------...

    # Body
    while !eof(io)
        line = readline(io)
        
        if "1" == line
            break
        end
        if isempty(line)
            break
        end
        tokens = split(line, delimiters, keepempty=false)
        tokens = parse.(Float64, tokens)
        push!(df_body, tokens)
    end

    return (body = df_body, meta = df_meta)
end

"""


    find_column_name(df_meta, c1, c3, c4)

Filter rows of the meta table based on column 1, 3, 4.  Check if there is 
1 and only 1 row, then return [1,1] that is "WOPR_3" in the example.

```
 Row │ column  1       2        3         4
     │ String  String  String   String    String
─────┼───────────────────────────────────────────
   1 │ WOPR_3  WOPR    STB/DAY  ADA-1762
```
"""
function find_column_name(df_meta, c1, c3, c4)
    df = filter(
        ["1", "3", "4"] => (x1,x3,x4) -> c1 == x1 && c3 == x3 && c4 == x4, 
        df_meta
    )

    @assert size(df)[1] == 1 "None or multiple column names found"

    return df[1,1]
end

"""
    skip_grdecl_keyword_data!(io)

Skip the content of a keyword after the keyword has been read and determined
the content should be skipped.
"""
function skip_grdecl_keyword_data!(io)
    time_to_break = false
    
    for line in eachline(io)
        if time_to_break
            break
        end
        if endswith(line, '/')
            time_to_break = true
        end
    end
end

"""
    read_grdecl_keyword_data!(io::IO, values::Array{T}) where {T<:String}

Read keyword data as `String`.
"""
function read_grdecl_keyword_data!(io::IO, values::Array{T}) where {T<:String}
    # Read tokens
    tokens = String[]
    for line in eachline(io)
        line = strip(line)
        if isempty(line)           continue  end
        if startswith(line, "--")  continue  end

        append!(tokens, split(line))

        if endswith(line, '/')  break  end
    end

    values .= tokens

    return nothing
end

"""
    read_grdecl_keyword_data!(io::IO, values::Array{T}) where {T<:Real}

Read keyword data as subtypes of `Real`.
Read values of a keyword.  Notice the keyword should has been read before
calling this function. 
"""
function read_grdecl_keyword_data!(io::IO, values::Array{T}) where {T<:Real}
    # Read tokens as strings
    tokens = Vector{String}()
    for line in eachline(io)

        line = strip(line)
        if isempty(line)           continue  end
        if startswith(line, "--")  continue  end

        append!(tokens, split(line))

        if endswith(line, '/')  break  end
    end

    # remove "/"
    tokens = tokens[1:end-1]

    # Parse tokens into Float64
    ind = 1
    for token in tokens
        count_value = split(token,"*")
        if length(count_value) == 2
            count = parse(Int64,    count_value[1])
            value = parse(T, count_value[2]) # eltype(T)?
            for x = 1:count
                values[ind] = value
                ind += 1
            end
        else
            values[ind] = parse(T, count_value[1]) # eltype(T)?
            ind += 1
        end
    end

    return nothing
end

"""
    read_grdecl_keyword_data!(io::IO, values::Array{T}, prop::String) where {T<:Real}

Read static data.
Read data of a given keyword as a subtype of `Real`.
"""
function read_grdecl_keyword_data!(io::IO, values::Array{T}, prop::String) where {T<:Real}
    for line in eachline(io)
        line = strip(line)

        if isempty(line)          continue end
        if startswith(line, "--") continue end
        tokens = split(line)
        if isempty(tokens)        continue end # will this every happen?
        
        keyword = tokens[1]
        if keyword != prop
            skip_grdecl_keyword_data!(io)
        else
            read_grdecl_keyword_data!(io, values)

            return true
        end
    end

    return false
end

"""

Read dynamic data (with timestamp)

# Arguments
- `values`: Pre-allocated array to save values to
- `prop`: Property name
- `date`: Date
"""
function read_grdecl_keyword_data!(io::IO, values::Array{T}, prop::String, date) where {T<:Real}
    for line in eachline(io)
        line = strip(line)
        if startswith(line, "--")
            continue
        end
        if isempty(line)
            continue
        end

        tokens = split(line)
        if isempty(tokens)
            continue
        end
        
        keyword = tokens[1]
        if keyword != prop
            skip_grdecl_keyword_data!(io)
        else
            # Read timestep
            line = readline(io)
            tokens = split(line, [' ', ','], keepempty=false)
            # last 4 tokens are time: Jan 07,2022 00:00:00
            timee = tokens[end]
            yearr = tokens[end-1]
            datee = tokens[end-2]
            monthh = tokens[end-3]
            
            #current_date = Date("$yearr-$monthh-$datee", dateformat"y-u-d") # 2022-Jan-07
            current_date = Date("$yearr-$monthh-$(datee)T$(timee)", dateformat"y-u-dTHH:MM:SS") # 2022-Jan-07
            #DateTime("2021-Jun-18T15:38:17", DateFormat("y-u-dTHH:MM:SS"))
            
            if current_date != date
                skip_grdecl_keyword_data!(io)
            else
                read_grdecl_keyword_data!(io, values)

                return true
            end
        end
    end

    return false
end
