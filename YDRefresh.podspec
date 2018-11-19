Pod::Spec.new do |s|
  s.name     = 'YDRefresh'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'A delightful iOS and OS X YDRefresh framework.'
  s.homepage = 'https://github.com/wangyund/YDRefresh'
  s.social_media_url = 'https://github.com/wangyund'
  s.authors  = { 'wangyund' => 'wuyezhiguhun@163.com' }
  s.source   = { :git => 'https://github.com/wangyund/YDRefresh.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  
  s.public_header_files = 'YDRefresh/.{h}'
  s.source_files = 'YDRefresh/*/.{h,m,png}'
  

end
