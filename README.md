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


More details coming soon.
