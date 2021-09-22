# function Base.merge!(trace::GenericTrace, db)
#     for pair in db # pairs
#         trace[pair[1]] = pair[2]
#     end
# end

# TODO: Use plotly_trace(; label="WBHP")
# function plotly_trace(
#     label;
#     history_alpha = 1.0, model_alpha = 0.3,
#     #history_alpha = 0.3, model_alpha = 1.0,
    
#     history_mode = "lines", model_mode = "lines",
#     #history_mode = "lines", model_mode = "markers",
#     #history_mode = "markers", model_mode = "lines",
#     history_line_width = 3, model_line_width = 2,
#     water_color = "30,144,255", oil_color="0,128,0", bhp_color = "0,0,0",
#     db...
#     )


#     trace = nothing
#     if     "WBHP"  == label
#         trace = scatter(
#             mode = model_mode,
#             line = Dict(
#                 :color => "rgba($bhp_color,$model_alpha)",
#                 :width => model_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($bhp_color,$model_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($bhp_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#             yaxis = "y3",
#         )
#     elseif "WBHPH" == label
#         trace = scatter(
#             mode = history_mode,
#             line = Dict(
#                 :color => "rgba($bhp_color,$history_alpha)",
#                 #:width => history_line_width,
#                 :width => model_line_width, # no need to be thick
#             ),
#             marker = Dict(
#                 :color => "rgba($bhp_color,$history_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($bhp_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#             yaxis = "y3",
#         )                
#     elseif "WOPR"  == label
#         trace = scatter(
#             mode = model_mode,
#             line = Dict(
#                 :shape => "vh",
#                 :color => "rgba($oil_color,$model_alpha)",
#                 :width => model_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($oil_color,$model_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($oil_color)",
#                     :width => 0,
#                     #:width => 1,
#                 ),
#             ),
#         )        
#     elseif "WOPRH" == label
#         trace = scatter(
#             #mode = "markers",
#             mode = history_mode,
#             line = Dict(
#                 :shape => "vh",
#                 :color => "rgba($oil_color,$history_alpha)",
#                 :width => history_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($oil_color,$history_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($oil_color)",
#                     :width => 0,
#                     #:width => 1,
#                 ),
#             ),
#         )
#     elseif "WOPT"  == label
#         trace = scatter(
#             mode = model_mode,
#             line = Dict(
#                 :color => "rgba($oil_color,$model_alpha)",
#                 :width => model_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($oil_color,$model_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($oil_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#             yaxis = "y2",
#          )
#     elseif "WOPTH" == label
#         trace = scatter(
#             mode = history_mode,
#             line = Dict(
#                 :color => "rgba($oil_color,$history_alpha)",
#                 :width => history_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($oil_color,$history_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($oil_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#             yaxis = "y2",
#         )
#     elseif "WWPR"  == label
#         trace = scatter(
#             mode = model_mode,
#             line = Dict(
#                 :shape => "vh",
#                 :color => "rgba($water_color,$model_alpha)",
#                 :width => model_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($water_color,$model_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($water_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#         )        
#     elseif "WWPRH" == label
#         trace = scatter(
#             mode = history_mode,
#             line = Dict(
#                 :color => "rgba($water_color,$history_alpha)",
#                 :width => history_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($water_color,$history_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($water_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#         )        
#     elseif "WWPT"  == label
#         trace = scatter(
#             mode = model_mode,
#             line = Dict(
#                 :color => "rgba($water_color,$model_alpha)",
#                 :width => model_line_width,
#              ),
#             marker = Dict(
#                 :color => "rgba($water_color,$model_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($water_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#             yaxis = "y2",
#         )
#     elseif "WWPTH"  == label
#         trace = scatter(
#             mode = history_mode,
#             line = Dict(
#                 :color => "rgba($water_color,$history_alpha)",
#                 :width => history_line_width,
#             ),
#             marker = Dict(
#                 :color => "rgba($water_color,$history_alpha)",
#                 :size => 4,
#                 :line => Dict(
#                     :color => "rgb($water_color)",
#                     #:width => 1,
#                     :width => 0,
#                 ),
#             ),
#             yaxis = "y2",
#         )        
#     else
#         throw(ErrorException("Unknown label: $label"))
#     end

#     for pair in db # pairs
#         trace[pair[1]] = pair[2]
#     end

#     return trace
# end

