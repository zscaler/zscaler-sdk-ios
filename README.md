
# Zscaler SDK for Mobile Apps - iOS

Zscaler SDK, part of the Zscaler Zero Trust Exchange™ platform, combines a set of robust capabilities to protect the integrity of your intellectual property, secure network communications from your mobile application, and prevent breaches against your APIs and core backend services.


## Integration

ZscalerSDK iOS supports Swift Package Manager, Cocoapods, and manual integration.

### SwiftPM
1. Navigate to File > Swift Packages > Add Package Dependency
2. Insert the repository URL for ZscalerSDK (http://github.com/zscaler/zscaler-sdk-ios)

### Cocoapods
1. Edit your Podfile to contain the following line:
```ruby
pod 'ZscalerSDK', :git => 'https://github.com/zscaler/zscaler-sdk-ios'
```
2. Run `pod install`

### Manual Integration
1. Download a zip of the `ZscalerSDK.xcframework` release.
2. Add `ZscalerSDK.xcframework` to your Xcode project.
3. In Frameworks, Libraries, and Embedded Content add `ZscalerSDK.xcframework`. 
4. Change the "embed" option to "Embed & Sign".
