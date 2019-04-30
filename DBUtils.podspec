Pod::Spec.new do |s|
    s.name                  = "ALUtils"
    s.version               = "0.3"
    s.summary               = "Database utils for Coredata"
    s.description           = <<-DESC
    Database utils for Coredata
    1. Entity mapper - useful extention for mapping json to entity
    2. Entity Json Exporter - flexible export from entity to json
    DESC

    s.homepage              = "https://github.com/alobanov/ALUtils"
    s.license               = { :type => "MIT", :file => "LICENSE" }
    s.author                = { "Lobanov Aleksey" => "lobanov.aw@gmail.com" }
    s.source                = { :git => "https://github.com/alobanov/ALUtils.git", :tag => s.version.to_s }
    s.social_media_url      = "https://twitter.com/alobanov"

    s.ios.deployment_target = '11.0'

    s.default_subspec = "DBUtils"
    s.source_files = 'Sources/dbutils/**/*.swift'

  s.subspec "DBUtils" do |ss|
    ss.source_files  = "Sources/dbutils/**/*.swift"
    ss.framework  = "Foundation"
    ss.framework  = "CoreData"
    ss.dependency "ALUtils/Utils"
  end

  s.subspec "Utils" do |ss|
    ss.source_files = "Sources/usefull/**/*.swift"
    ss.dependency 'RxSwift', '5.0.0'
    ss.dependency 'SwiftyJSON', '5.0.0'
    ss.dependency 'ObjectMapper' '3.4.2'
  end

  s.subspec "RxCoredataProvider" do |ss|
    ss.source_files = "Sources/coredataProvider/**/*.swift"
    ss.dependency "ALUtils/Utils"
    ss.dependency "ALUtils/DBUtils"
    ss.dependency 'DATAStack'
  end
end
