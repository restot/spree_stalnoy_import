Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :admin, path: Spree.admin_path do
    resources :yml_codes
    resources :stalnoy_imports
    get '/stalnoy_import_test', to: 'stalnoy_imports#test'
    get '/stalnoy_import_rules', to: 'stalnoy_imports#rules'
    get '/stalnoy_import_upload', to: 'stalnoy_imports#upload'
    get '/stalnoy_import_cols/:id', to: 'stalnoy_imports#cols', as: 'vcols'
    get '/stalnoy_import_rows/:id', to: 'stalnoy_imports#rows', as: 'vrows'
    match  '/stalnoy_import_setcols/:id', to: 'stalnoy_imports#setcols', as: 'setcols', via: [ :put, :pach]
    match  '/stalnoy_import_setrows/:id', to: 'stalnoy_imports#setrows', as: 'setrows', via: [ :put, :pach]
    get '/stalnoy_import_test_stream', to: 'stalnoy_imports#test_stream'
    get '/stalnoy_import_stream/:id', to: 'stalnoy_imports#stream', as: 'streamid'
    get '/stalnoy_import_hide_all', to: 'stalnoy_imports#hide_all'

    get '/yml_code/:id', to: 'yml_codes#start', as: 'priceid'

  end
end
