module OilData

using DataFrames
using PlotlyJS
using Dates
using HDF5

    
#greet() = print("Hello World!")

include("parser.jl")
export add_day,
       find_prt_start_date,
       read_hdf5_times,
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
export plotly_trace, plotly_layout,
       axis_time,
       axis_bhp,
       axis_oil_rate,
       axis_water_rate

include("utility.jl")
export downsample, find_duplication,
       find_integer_times,
       find_indices,
       find_last_duplication,
       repair_times,
       smooth_production

end # module
