Pod::Spec.new do |s|
  s.name         = "Swarm"
  s.version      = "0.3.0"
  s.summary      = "Simple, fast, modular Web-scrapping engine written in Swift"
  s.homepage     = "https://github.com/DenTelezhkin/Swarm"
  s.license  = 'MIT'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin.oss@gmail.com' }
  s.social_media_url = 'https://twitter.com/DenTelezhkin'
  s.swift_versions = ['5.3']
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '3.0'
  s.source = { :git => 'https://github.com/DenTelezhkin/Swarm.git', :tag => s.version.to_s }
  s.source_files  = "Sources/Swarm/*.{swift}"
end
