#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint speed_checker_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'speed_checker_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for SpeedChecker SDK'
  s.description      = <<-DESC
Flutter plugin for SpeedChecker SDK
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.preserve_paths = 'DataCompression.xcframework/**/*', 'Socket.xcframework/**/*', 'SpeedcheckerSDK.xcframework/**/*', 'XMLParsing.xcframework/**/*'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework DataCompression', 'OTHER_LDFLAGS' => '-framework Socket', 'OTHER_LDFLAGS' => '-framework SpeedcheckerSDK', 'OTHER_LDFLAGS' => '-framework XMLParsing'  }
  s.vendored_frameworks = 'DataCompression.xcframework', 'Socket.xcframework', 'SpeedcheckerSDK.xcframework', 'XMLParsing.xcframework'
end
