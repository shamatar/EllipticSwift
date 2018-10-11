Pod::Spec.new do |s|
s.name             = "EllipticSwift"
s.version          = "2.0.7"
s.summary          = "Elliptic curve arithmetics in vanilla Swift for iOS ans macOS"

s.description      = <<-DESC
Elliptic curve arithmetics and modular multiprecision arithmetics in vanilla Swift. Uses Apple's Accelerate framework on MacOS and manually implemented U256 type for iOS.
DESC

s.homepage         = "https://github.com/shamatar/EllipticSwift"
s.license          = 'Apache License 2.0'
s.author           = { "Alex Vlasov" => "alex.m.vlasov@gmail.com" }
s.source           = { :git => 'https://github.com/shamatar/EllipticSwift.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/shamatar'

s.swift_version = '4.1'
s.module_name = 'EllipticSwift'
s.source_files = 'EllipticSwift/Common/**/*.swift', 'EllipticSwift/Common/PrecompiledCurves/**/*.swift', 'EllipticSwift/EllipticSwift.h'
s.ios.deployment_target = "9.0"
s.ios.source_files = 'EllipticSwift/iOS/**/*.swift'

s.osx.deployment_target = "10.11"

s.osx.source_files = 'EllipticSwift/MacOS/**/*.swift'
s.osx.frameworks = 'Accelerate'

s.public_header_files = 'EllipticSwift/EllipticSwift.h'
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }


s.dependency 'BigInt', '~> 3.1'
end
