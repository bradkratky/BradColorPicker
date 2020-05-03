#
# Be sure to run `pod lib lint BradColorPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BradColorPicker'
  s.version          = '0.5.0'
  s.summary          = 'A Swift color picker using HSV, RGBA, and hex codes.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
BradColorPicker is an HSV/RGBA color picker written in Swift.  It allows selection of a color using an HSV palette, RGB sliders or hex code input. The picker is launched using a view controller and closes once the user finishes selection.
                       DESC

  s.homepage         = 'https://github.com/bradkratky/BradColorPicker'
  s.screenshots     = 'https://raw.githubusercontent.com/bradkratky/BradColorPicker/master/Example/screenshot.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brad Kratky' => 'brad@tidaltext.com' }
  s.source           = { :git => 'https://github.com/bradkratky/BradColorPicker.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bradkratky'

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.source_files = 'BradColorPicker/Classes/**/*'
  s.resources = 'BradColorPicker/**/*.xcassets'
end
