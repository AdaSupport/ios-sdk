# Ada iOS SDK Cocoapod Example App

To test out code changes with the Example app using a Cocoapod you may use this app on its own by following these steps:

1. Using your terminal - make sure you install/update the existing version of the `AdaEmbedFramework` you have installed.
    - If you haven't installed `AdaEmbedFramework` before: just run `pod install` in the `ExampleAppCocoapod` directory.
    - If you have installed `AdaEmbedFramework` before: in the `ExampleAppCocoapod` directory delete the Pods folder, delete Podfile.lock and run `pod install --repo-update`

2. Double click `ExampleAppCocoapod.xcworkspace` to open the project in xcode in standalone (you will need to do this as there are specific build steps created by Cocoapod to compile this app). Do not use `ExampleAppCocoapod.xcodeproj`.

3. Click `Run` in xcode to run the app and happy testing!

Notes:
- If you open up the root project in xcode - you won't be able to run this example app as it needs build steps from the `ExampleAppCocoapod.xcworkspace`.