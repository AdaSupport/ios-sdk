# Ada iOS SDK Cocoapod Example App

1. Using your terminal - make sure you install/update the existing version of the `AdaEmbedFramework` you have installed.
    - If you want to use a local version of `EmbedFramework` you can first change the Cartfile to `git "file://<absolute_path_to_ios-sdk_repo>" "<branch_name"`
    - Then to install dependencies, run `carthage update --platform iOS --use-xcframeworks` in this directory.

2. Open the `ios-sdk` directory in xcode
    - You'll need to add the framework to Xcode by going to the `ExampleAppCarthage` project in the project navigator, go to `ExampleAppCarthage` in `targets` and drag/drop `Carthage/Build/AdaEmbedFramework.xcframework` into the `Frameworks, Libraries and Embedded Content` section

3. Switch to the `ExampleAppCarthage` in xcode (top middle bar next to the simulator you chose) to run the app and happy testing!