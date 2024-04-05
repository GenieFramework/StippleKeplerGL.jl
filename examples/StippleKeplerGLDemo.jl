using Stipple, Stipple.ReactiveTools
using StippleKeplerGL
using DataFrames
using CSV
using Colors
using ColorBrewer

keplergl_path = dirname(dirname(pathof(KeplerGL)))
df = CSV.read("$keplergl_path/assets/example_data/data.csv", DataFrame)

token = "token please"   

m = KeplerGL.KeplerGLMap(token, center_map=false)

KeplerGL.add_point_layer!(m, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("PRGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false
)

m.config[:config][:mapState][:latitude] = 38.32068477880718
m.config[:config][:mapState][:longitude]= -120.42806781055732
m.config[:config][:mapState][:zoom] = 4.886825331541375
m.window[:map_legend_show] = m.window[:map_legend_active] = m.window[:visible_layers_show] = m.window[:visible_layers_active] = false

@app begin
    @out map = m
end

@deps StippleKeplerGL

ui() = [
    h1("KeplerGL Demo", style = "padding-bottom: 0.5em")
    keplergl(:map)
]

@page("/", ui)

up(open_browser = true)