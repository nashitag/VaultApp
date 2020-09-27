# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

plugin 'cocoapods-keys', {
    :project => "VaultApp",
    :keys => [
        "EncryptionKeyForAlbumPin",
        "EncryptionKeyForPhotos"
    ]
}

target 'VaultApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VaultApp
  pod 'Firebase/Storage’  
  pod 'Firebase/Core’
  pod 'Firebase/Auth’
  pod 'Firebase/Database’
  pod 'RNCryptor', '~> 5.0'

  target 'VaultAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
