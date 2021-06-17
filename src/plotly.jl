# function Base.merge!(trace::GenericTrace, db)
#     for pair in db # pairs
#         trace[pair[1]] = pair[2]
#     end
# end

function plotly_trace(
    label;
    line_alpha = 0.3, marker_alpha = 1,
    db...
    )

    trace = nothing
    if     "WBHP"  == label
        trace = scatter(
            mode = "lines",
            line = Dict(
                :color => "rgba(0,0,0,$line_alpha)",
            ),
            yaxis = "y3",
        )
    elseif "WBHPH" == label
        trace = scatter(
            mode = "markers",
            marker = Dict(
                :color => "rgba(0,0,0,$marker_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb(0,0,0)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y3",
        )                
    elseif "WOPR"  == label
        trace = scatter(
            mode = "lines",
            line = Dict(
                :shape => "vh",
                :color => "rgba(0,128,0,$line_alpha)",
            ),
        )        
    elseif "WOPRH" == label
        trace = scatter(
            mode = "markers",
            marker = Dict(
                :color => "rgba(0,128,0,$marker_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb(0,128,0)",
                    :width => 0,
                    #:width => 1,
                ),
            ),
        )
    elseif "WOPT"  == label
        trace = scatter(
            mode = "lines",
            line = Dict(
                :color => "rgba(0,128,0,$line_alpha)",
             ),
            yaxis = "y2",
         )
    elseif "WOPTH" == label
        trace = scatter(
            mode = "markers",
            marker = Dict(
                :color => "rgba(0,128,0,$marker_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb(0,128,0)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y2",
        )
    elseif "WWPR"  == label
        trace = scatter(
            mode = "lines",
            line = Dict(
                :shape => "vh",
                :color => "rgba(30,144,255,$line_alpha)",
             ),
         )        
    elseif "WWPRH" == label
        trace = scatter(
            mode = "markers",
            marker = Dict(
                :color => "rgba(30,144,255,$marker_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb(30,144,255)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )        
    else
        throw(ErrorException("Unknown label: $label"))
    end

    for pair in db # pairs
        trace[pair[1]] = pair[2]
    end

    return trace
end

function plotly_layout()
    layout = Layout(
        #title = "Pad 6",
        #showlegend = false,
        showlegend = true,
        margin = Dict(
            #:pad => -10,
            #:b => 0,
        ),
        xaxis = Dict(
            :title => "Time",
            :dtick => 86400*1000*30, # unit is ms
            :ticklen => 5,
            :domain => [0.1, 0.95],
            :rangemode => "tozero",
            #:automargin => false,
            #:showspikes => false,
            #:spikemode => "toaxis",
            #:showline => true,
            #:tickformat => "%b %Y",
            #:tickvals = [1, 3, 5, 7, 9, 11],
            #:ticktext = ['One', 'Three', 'Five', 'Seven', 'Nine', 'Eleven']
        ),
        yaxis = Dict(
            :title => "Liquid Flowrate [STB/d]",
            #:range => [0, 35],
            :showline => true,
            :ticklen => 5,
            :rangemode => "tozero",
        ),
        yaxis2 = Dict(
            :title => "Liquid Production Volume [STB]",
            #:range => [0, 2500],
            :rangemode => "tozero",
            :ticklen => 5,
            # titlefont: {color: '#ff7f0e'},
            # tickfont: {color: '#ff7f0e'},
            :anchor => "x", # "free"
            :overlaying => "y",
            :side => "right",
            :position => 1.0,
            :showline => true,
            :zeroline => false,
            :showgrid => false,
        ),
        yaxis3 = Dict(
            :title => "Pressure [psi]",
            #:range => [0, 11000],
            :rangemode => "tozero",
            :ticklen => 5,
            # titlefont: {color: '#ff7f0e'},
            # tickfont: {color: '#ff7f0e'},
            :anchor => "free", # "free"
            :overlaying => "y",
            :side => "left",
            :position => 0.05,
            :showline => true,
            :zeroline => false,
            :showgrid => false,
        ),
    )
    
    return layout
end

# deprecated

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

function wbhph_trace(;alpha=1, db...)
    trace = scatter(
        mode = "markers",
        marker = Dict(
            :color => "rgba(0,0,0,$alpha)",
            :size => 4,
            :line => Dict(
                :color => "rgb(0,0,0)",
                #:width => 1,
                :width => 0,
            ),
        ),
        yaxis = "y3",
    )

    merge!(trace, db)

    return trace
end

"""
    wopr_trace(;db...)
Custom style for well-oil-production-rate

```julia
wopr_trace(name="ADK-1972", x=xvec, y=yvec)
```
"""
function wopr_trace(; alpha=0.2, db...)
    trace = scatter(
        mode = "lines",
        line = Dict(
            :shape => "vh",
            :color => "rgba(0,128,0,$alpha)",
        ),
    )

    merge!(trace, db)

    return trace
end

function woprh_trace(; alpha=1, db...)
    trace = scatter(
        mode = "markers",
        marker = Dict(
            :color => "rgba(0,128,0,$alpha)",
            :size => 4,
            :line => Dict(
                :color => "rgb(0,128,0)",
                :width => 0,
                #:width => 1,
            ),
        ),
    )

    merge!(trace, db)

    return trace
end

function wopt_trace(; alpha=0.2, db...)
    trace = scatter(
       mode = "lines",
       line = Dict(
           :color => "rgba(0,128,0,$alpha)",
        ),
       yaxis = "y2",
    )

    merge!(trace, db)

    return trace
end

function wopth_trace(; alpha=1, db...)
    trace = scatter(
        mode = "markers",
        marker = Dict(
            :color => "rgba(0,128,0,$alpha)",
            :size => 4,
            :line => Dict(
                :color => "rgb(0,128,0)",
                #:width => 1,
                :width => 0,
            ),
        ),
        yaxis = "y2",
    )

    merge!(trace, db)

    return trace
end

function wwpr_trace(; alpha=0.2, db...)
    trace = scatter(
       mode = "lines",
       line = Dict(
           :shape => "vh",
           :color => "rgba(30,144,255,$alpha)",
        ),
    )

    merge!(trace, db)

    return trace
end

function wwprh_trace(; alpha=1, db...)
    trace = scatter(
        mode = "markers",
        marker = Dict(
            :color => "rgba(30,144,255,$alpha)",
            :size => 4,
            :line => Dict(
                :color => "rgb(30,144,255)",
                #:width => 1,
                :width => 0,
            ),
        ),
    )

    merge!(trace, db)

    return trace
end