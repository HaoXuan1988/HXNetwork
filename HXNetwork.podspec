
Pod::Spec.new do |s|
  s.name         = "HXNetwork”
  s.version      = “1.0.0”
  s.summary      = "基于AFNetworking封装的简单易用网络库"

  s.description  = <<-DESC
                   基于AFNetworking 3.0.4 封装的网络库，提供了常用的API，调用简单。
                   DESC
  s.homepage     = "https://github.com/HaoXuan1988/HXNetwork"
  s.license      = "MIT"
  s.author             = { “haoxuan1988” => "" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/HaoXuan1988/HXNetwork.git", :tag => ‘1.0.0’ }
  s.source_files  = "HXNetwork", "*.{h,m}"
  s.requires_arc = true
  s.dependency "AFNetworking", "~> 3.0.4”

end
