Vue.component("VueKeplerGl", {
    template: '<div id="id1"></div>',
    inheritAttrs: !1,
    props: {
        id: {
            type: String,
            required: !1,
            default: 'kepler-gl'
        },
        map: {
            type: Object
        },
    },
    data() {
        return {
            
        }
    },
    mounted() {
        this.replot(this.map)
    },
    methods: {
        make_initial_state(m) {
            return KeplerGl.keplerGlReducer.initialState({
                uiState: {
                    readOnly: m.window.read_only,
                    activeSidePanel: null, 
                    currentModal: null,
                    mapControls: {
                        visibleLayers: {
                            show: m.window.visible_layers_show,
                            active: m.window.visible_layers_active
                        },
                        mapLegend: {
                            show: m.window.map_legend_show,
                            active: m.window.map_legend_active
                        },
                        toggle3d: {
                            show: m.window.toggle_3d_show,
                            active: m.window.toggle_3d_active
                        },
                        splitMap: {
                            show: m.window.split_map_show,
                            active: m.window.split_map_active
                        }
                    }
                }
            })
        },
        replot(m) {
            /* Validate Mapbox Token */
            MAPBOX_TOKEN = m.window.token
            console.log(MAPBOX_TOKEN)
            if ((MAPBOX_TOKEN || '') === '' || MAPBOX_TOKEN === 'PROVIDE_MAPBOX_TOKEN') {
            alert(WARNING_MESSAGE);
            }

            /** STORE **/
            state = this.make_initial_state(m)
            const reducers = (function createReducers(Redux, KeplerGl) {
            return Redux.combineReducers({
                // mount KeplerGl reducer
                keplerGl: state
            });
            }(Redux, KeplerGl));

            const middleWares = (function createMiddlewares(KeplerGl) {
            return KeplerGl.enhanceReduxMiddleware([
                // Add other middlewares here
            ]);
            }(KeplerGl));

            const enhancers = (function createEnhancers(Redux, middles) {
            return Redux.applyMiddleware(...middles);
            }(Redux, middleWares));

            const store = (function createStore(Redux, enhancers) {
            const initialState = {};

            return Redux.createStore(
                reducers,
                initialState,
                Redux.compose(enhancers)
            );
            }(Redux, enhancers));
            // expose store globally:
            window.store = store;
            /** END STORE **/

            /** COMPONENTS **/
            const KeplerElement = (function (react, KeplerGl, mapboxToken) {
                return function(props) {
                    return react.createElement(
                    'div',
                    {style: {position: 'relative', left: 0, width: '100%', height: '100%'}},
                    react.createElement(
                        KeplerGl.KeplerGl,
                        {
                            mapboxApiAccessToken: mapboxToken,
                            id: this.id,
                            width: props.width || m.window.width,
                            height: props.height || m.window.height
                        }
                    )
                    )
                }
            }(React, KeplerGl, MAPBOX_TOKEN));

            const app = (function createReactReduxProvider(react, ReactRedux, KeplerElement) {
                return react.createElement(
                    ReactRedux.Provider,
                    {store},
                    react.createElement(KeplerElement, null)
                )
            }(React, ReactRedux, KeplerElement));
            /** END COMPONENTS **/

            /** Render **/
            (function render(react, ReactDOM, app) {
            ReactDOM.render(app, document.getElementById('id1'));
            }(React, ReactDOM, app));

            const newDatasets = [];
            m.datasets.forEach( (d) => {
                if (d.hasOwnProperty('datasets')) {
                    keplergljson = {
                        datasets: [d],
                        config: m.config
                    }
                    processeddata = [KeplerGl.processKeplerglJSON(keplergljson).datasets[0].data]
                } else if (d.hasOwnProperty('csvstring')) {
                    processeddata = [KeplerGl.processCsvData(d.csvstring)]
                } else  if (d.hasOwnProperty('json')) {
                    processeddata = [KeplerGl.processGeojson(d.json)]            
                }

                // for debugging

                // match id with old datasets
                newDataset = processeddata.map((d2, i) => ({
                version: m.config.version,
                data: {
                    id: d.id,
                    label: d.id,
                    allData: d2.rows,
                    fields: d2.fields
                }
                }));

                newDatasets.push(newDataset[0]);
                
                // for debugging
                // console.log(newDataset)
            })
        
            // const config = m.config
        
            const loadedData = KeplerGl.KeplerGlSchema.load(
                newDatasets,
                m.config
            );
        
            loadedData['options'] = {centerMap: m.window.center_map, readOnly: m.window.read_only};
            store.dispatch(KeplerGl.addDataToMap(loadedData));
        }
    }
});