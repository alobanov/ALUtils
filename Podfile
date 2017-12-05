use_frameworks!
inhibit_all_warnings!
platform :ios, '9.0'

target 'EntitySerialization' do
#pod 'DBUtils', :path => '.'
pod 'DATAStack'
pod 'RxSwift', '~> 3'
pod 'ObjectMapper', '~> 2.2.7'
pod 'SwiftyJSON'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.2'
    end
  end
end
