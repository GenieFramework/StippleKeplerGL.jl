using Stipple, Stipple.ReactiveTools
using StippleUI
using KeplerGL
using DataFrames
using CSV
using Colors
using ColorBrewer

df = CSV.read(joinpath(Base.pkgdir(KeplerGL), "assets", "example_data", "data.csv"), DataFrame)

token = "token please"

m = KeplerGL.KeplerGLMap(token, center_map=false)
KeplerGL.add_point_layer!(m, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize",
    color_range = ColorBrewer.palette("PRGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false);

m.config[:config][:mapState][:latitude] = 38.32068477880718
m.config[:config][:mapState][:longitude]= -120.42806781055732
m.config[:config][:mapState][:zoom] = 4.886825331541375
m.window[:map_legend_show] = false
m.window[:map_legend_active] = false
m.window[:visible_layers_show] = false
m.window[:visible_layers_active] = false

@app HH begin
    @out map = m
end

keplergl_assets_config = Genie.Assets.AssetsConfig(package = "KeplerGL.jl")
assets_config = Genie.Assets.AssetsConfig(package = "StippleKeplerGL.jl")

basedir = Base.pkgdir(KeplerGL)
deps_routes = String[]
for js in [
    "react.production.min.js", "react-dom.production.min.js",
    "redux.js", "react-redux.min.js",
    "styled-components.min.js", "keplergl.min.js",
  ]
  s = script(src = Genie.Assets.add_fileroute(keplergl_assets_config, js; basedir).path)
  push!(deps_routes, s)
end

basedir = joinpath(Base.homedir(), ".julia", "dev", "StippleKeplerGL")
s = script(src = Genie.Assets.add_fileroute(assets_config, "KeplerGL.js"; basedir).path)
push!(deps_routes, s)

kepler_deps() = deps_routes

@deps HH kepler_deps

ui() = [
    h1("Hello World")
    xelem(R"kepler-gl", map = :map)
]

route("/") do
    global model
    model = @init HH
    page(model, ui) |> html
end

up(open_browser = true)
