Pod::Spec.new do |s|
  s.name             = "Pixpie"
  s.version          = "0.3.3"
  s.summary          = "Pixpie SDK for iOS"
  s.description      = "Pixpie is a media content optimization service for mobile applications. Built for mobile developers."
  s.homepage         = "http://pixpie.co"
  s.screenshots      = "http://pixpie-230a.kxcdn.com/images/pixpie_full_logo.png"
  s.license          = 'MIT'
  s.author           = { "Dmitry Osipa" => "dmitry@pixpie.co" }
  s.source           = { :git => "https://github.com/PixpieCo/Pixpie-iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/PixpieCo'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/Public/**/*.h'
  s.dependency 'AFNetworking', '~> 3.0'
  s.dependency 'WebP', '~> 0.5.0'
  s.xcconfig = { :'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'}

end