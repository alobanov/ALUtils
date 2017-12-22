# DBUtils
Utils

```swift
source 'https://github.com/alobanov/ALSpec.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!
platform :ios, '9.0'

target 'TestLib' do
pod 'ALUtils/Utils', :git => 'https://github.com/alobanov/ALUtils.git', :branch => 'master'
pod 'ALUtils/DBUtils', :git => 'https://github.com/alobanov/ALUtils.git', :branch => 'master'
pod 'ALUtils/RxCoredataProvider', :git => 'https://github.com/alobanov/ALUtils.git', :branch => 'master'
end
```
