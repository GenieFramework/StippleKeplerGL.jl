using Stipple, Stipple.ReactiveTools
using StippleUI
using StippleKeplerGL
using DataFrames
using CSV
using Colors
using ColorBrewer

keplergl_path = dirname(dirname(pathof(isdefined(@__MODULE__, :KeplerGLBase) ? KeplerGLBase : KeplerGL)))
df = CSV.read("$keplergl_path/assets/example_data/data.csv", DataFrame)

token = "token please"   

m1 = KeplerGL.KeplerGLMap(token, center_map=false)

KeplerGL.add_point_layer!(m1, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("PRGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false
)

m1.config[:config][:mapState][:latitude] = 38.32068477880718
m1.config[:config][:mapState][:longitude]= -120.42806781055732
m1.config[:config][:mapState][:zoom] = 4.886825331541375
m1.window[:map_legend_show] = m1.window[:map_legend_active] = m1.window[:visible_layers_show] = m1.window[:visible_layers_active] = false

m2 = KeplerGL.KeplerGLMap(token, center_map=false)

KeplerGL.add_point_layer!(m2, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("RdYlGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false
)

m2.config[:config][:mapState][:latitude] = 38.32068477880718
m2.config[:config][:mapState][:longitude]= -122.42806781055732
m2.config[:config][:mapState][:zoom] = 4.886825331541375
m2.window[:map_legend_show] = m2.window[:map_legend_active] = m2.window[:visible_layers_show] = m2.window[:visible_layers_active] = false

@app begin
    @out map1 = m1
    @out map2 = m2
end

@deps StippleKeplerGL
Stipple.register_global_components("VueKeplerGl", legacy = true)

ui() = [
    column(class = "full-height", [
        h5(class = "col-auto q-pl-lg q-pt-md", "KeplerGL Demo", style = "padding-bottom: 0.5em")
        cell(keplergl(:map1, ref = "map1", id = "map1"))
        cell(keplergl(:map2, ref = "map2"))
    ])
]

route("/") do
    # global model
    model = @init
    page(class = "fixed-full", model, ui) |> html
end

up(open_browser = true)