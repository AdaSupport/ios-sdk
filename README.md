# EmbedFramework
Our framework for supporting Ada Chat inside native iOS applications.

## Usage
Refer to client-facing docs [here](https://github.com/AdaSupport/docs/blob/master/ada-ios-sdk.md).

## Distribution
Changes to the EmbedFramework must be made available for manual and Cocoapod integration. Otherwise, your changes are not accessible to anyone! Steps for distributing both are outlined below.

### Manual Integration
For manual integration, the link to the zipped framework in the docs simply needs to be updated. To create the zipped framework, open EmbedFramework in XCode and go to `Products > AdaEmbedFramework.framework`. Right click and press "Show in Finder". Copy the file and compress to zip. 

Next, attach this as a binary to the corresponding release note. Copy the link and update in the docs [here](https://github.com/AdaSupport/docs/blob/master/ada-ios-sdk.md#option-1-manual-integration).

### Cocoapods
To create a new version of the Cocoapoad, first update the pod version in the `.podspec` file. (Be sure to follow [SemVer](https://semver.org/)!) Next, commit and push your changes to Github.

Tag the code on Github by running the following command on the EmbedFramework repo from the terminal.

```
git tag 1.2.3 // Replace with the same tag version specified in the podspec file
git push --tags
```
Finally, push the new pod to the private podspec repo, [EmbedFrameworkSpec](https://github.com/AdaSupport/EmbedFrameworkSpec), by running:

```
pod repo push EmbedFrameworkSpec AdaEmbedFramework.podspec
```

That's it! Clients using the AdaEmbedFramework Cocoapod can now update the version in the podfile, then run `pod install` to get the latest changes.
