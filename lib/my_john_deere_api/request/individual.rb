module MyJohnDeereApi::Request::Individual
  autoload :Base,                     'my_john_deere_api/request/individual/base'
  autoload :Asset,                    'my_john_deere_api/request/individual/asset'
  autoload :ContributionProduct,      'my_john_deere_api/request/individual/contribution_product'
  autoload :ContributionDefinition,   'my_john_deere_api/request/individual/contribution_definition'
  autoload :Field,                    'my_john_deere_api/request/individual/field'
  autoload :Organization,             'my_john_deere_api/request/individual/organization'
end