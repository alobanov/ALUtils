Pod::Spec.new do |s|
    s.name                  = "DBUtils"
    s.version               = "0.1.2"
    s.summary               = "Database utils for Coredata"
    s.description           = <<-DESC
    Database utils for Coredata
    1. Entity mapper - useful extention for mapping json to entity
    2. Entity Json Exporter - flexible export from entity to json
    DESC

    s.homepage              = "https://github.com/alobanov/DBUtils"
    s.license               = { :type => "MIT", :file => "LICENSE" }
    s.author                = { "Lobanov Aleksey" => "lobanov.aw@gmail.com" }
    s.source                = { :git => "https://github.com/alobanov/DBUtils.git", :tag => s.version.to_s }
    s.social_media_url      = "https://twitter.com/alobanov"

    s.ios.deployment_target = '9.0'

    s.default_subspec = "Core"
    s.source_files = 'Sources/dbutils/**/*.swift'

  s.subspec "Core" do |ss|
    ss.source_files  = "Sources/dbutils/**/*.swift"
    ss.framework  = "Foundation"
    ss.framework  = "CoreData"
  end

  s.subspec "Usefull" do |ss|
    ss.source_files = "Sources/usefull/**/*.swift"
    ss.dependency 'RxSwift', '~> 3'
    ss.dependency 'SwiftyJSON'
    ss.dependency 'ObjectMapper', '~> 2.2.7'
  end

  s.subspec "RxCoredataProvider" do |ss|
    ss.source_files = "Sources/coredataProvider/**/*.swift"
    ss.dependency "DBUtils/Usefull"
    ss.dependency 'DATAStack'
  end
end
