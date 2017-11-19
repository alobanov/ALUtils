# DBUtils
Database utils for Coredata

```swift
source 'https://github.com/alobanov/ALSpec.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!
platform :ios, '9.0'

target 'TestLib' do
pod 'DBUtils'

# or just only mapper pod 'DBUtils\EntityMapper'
# or just only json export util pod 'DBUtils\JsonEntityExporter'
end
```
