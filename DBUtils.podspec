Pod::Spec.new do |s|
    s.name                  = "DBUtils"
    s.version               = "0.1.0"
    s.summary               = "Database utils for Coredata"
    s.description           = <<-DESC
    Database utils for Coredata
    DESC

    s.homepage              = "https://github.com/alobanov/DBUtils"
    s.license               = { :type => "MIT", :file => "LICENSE.md" }
    s.author                = { "Lobanov Aleksey" => "lobanov.aw@gmail.com" }
    s.source                = { :git => "git@github.com:alobanov/DBUtils.git", :tag => s.version.to_s }
    s.social_media_url      = "https://twitter.com/alobanov"

    s.ios.deployment_target = '9.0'

    s.default_subspec = "Utils"
    s.source_files = 'Sources/**/*.swift'

  s.subspec "EntityMapper" do |ss|
    ss.source_files  = "Sources/entityMapper/*.swift"
    ss.framework  = "Foundation"
    ss.framework  = "CoreData"
  end

  s.subspec "JsonEntityExporter" do |ss|
    ss.source_files = "Sources/jsonEntityExporter/*.swift"
    ss.framework  = "Foundation"
    ss.framework  = "CoreData"
  end

  s.subspec "Utils" do |ss|
    ss.dependency "DBUtils/EntityMapper"
    ss.dependency "DBUtils/JsonEntityExporter"
    ss.framework  = "Foundation"
    ss.framework  = "CoreData"
  end
end
