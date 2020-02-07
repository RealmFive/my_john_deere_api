# my\_john\_deer\_api

[![CircleCI](https://circleci.com/gh/Intellifarm/my_john_deere_api.svg?style=svg)](https://circleci.com/gh/Intellifarm/my_john_deere_api)

This client allows you to connect the MyJohnDeere API without having to code your own oauth process, API requests, and pagination. 

* Supports both sandbox and live mode
* Simplifies the oAuth negotiation process
* Uses ruby enumerables to handle pagination behind the scenes. Calls like `each`, `map`, etc will fetch new pages of data as needed.

## Documentation

We provide RDoc documentation, but here is a helpful guide for getting started. Because the gem name is long, all examples are going
to assume this shortcut:

    JD = MyJohnDeereApi

So that when you see:

    JD::Authorize

It really means:

    MyJohnDeereApi::Authorize


### Authorizing with John Deere via Auth 1.0

This is the simplest path to authorization, though your user has to jump through an extra hoop of giving you the verification code:
  
    # Create an authorize object, using your app's API key and secret. You can
    # pass an environment (`:live` or `:sandbox`), which default to `:live`.
    authorize = JD::Authorize.new(API_KEY, API_SECRET, environment: :sandbox)
    
    # Retrieve a valid authorization url from John Deere, where you can send 
    # your user for authorizing your app to the JD platform.
    url = authorize.authorize_url
    
    # Verify the code given to the user during the authorization process, and
    # turn this into access credentials for your user.
    authorize.verify(code)    

In reality, you will likely need to re-instantiate the authorize object when the user returns, and that works without issue:

    # Create an authorize object, using your app's API key and secret.
    authorize = JD::Authorize.new(API_KEY, API_SECRET, environment: :sandbox)
    
    # Retrieve a valid authorization url from John Deere.
    url = authorize.authorize_url
    
    # Queue elevator music while your app serves other users...
    
    # Re-create the authorize instance in a different process
    authorize = JD::Authorize.new(API_KEY, API_SECRET, environment: :sandbox)
    
    # Proceed as normal
    authorize.verify(code)

In a web app, you're prefer that your user doesn't have to copy/paste verification codes. So you can pass in an :oauth_callback url.
When the user authorizes your app with John Deere, they are redirected to the url you provide, with the paraameter 'oauth_verifier'
that contains the verification code so the user doesn't have to provide it.

    # Create an authorize object, using your app's API key and secret.
    authorize = JD::Authorize.new(
      API_KEY, 
      API_SECRET, 
      environment: :sandbox,
      oauth_callback: 'https://example.com'
    )
    
    # Retrieve a valid authorization url from John Deere.
    # This will contain the callback url encoded into the
    # query string for you.
    url = authorize.authorize_url
    
    # Queue elevator music while your app serves other users...
    
    # Re-create the authorize instance in a different process.
    # It's not necessary to re-initialize with the callback url.
    authorize = JD::Authorize.new(API_KEY, API_SECRET, environment: :sandbox)
    
    # Inside a Rails controller, you might do this:
    authorize.verify(params[:oauth_verifier])


### Interacting with the user's John Deere account

After authorization is complete, the `Client` object will provide most of the interface for this library. A client can
be used with or without user credentials, because some API calls are specific to your application's relationship
with John Deere, not your user's. But most interactions will involve user data. Here's how to instantiate a client:

    client = JD::Client.new(
      # the application's API key
      API_KEY,
      
      # the application's API secret
      API_SECRET,
      
      # the chosen environment (:sandbox or :live)
      environment: :sandbox,
      
      # the user's access credentials
      access: [ACCESS_TOKEN, ACCESS_SECRET]
    )


### Direct API Requests

While the goal of the client is to eliminate the need to make/interpret calls to the John Deere API, it's important
to be able to make calls that are not yet fully supported by the client. Or sometimes, you need to troubleshoot.


#### GET


GET requests require only a resource path.

    client.get('/organizations')
    
    # Abbreviated sample response:
    {
      "links": [...],
      "total": 1,
      "values": [
        {
          "@type": "Organization",
          "name": "ABC Farms",
          "type": "customer",
          "member": true,
          "id": "123123",
          "links": [...]
        },
      ]
    }

This won't provide any client goodies like pagination or validation, but it does parse the returned JSON.


#### POST

POST requests require a resource path, and a hash for the request body. The client will camelize the keys, and convert to JSON.

    client.post(
     '/organizations/123123/assets',
     {
       "title"=>"i like turtles", 
       "assetCategory"=>"DEVICE", 
       "assetType"=>"SENSOR", 
       "assetSubType"=>"ENVIRONMENTAL", 
       "links"=>[
         {
           "@type"=>"Link", 
           "rel"=>"contributionDefinition", 
           "uri"=>"https://sandboxapi.deere.com/platform/contributionDefinitions/CONTRIBUTION_DEFINITION_ID"
         }
        ]
      }
    )

John Deere's standard response is a 201 HTTP status code, with the message "Created". This method returns the full Net::HTTP response.


#### PUT

PUT requests require a resource path, and a hash for the request body. The client will camelize the keys, and convert to JSON.

    client.put(
     '/assets/123123',
     {
       "title"=>"i REALLY like turtles", 
       "assetCategory"=>"DEVICE", 
       "assetType"=>"SENSOR", 
       "assetSubType"=>"ENVIRONMENTAL", 
       "links"=>[
         {
           "@type"=>"Link", 
           "rel"=>"contributionDefinition", 
           "uri"=>"https://sandboxapi.deere.com/platform/contributionDefinitions/CONTRIBUTION_DEFINITION_ID"
         }
        ]
      }
    )

John Deere's standard response is a 204 HTTP status code, with the message "No Content". This method returns the full Net::HTTP response.


#### DELETE

DELETE requests require only a resource path.

    client.delete('/assets/123123')

John Deere's standard response is a 204 HTTP status code, with the message "No Content". This method returns the full Net::HTTP response.


More details coming soon.
