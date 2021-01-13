Pod::Spec.new do |spec|
  spec.name         = "Swarm"
  spec.version      = "0.0.1"
  spec.summary      = "Simple, fast, modular Web-scrapping engine written in Swift"
  spec.homepage     = "https://github.com/DenTelezhkin/Swarm"
  spec.license  = 'MIT'
  spec.authors  = { 'Denys Telezhkin' => 'denys.telezhkin.oss@gmail.com' }
  spec.social_media_url = 'https://twitter.com/DenTelezhkin'
  spec.swift_versions = ['5.3']
  spec.ios.deployment_target = '10.0'
  spec.tvos.deployment_target = '10.0'
  spec.osx.deployment_target = '10.12'
  spec.watchos.deployment_target = '3.0'
  spec.source = { :git => 'https://github.com/DenTelezhkin/Swarm.git', :tag => spec.version.to_s }
  spec.source_files  = "Sources/Swarm/*.{swift}"
end
