use_frameworks!
inhibit_all_warnings!
platform :ios, '11.0'

target 'EntitySerialization' do
#pod 'DBUtils', :path => '.'
pod 'DATAStack'
pod 'RxSwift'
pod 'ObjectMapper'
pod 'SwiftyJSON'
pod 'RxDataSources'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end
