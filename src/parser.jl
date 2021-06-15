using DataFrames
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
function add_day(start::Dates.DateTime, duration)
    d = start + Dates.Millisecond(Int(duration*86400*1000)) # convert days to ms
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
# SUMMARY OF RUN Pad-X_50_19 :: Run Date and Time : Fri Jun 11 12:18:19 2021 Central Daylight Time
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# TIME           YEARS          FPPW           FPPO           FPPG           FNQT           FNQR           FEIP           FWIT           FWIR           
# DAYS           YEARS          PSIA           PSIA           PSIA           STB            STB/DAY        BTU            STB            STB/DAY        
#                               FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          FIELD          
#                               1              1              1                                            1                                            
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# 0              0              5316.56        6415.72        7839.82        0              0              0              0              0              
# 1              0.00273785     5316.56        6415.62        7839.75        0              0              0              0              0              
# 4              0.0109514      5316.68        6420.9         7843.84        0              0              0              1.20911        0.403038       
#
#1
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# SUMMARY OF RUN Pad-X_50_19 :: Run Date and Time : Fri Jun 11 12:18:19 2021 Central Daylight Time
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# TIME           CWPRL          CWPTL          GGIR           GGIR           GGIT           GGIT           GGOR           GGOR           GGPR           
# DAYS           STB/DAY        STB            MSCF/DAY       MSCF/DAY       MSCF           MSCF           MSCF/STB       MSCF/STB       MSCF/DAY       
#                MdM-20XX       MdM-20XX       G              FIELD          G              FIELD          G              FIELD          G              
#                40 24 15       40 24 15                                                                                                                
# ------------------------------------------------------------------------------------------------------------------------------------------------------
# 0              0              0              0              0              0              0              0              0              0              
# 1              0              0              0              0              0              0              0              0              0              
# 4              0              0              0              0              0              0              0              0              0              
# 9.5            0              0              0              0              0              0              0              0              0              

"""

nt.body
  Row │ TIME       YEARS       FPPW     FPPO     FPPG     
      │ Float64    Float64     Float64  Float64  Float64  
──────┼───────────────────────────────────────────────────
    1 │   0.0      0.0         5316.25  6415.77  7839.76  
    2 │   1.0      0.00273785  5316.22  6415.66  7839.66  
    3 │   1.35154  0.00370032  5322.81  6434.31  7855.26  
    4 │   1.66463  0.0045575   5326.12  6446.29  7865.1   
    5 │   2.30742  0.00631736  5331.27  6462.0   7878.14

nt.meta
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
"""
function read_rsm(io::IOStream)
    line = readline(io) # 1
    nt = read_rsm_section(io) # (body = df_body, meta = df_meta)
    df_body = nt.body
    df_meta = nt.meta
    while !eof(io)
        nt = read_rsm_section(io)

        # Must have the same number or rows
        @assert size(df_body)[1] == size(nt.body)[1] "SUMMARY sections has different number of rows"
        
        df_body = hcat(df_body, nt.body[!,2:end], makeunique=true) # skip 1st column that is DAYS
        df_meta = hcat(df_meta, nt.meta[!,2:end], makeunique=true)
    end

    # assert
    @assert names(nt.meta) == names(nt.body) "DataFrame generates different column names?"

    # Transpose meta table
    # https://stackoverflow.com/questions/37668312/transpose-of-julia-dataframe
    df = df_meta
    df_metat = DataFrame([[names(df)]; collect.(eachrow(df))], [:column; Symbol.(axes(df, 1))])
    
    return (body = df_body, meta = df_metat)
end
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