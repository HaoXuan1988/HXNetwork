
Pod::Spec.new do |s|

  s.name         = "HXNetwork"
  s.version      = "1.0.0"
  s.summary      = "基于 AFNetworking 封装的常用 API."
  s.description  = <<-DESC
基于AFNetworking封装的网络库，提供了常用的API，调用简单。若在使用过程中有问题，请反馈与作者，以便完善之!
                   DESC

  s.homepage     = "https://github.com/HaoXuan1988/HXNetwork"

  s.license      = "MIT"
  s.author             = { "吕浩轩" => "confidenthaoxuan@163.com" }
  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"

  s.source       = { :git => "https://github.com/HaoXuan1988/HXNetwork.git", :tag => s.version }
  s.source_files  = "HXNetwork", "*.{h,m}"
  s.requires_arc = true
  s.dependency "AFNetworking", "~> 3.0.4"

end
