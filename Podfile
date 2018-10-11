def import_pods
  pod 'BigInt', '~> 3.1'
end

target 'EllipticSwift' do
  platform :osx, '10.11'
  use_frameworks!
#  use_modular_headers!
  import_pods

  target 'EllipticSwiftTests' do
    use_frameworks! 
    platform :osx, '10.11'
    inherit! :search_paths
    import_pods
    # Pods for testing
  end

  target 'EllipticSwiftTests_Performance' do
    use_frameworks!
    platform :osx, '10.11'
    inherit! :search_paths
    import_pods
    # Pods for testing
  end

end



target 'EllipticSwift_iOS' do
  platform :ios, '9.0'
  use_frameworks!
#  use_modular_headers!
  import_pods
  target 'EllipticSwift_iOS_Tests' do
    use_frameworks!
    platform :ios, '9.0'
    inherit! :search_paths
    import_pods
    # Pods for testing
  end
end