function plotly_trace(
    ;
    label = "WBHP",
    history_alpha = 1.0, model_alpha = 0.3,
    #history_alpha = 0.3, model_alpha = 1.0,
    
    history_mode = "lines", model_mode = "lines",
    #history_mode = "lines", model_mode = "markers",
    #history_mode = "markers", model_mode = "lines",
    history_line_width = 3, model_line_width = 2,
    water_color = "30,144,255", oil_color="0,128,0", bhp_color = "0,0,0",
    db...
    )


    trace = nothing
    if     "WBHP"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :color => "rgba($bhp_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($bhp_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($bhp_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y3",
        )
    elseif "WBHPH" == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :color => "rgba($bhp_color,$history_alpha)",
                #:width => history_line_width,
                :width => model_line_width, # no need to be thick
            ),
            marker = Dict(
                :color => "rgba($bhp_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($bhp_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y3",
        )                
    elseif "WOPR"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :shape => "vh",
                :color => "rgba($oil_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    :width => 0,
                    #:width => 1,
                ),
            ),
        )        
    elseif "WOPRH" == label
        trace = scatter(
            #mode = "markers",
            mode = history_mode,
            line = Dict(
                :shape => "vh",
                :color => "rgba($oil_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    :width => 0,
                    #:width => 1,
                ),
            ),
        )
        if "markers" == history_mode
            trace[:marker][:color] = "rgba(255,255,255,0)"
            trace[:marker][:size]  = 8
            trace[:marker][:line][:color] = "rgba($oil_color, $history_alpha)"
            trace[:marker][:line][:width] = 1
        elseif "lines" == history_mode
        end   
    elseif "WOPT"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :color => "rgba($oil_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y2",
         )
    elseif "WOPTH" == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :color => "rgba($oil_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y2",
        )
    elseif "WWPR"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :shape => "vh",
                :color => "rgba($water_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($water_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($water_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )        
    elseif "WWPRH" == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :shape => "vh",
                :color => "rgba($water_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($water_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgba($water_color, $history_alpha)",
                    :width => 0,
                ),
            ),
        )
        if "markers" == history_mode
            trace[:marker][:color] = "rgba(255,255,255,0)"
            trace[:marker][:size]  = 8
            trace[:marker][:line][:color] = "rgba($water_color, $history_alpha)"
            trace[:marker][:line][:width] = 1
        elseif "lines" == history_mode
        end   
    elseif "WWPT"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :color => "rgba($water_color,$model_alpha)",
                :width => model_line_width,
             ),
            marker = Dict(
                :color => "rgba($water_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($water_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y2",
        )
    elseif "WWPTH"  == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :color => "rgba($water_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($water_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($water_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
            yaxis = "y2",
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
            :domain => [0.10, 0.90],
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
            # :title => Dict(
            #     :text => "Liquid Flowrate [STB/d]",
            #     :font => Dict(
            #       :size => 20,
            #     ),
            # ),
            #:range => [0, 35],
            :domain => [0.05, 0.95], # so html does not cut off at the bottom
            :showline => true,
            :ticklen => 5,
            :rangemode => "tozero",
            
        ),
        yaxis2 = Dict(
            :title => "Liquid Production Volume [STB]",
            # :title => Dict(
            #     :text => "Liquid Production Volume [STB]",
            #     :font => Dict(
            #       :size => 20,
            #     ),
            # ),
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
            # :title => Dict(
            #     :text => "Pressure [psi]",
            #     :font => Dict(
            #       :size => 20,
            #     ),
            # ),
            #:range => [0, 11000],
            :rangemode => "tozero",
            :ticklen => 5,
            :tickformat => ",",
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
        yaxis4 = Dict(
            # :title => Dict(
            #     :text => "Pressure [psi]",
            #     :font => Dict(
            #       :size => 20,
            #     ),
            # ),
            #:range => [0, 11000],
            :rangemode => "tozero",
            :ticklen => 5,
            :tickformat => ",",
            # titlefont: {color: '#ff7f0e'},
            # tickfont: {color: '#ff7f0e'},
            :anchor => "free", # "free"
            :overlaying => "y",
            :side => "left",
            :position => 1.0,
            :showline => true,
            :zeroline => false,
            :showgrid => false,
        ),
    )
    
    return layout
end

# Not used
function subplot_trace(; label="WBHP",
    history_alpha = 1.0, model_alpha = 0.3,
    history_mode = "lines", model_mode = "lines",
    #history_mode = "lines", model_mode = "markers",
    #history_mode = "markers", model_mode = "lines",
    history_line_width = 3, model_line_width = 2,
    water_color = "30,144,255", oil_color="0,128,0", bhp_color = "0,0,0",
    db...)
    trace = nothing
    if     "WBHP"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :color => "rgba($bhp_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($bhp_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($bhp_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )
    elseif "WBHPH" == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :color => "rgba($bhp_color,$history_alpha)",
                #:width => history_line_width,
                :width => model_line_width, # no need to be thick
            ),
            marker = Dict(
                :color => "rgba($bhp_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($bhp_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )                
    elseif "WOPR"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :shape => "vh",
                :color => "rgba($oil_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    :width => 0,
                    #:width => 1,
                ),
            ),
        )        
    elseif "WOPRH" == label
        trace = scatter(
            #mode = "markers",
            mode = history_mode,
            line = Dict(
                :shape => "vh",
                :color => "rgba($oil_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    :width => 0,
                    #:width => 1,
                ),
            ),
        )
    elseif "WOPT"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :color => "rgba($oil_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
         )
    elseif "WOPTH" == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :color => "rgba($oil_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($oil_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($oil_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )
    elseif "WWPR"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :shape => "vh",
                :color => "rgba($water_color,$model_alpha)",
                :width => model_line_width,
            ),
            marker = Dict(
                :color => "rgba($water_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($water_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )        
    elseif "WWPRH" == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :color => "rgba($water_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($water_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($water_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )        
    elseif "WWPT"  == label
        trace = scatter(
            mode = model_mode,
            line = Dict(
                :color => "rgba($water_color,$model_alpha)",
                :width => model_line_width,
             ),
            marker = Dict(
                :color => "rgba($water_color,$model_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($water_color)",
                    #:width => 1,
                    :width => 0,
                ),
            ),
        )
    elseif "WWPTH"  == label
        trace = scatter(
            mode = history_mode,
            line = Dict(
                :color => "rgba($water_color,$history_alpha)",
                :width => history_line_width,
            ),
            marker = Dict(
                :color => "rgba($water_color,$history_alpha)",
                :size => 4,
                :line => Dict(
                    :color => "rgb($water_color)",
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