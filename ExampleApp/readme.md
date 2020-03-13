#  Ada Support Example App

This app provides an example implementation of the Ada Embed Framework. Please refer to `ViewController.swift` in this app for steps for implementing the Ada chat UI in three different contexts:

* Pushing on an instance of `UINavigationController`
* Presenting over an instance of `UIViewController`
* Embedding into a `UIView`

Implementing the UI is as simple as creating an instance of `AdaWebHost`, passing in the following properties:

* The `handle` (required). This is the name of your Ada instance.
* Optional, `openWebLinksInSafari`, a boolean value that will force web links that appear in the chat in Safari. Set to `false` to have links open in an in-app browser.
* Optional, `appScheme`, a string representing the app scheme for your hosting app, if you wish to support deep links that appear in your chat. 

### Supporting Deep Links
If you wish to provide your users with links to particular locations in your app, you can implement deep link support in your app. To configure your app, you can [follow these directions](https://www.donnywals.com/handling-deeplinks-in-your-app/). This example app has been configured to support the custom app scheme: `adaexampleapp://`. 

