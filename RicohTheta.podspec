#
#  Be sure to run `pod spec lint CommonUI.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new  do |spec|

spec.name         = "RicohTheta"
spec.version      = "0.0.1"
spec.summary      = "Ricoh theta capturing"
spec.description  = "Ricoh theta capturing using Google Open Spherical Camera API with little customization done by Ricoh theta, also see https://api.ricoh/docs/"
spec.homepage     = "https://github.com/Winfooz/RicohTheta.git"
spec.license          = { :type => 'MIT', :file => 'LICENSE' }

spec.swift_version = "5.0"

spec.author           = { 'Majd Sabah' => 'sbh.majd@gmail.com' }

spec.platform     = :ios, "13.0"

spec.source       = { :git => "https://github.com/Winfooz/RicohTheta.git", :tag => spec.version.to_s }

spec.source_files = 'RicohTheta/Source/**/*.{swift}'

spec.dependency 'GenericJSON'

spec.test_spec 'UnitTests' do |test_spec|
  test_spec.source_files = 'RicohThetaTests/**/*.{swift}'
end

end
