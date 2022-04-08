Pod::Spec.new do |s|
  s.name = 'DynamicObject'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Dynamic-Typed Object in Swift'
  s.homepage = 'https://github.com/maxep/swift-dynamic-object'
  s.authors = { 'Maxime Epain' => 'me@maxep.me' }
  s.source = { :git => 'https://github.com/maxep/swift-dynamic-object.git', :tag => s.version }

  s.ios.deployment_target = '12.2'
  s.osx.deployment_target = '10.14.4'
  s.tvos.deployment_target = '12.2'
  
  s.source_files = 'Sources/*.swift'

  s.test_spec 'Tests' do |test|
    test.source_files = 'Tests/*.swift'
  end  

end
