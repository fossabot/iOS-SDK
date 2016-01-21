#
# Be sure to run `pod lib lint Pixpie-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Pixpie-iOS"
  s.version          = "0.1.0"
  s.summary          = "Pixpie SDK for iOS"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = "Pixpie is a media content optimization service for mobile applications. Built for mobile developers."
  s.homepage         = "http://pixpie.co"
  s.screenshots      = "http://pixpie.co/img/pixpie_full_logo.png"
  s.license          = 'MIT'
  s.author           = { "Dmitry Osipa" => "dmitry@pixpie.co" }
  s.source           = { :git => "https://github.com/Pixpie-iOS/Pixpie-iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/PixpieCo'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Pixpie-iOS' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'Security'
  s.dependency 'AFNetworking', '~> 3.0'
  s.dependency      'libwebp', '~> 0.4.2'
end
