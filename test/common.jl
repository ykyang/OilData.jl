using Logging

global_logger(ConsoleLogger(stdout, Logging.Info))

"""

Checkout `oil_data` and place it in one of the locations as shown below.
"""
function data_dir()
    
    #@info "pwd(): $(pwd())"
    # if basename(path) == "OilData"
    #     path = joinpath(path, "test")
    # end
    name = "oil_data"

    path = joinpath(pwd(), name)
    if isdir(path)
        return abspath(path)
    end

    path = joinpath(pwd(), "test", name)
    if isdir(path)
        return abspath(path)
    end

    path = joinpath(pwd(), "..", name)
    if isdir(path)
        return abspath(path)
    end

    path = joinpath(pwd(), "..", "..", name)
    if isdir(path)
        return abspath(path)
    end

    path = joinpath(pwd(), "..", "..", "..", name)
    if isdir(path)
        return abspath(path)
    end
    
    path = joinpath(pwd(), "..", "..", "..", "..", name)
    if isdir(path)
        return abspath(path)
    end

    path = joinpath(pwd(), "..", "..", "..", "..", "..", name)
    if isdir(path)
        return abspath(path)
    end

    #@warn "Data directory not found: $name"

    return nothing
    # throw(
    #     ErrorException("No data/ found")
    # )
end

# Check if `oil_data` is available
if isnothing(data_dir())
    @warn "Data directory not found"
    @warn "Some tests will be skipped"
else
    @info "Found data directory: $(data_dir())"
end