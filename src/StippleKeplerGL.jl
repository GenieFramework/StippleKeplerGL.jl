module StippleKeplerGL

using Stipple
using Reexport

@reexport using KeplerGL

export keplergl

keplergl_assets_config = Genie.Assets.AssetsConfig(package = "KeplerGLBase.jl")
assets_config = Genie.Assets.AssetsConfig(package = "StippleKeplerGL.jl")

const deps_routes = String[]
deps() = deps_routes

import Stipple.Genie.Renderer.Html: register_normal_element, normal_element

register_normal_element("vue__kepler__gl", context = @__MODULE__)

function keplergl(map::Union{Symbol,Nothing}, args...;
    col::Union{Int,AbstractString,Symbol,Nothing} = -1,
    xs::Union{Int,AbstractString,Symbol,Nothing} = -1, sm::Union{Int,AbstractString,Symbol,Nothing} = -1, md::Union{Int,AbstractString,Symbol,Nothing} = -1,
    lg::Union{Int,AbstractString,Symbol,Nothing} = -1, xl::Union{Int,AbstractString,Symbol,Nothing} = -1, size::Union{Int,AbstractString,Symbol,Nothing} = -1,
    class = "", kwargs...)
    
    kwargs = Stipple.attributes(Stipple.flexgrid_kwargs(; map, class, col, xs, sm, md, lg, xl, symbol_class = false, kwargs...))
  
    vue__kepler__gl(args...; kwargs...)
end

function __init__()
    basedir = dirname(dirname(pathof(KeplerGLBase)))
    for js in [
        "react.production.min.js", "react-dom.production.min.js",
        "redux.js", "react-redux.min.js",
        "styled-components.min.js", "keplergl.min.js",
    ]
        s = script(src = Genie.Assets.add_fileroute(keplergl_assets_config, js; basedir).path)
        push!(deps_routes, s)
    end

    basedir = dirname(@__DIR__)
    s = script(src = Genie.Assets.add_fileroute(assets_config, "KeplerGL.js"; basedir).path)
    push!(deps_routes, s)
end

end