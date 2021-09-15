module OilData

using DataFrames
using PlotlyJS
using Dates

    
#greet() = print("Hello World!")

include("parser.jl")
export add_day,
       find_prt_start_date,
       read_rsm, 
       find_column_name, 
       find_schedule_end_date, 
       find_prt_current_date,
       find_prt_current_time,
       read_grdecl_float64!,
       read_grdecl_keyword_data!,
       read_grdecl_string!,
       skip_grdecl_keyword_data!

include("plotly.jl")
export plotly_trace, plotly_layout
end # module
