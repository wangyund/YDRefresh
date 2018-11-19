Pod::Spec.new do |s|
  s.name     = 'YDSQLite'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'A delightful iOS and OS X SQLite framework.'
  s.homepage = 'https://github.com/wangyund/YDSQLite'
  s.social_media_url = 'https://github.com/wangyund'
  s.authors  = { 'wangyund' => 'wuyezhiguhun@163.com' }
  s.source   = { :git => 'https://github.com/wangyund/YDSQLite.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  
  s.public_header_files = 'YDSQLite/Framework/YDSQLite.h'
  s.source_files = 'YDSQLite/Framework/YDSQLite.h'
  
  pch_AF = <<-EOS

EOS
  
  s.subspec 'Extension' do |ss|
    ss.source_files = 'YDSQLite/Framework/Extension/.{h,m}'
    ss.public_header_files = 'YDSQLite/Framework/Extension/.{h}'

  end

  
  s.subspec 'SQL' do |ss|
    ss.source_files = 'YDSQLite/Framework/SQL/*/.{h,m}'
    ss.public_header_files = 'YDSQLite/Framework/SQL/*/.{h}'

  end

  
  s.subspec 'Dao' do |ss|
    ss.source_files = 'YDSQLite/Framework/Dao/.{h,m}'
    ss.public_header_files = 'YDSQLite/Framework/Dao/.{h}'

  end

  s.subspec 'Utils' do |ss|
    ss.source_files = 'YDSQLite/Framework/Utils/.{h,m}'
    ss.public_header_files = 'YDSQLite/Framework/Utils/.{h}'
  end

  s.subspec 'DB' do |ss|
    ss.public_header_files = 'YDSQLite/Framework/DB/*/.{h}'
    ss.source_files = 'YDSQLite/Framework/DB/*/.{h,m}'
  end
end
