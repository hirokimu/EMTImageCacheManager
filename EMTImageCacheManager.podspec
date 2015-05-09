Pod::Spec.new do |s|
  s.name         = "EMTImageCacheManager"
  s.version      = "1.0.0"
  s.summary      = "An image cache manager for WKInterfaceDevice of Apple WatchKit"
  s.description  = <<-DESC
                   If WKInterfaceDevice's .cachedImages is already full, EMTImageCacheManager removes cache files as much as necessary in ascending order by added date.
                   DESC
  s.homepage     = "https://github.com/hirokimu/EMTImageCacheManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Hironobu Kimura" => "kimura@emotionale.jp" }
  s.platform     = :ios, "8.2"
  s.source       = { :git => "https://github.com/hirokimu/EMTImageCacheManager.git", :tag => s.version }
  s.source_files  = "EMTImageCacheManager/*.{h,m,swift}"
  s.requires_arc = true
end
