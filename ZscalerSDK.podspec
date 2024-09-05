
Pod::Spec.new do |s|
  s.name                = 'ZscalerSDK'
  s.version             = '1.0.4'
  s.summary             = 'Zscaler SDK for Mobile Apps'
  s.description         = 'Zscaler App Security SDK'
  s.license             = { :type => 'Commercial' }
  s.author              = 'Zscaler'
  s.homepage            = 'https://zscaler.com/'

  s.platform            = :ios, '15.0'
  s.source              = { :http => 'https://github.com/zscaler/zscaler-sdk-ios' }

  s.vendored_frameworks = ['Zscaler.xcframework']
end


