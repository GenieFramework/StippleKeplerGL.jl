using Stipple, Stipple.ReactiveTools
using StippleKeplerGL
using DataFrames
using CSV
using Colors
using ColorBrewer
using Test

keplergl_path = Base.pkgdir(KeplerGLBase)
df = CSV.read(joinpath(keplergl_path, "assets", "example_data", "data.csv"), DataFrame)

token = "mapbox_key"
m1 = KeplerGLMap(token, center_map=false)

add_point_layer!(m1, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("PRGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false
)

m1.config[:config][:mapState][:latitude] = 38.32068477880718
m1.config[:config][:mapState][:longitude]= -120.42806781055732
m1.config[:config][:mapState][:zoom] = 4.886825331541375
m1.window[:map_legend_show] = m1.window[:map_legend_active] = m1.window[:visible_layers_show] = m1.window[:visible_layers_active] = false


@deps StippleKeplerGL
isdefined(Stipple, :register_global_components) && Stipple.register_global_components("VueKeplerGl", legacy = true)

@test keplergl(col = 2, :map1, ref = "map_ref", id = "map1") == "<vue-kepler-gl :map=\"map1\" id=\"map1\" class=\"col-2\" ref=\"map_ref\"></vue-kepler-gl>"
