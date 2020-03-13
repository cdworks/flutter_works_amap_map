#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint works_amap_map.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'works_amap_map'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*','Resoures/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.resources = 'Resoures/**/*'
  
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  
  s.dependency 'AMapNavi-NO-IDFA'
  s.dependency 'AMapLocation-NO-IDFA'
  s.dependency 'AMapSearch-NO-IDFA'
  s.dependency 'MJRefresh'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
