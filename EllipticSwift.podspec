Pod::Spec.new do |s|
s.name             = "EllipticSwift"
s.version          = "1.0"
s.summary          = "Elliptic curve arithmetics in vanilla Swift for iOS ans macOS"

s.description      = <<-DESC
Elliptic curve arithmetics and modular multiprecision arithmetics in vanilla Swift. Uses Apple's Accelerate framework for with numeric types for now.
DESC

s.homepage         = "https://github.com/shamatar/EllipticSwift"
s.license          = 'Apache License 2.0'
s.author           = { "Alex Vlasov" => "alex.m.vlasov@gmail.com" }
s.source           = { :git => 'https://github.com/shamatar/EllipticSwift.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/shamatar'

s.swift_version = '4.1'
s.module_name = 'EllipticSwift'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.11"
s.source_files = "EllipticSwift/**/*.{swift}, EllipticSwift/FixedWidthTypes/**/*.{swift}",
s.public_header_files = "EllipticSwift/**/*.{h}"
#s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

s.frameworks = 'Accelerate'
s.dependency 'BigInt', '~> 3.1'
end
