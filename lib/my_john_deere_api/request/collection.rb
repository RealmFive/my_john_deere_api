module MyJohnDeereApi::Request::Collection
  autoload :Base,                 'my_john_deere_api/request/collection/base'
  autoload :Assets,               'my_john_deere_api/request/collection/assets'
  autoload :AssetLocations,       'my_john_deere_api/request/collection/asset_locations'
  autoload :Organizations,        'my_john_deere_api/request/collection/organizations'
  autoload :Fields,               'my_john_deere_api/request/collection/fields'
  autoload :Flags,                'my_john_deere_api/request/collection/flags'
end