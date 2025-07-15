Pod::Spec.new do |s|
  s.name             = 'wallcraft_manager'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for setting wallpapers and saving images to gallery.'
  s.description      = <<-DESC
A Flutter plugin that provides functionality to set wallpapers and save images to the device gallery on Android and iOS platforms.
                       DESC
  s.homepage         = 'https://github.com/mahadydev/wallcraft_manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'MD Mahady Hasan' => 'mahadydev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
