#
# Be sure to run `pod lib lint YPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YPlayer'
  s.version          = '1.0.1'
  s.summary          = 'Webview for youtube videos to playe video or search by youtube for a video'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Youtube player is to run and play youtube videos using webview, it will show webview as native component, so you can do many things, like seeking time, get current time, play video with options, etc..
                       DESC

  s.homepage         = 'https://github.com/mfa01/YoutubePlayer-iframe'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mohammad Alabed' => 'mfa01@yahoo.com' }
  s.source           = { :git => 'https://github.com/mfa01/YoutubePlayer-iframe.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '13.0'
  s.swift_versions = '5.0'
  s.source_files = 'YPlayer/Classes/**/*', 'YoutubePlayer/WebviewController/**/*'
  #,'YPlayer/Classes/**/*.swift','YPlayer/Classes/**/*.xib'

  
  # s.resource_bundles = {
  #   'YPlayer' => ['YPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
