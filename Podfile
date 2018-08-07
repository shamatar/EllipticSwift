def import_pods
  pod 'BigInt', '~> 3.1'
end

target 'EllipticSwift' do
  platform :osx, '10.11'
  use_frameworks!
#  use_modular_headers!
  import_pods

  target 'EllipticSwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'EllipticSwift_iOS' do
  platform :ios, '9.0'
  use_frameworks!
#  use_modular_headers!
  import_pods
end
