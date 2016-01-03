#LGPhotoBrowser.podspec
Pod::Spec.new do |s|
s.name         = "LGPhotoBrowser"
s.version      = "1.1.0"
s.summary      = "此框架包含三个模块：照片浏览器，相册选择器，照相机.此框架在实际项目中使用过，过程中改善了众多bug，在稳定性、流畅性以及内存消耗方面做了大量优化。但难免还有缺陷，希望同道朋友在使用过程中发现并指正！"

s.homepage     = "https://github.com/gang544043963/LGPhotoBrowser"
s.license      = 'MIT'
s.author       = { "ligang" => "544043963@.com" }
s.platform     = :ios, "7.0"
s.ios.deployment_target = "7.0"
s.source       = { :git => "https://github.com/gang544043963/LGPhotoBrowser.git", :tag => s.version}
s.source_files  = 'LGPhotoBrowser/Classes/*.h'
s.requires_arc = true
end