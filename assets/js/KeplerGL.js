Vue.component("VueKeplerGl", {
    template: `<div :id="id" style="position: relative; width: 100%; height: 100%"></div>`,
    inheritAttrs: !1,
    props: {
        id: {
            type: String,
            required: !1,
            default: 'keplergl-' + Math.random().toString().substring(2)
        },
        map: {
            type: Object
        },
    },
    data() {
        return {
            app: null,
            store: null
        }
    },
    mounted() {
        let d = this.setupMap(this.id)
        this.app = d.app
        this.store = d.store
        this.loadData(this.map.datasets)
    },
    watch: {
        'map.datasets': {
            handler: function (m) {this.loadData(m)},
            deep: true
        },
        'map.window': { 
            handler: function (newWindow) {
                // Update UI based on changes to map.window
                // For example, update readOnly state
                if (this.app) {
                    this.store.dispatch({
                        type: 'UPDATE_UI_STATE',
                        payload: this.makeUIState()
                    });
                }
            },
            deep: true
        },
        'map.config': {
            handler: function (newConfig) {
                // Update UI based on changes to map.config
                // For example, update visible layers or map legend
                if (this.app) {
                    this.loadData(this.map.datasets);
                }
            },
            deep: true
        }
    },
    methods: {
        makeUIState() {
            m = this.map
            return {
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
        },

        setupMap(id) {
            const m = this.map
            /* Validate Mapbox Token */
            MAPBOX_TOKEN = m.window.token
            // console.log(MAPBOX_TOKEN)
            if ((MAPBOX_TOKEN || '') === '' || MAPBOX_TOKEN === 'PROVIDE_MAPBOX_TOKEN') {
                alert(WARNING_MESSAGE);
            }

            /** STORE **/
            const customReducer = KeplerGl.keplerGlReducer.initialState({
                uiState: this.makeUIState()
            })
            const reducers = Redux.combineReducers({
                // mount KeplerGl reducer
                keplerGl: customReducer
            });

            const composedReducer = (state, action) => {
                switch (action.type) {
                    case 'UPDATE_UI_STATE':
                        return {
                            ...state,
                            keplerGl: {
                                ...state.keplerGl,
                                map: {
                                    ...state.keplerGl.map,
                                    uiState: {...state.keplerGl.map.uiState, ...action.payload}
                                }
                            }
                        }
                }
                return reducers(state, action)
            };

            const middleWares = KeplerGl.enhanceReduxMiddleware([
                // Add other middlewares here
            ]);

            const enhancers = Redux.applyMiddleware(...middleWares);

            const store = Redux.createStore(
                composedReducer,
                {},
                Redux.compose(enhancers)
            );

            // expose store globally for debugging purposes
            window.store = store;
            /** END STORE **/

            /** COMPONENTS **/
            const KeplerElement = function(props) {
                return React.createElement(
                    'div',
                    {style: {position: 'relative', left: 0, width: '100%', height: '100%'}},
                    React.createElement(
                        AutoSizer,
                        {},
                        function({height, width}) {
                            return React.createElement(
                                KeplerGl.KeplerGl,
                                {
                                    mapboxApiAccessToken: MAPBOX_TOKEN,
                                    id: this.id,
                                    width: width,
                                    height: height || '100%'
                                }
                            )
                        }
                    )
                )
            }

            const app = React.createElement(
                ReactRedux.Provider,
                {store},
                React.createElement(KeplerElement, null)
            )
            /** END COMPONENTS **/

            /** Render **/
            ReactDOM.render(app, document.getElementById(id));

            return {app, store}
        },
        loadData(datasets) {
            const newDatasets = [];
            datasets.forEach( (d) => {
                if (d.hasOwnProperty('datasets')) {
                    keplergljson = {
                        datasets: [d],
                        config: this.map.config
                    }
                    processeddata = [KeplerGl.processKeplerglJSON(keplergljson).datasets[0].data]
                } else if (d.hasOwnProperty('csvstring')) {
                    processeddata = [KeplerGl.processCsvData(d.csvstring)]
                } else  if (d.hasOwnProperty('json')) {
                    processeddata = [KeplerGl.processGeojson(d.json)]            
                }

                // match id with old datasets
                newDataset = processeddata.map((d2, i) => ({
                    version: this.map.config.version,
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
        
            const loadedData = KeplerGl.KeplerGlSchema.load(
                newDatasets,
                this.map.config
            );
        
            loadedData['options'] = {centerMap: this.map.window.center_map, readOnly: this.map.window.read_only};
            this.store.dispatch(KeplerGl.addDataToMap(loadedData));
        }
    }
});