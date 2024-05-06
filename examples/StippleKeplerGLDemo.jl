using Stipple, Stipple.ReactiveTools
using StippleUI
using StippleKeplerGL
using DataFrames
using CSV
using Colors
using ColorBrewer

keplergl_path = Base.pkgdir(isdefined(@__MODULE__, :KeplerGLBase) ? KeplerGLBase : KeplerGL)
df = CSV.read(joinpath(keplergl_path, "assets", "example_data", "data.csv"), DataFrame)

# token = "token please"

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

m2 = KeplerGLMap(token, center_map=false)

add_point_layer!(m2, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("RdYlGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false
)

m2.config[:config][:mapState][:latitude] = 38.32068477880718
m2.config[:config][:mapState][:longitude]= -122.42806781055732
m2.config[:config][:mapState][:zoom] = 4.886825331541375
m2.window[:map_legend_show] = m2.window[:map_legend_active] = m2.window[:visible_layers_show] = m2.window[:visible_layers_active] = false

d1, d2 = m1.datasets, m2.datasets;

@app begin
    @out map1 = m1
    @out map2 = m2
    @in clear_data = false
    @in restore_data = false
    @in show_legend = false
    @in go_west = false
    @in go_east = false

    @onbutton clear_data begin
        __model__["map1.datasets"] = []
        __model__["map2.datasets"] = []
    end

    @onbutton restore_data begin
        __model__["map1.datasets"] = d1
        __model__["map2.datasets"] = d2
    end

    @onbutton go_west begin
        map1.config[:config][:mapState][:longitude] -= 1
        __model__["map1.config.config.mapState.longitude"] = map1.config[:config][:mapState][:longitude]

        map2.config[:config][:mapState][:longitude] -= 1
        __model__["map2.config.config.mapState.longitude"] = map2.config[:config][:mapState][:longitude]
    end

    @onbutton go_east begin
        map1.config[:config][:mapState][:longitude] += 1
        __model__["map1.config.config.mapState.longitude"] = map1.config[:config][:mapState][:longitude]

        map2.config[:config][:mapState][:longitude] += 1
        __model__["map2.config.config.mapState.longitude"] = map2.config[:config][:mapState][:longitude]
    end

    @onchange show_legend begin
        __model__["map1.window.map_legend_show"] = show_legend
        __model__["map2.window.map_legend_show"] = show_legend

        # alternatively, one could use the following lines to show the legend via the backend
        # but this will transmit the full map data to the frontend

        # map1.window[:map_legend_show] = show_legend
        # notify(map1)
    end
end

@deps StippleKeplerGL
isdefined(Stipple, :register_global_components) && Stipple.register_global_components("VueKeplerGl", legacy = true)

ui() = [
    column(class = "full-height", [
        row(col = :auto, class = "items-center", [
            h5(class = "col-auto q-pl-lg q-py-md", "KeplerGL Demo")
            cell()
            btn(col = :auto, "", icon = "west", @click(:go_west), class = "q-mr-md", [tooltip("go west")])
            btn(col = :auto, "", icon = "east", @click(:go_east), class = "q-mr-md", [tooltip("go east")])
            btn(col = :auto, "", icon = "delete", @click(:clear_data), class = "q-mr-md", [tooltip("clear data")])
            btn(col = :auto, "", icon = "restore_from_trash", @click(:restore_data), class = "q-mr-md", [tooltip("restore data")])
            toggle(col = :auto, "legend", :show_legend, class = "q-mr-md")
        ])
        
        cell(keplergl(:map1, ref = "map1", id = "map1"))
        cell(keplergl(:map2, ref = "map2"))
    ])
]

route("/") do
    # uncomment next line for testing / debugging
    global model
    model = @init
    page(class = "fixed-full", model, ui) |> html
end

up(open_browser = true)