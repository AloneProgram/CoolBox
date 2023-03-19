# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

source 'https://cdn.cocoapods.org'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
    end
end


target 'CoolBox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  use_modular_headers!
  # 忽略引入库的所有警告
  inhibit_all_warnings!
  
  # 网络请求
  pod 'Moya'
  # JSON解析
  pod 'SwiftyJSON', '~> 4.0'
  # 图片缓存
  pod 'Kingfisher', '~> 6.3.1'
  # 数据缓存
  pod 'MMKV'
  # 布局框架
  pod 'SnapKit'
  # 上下拉刷新
  pod 'MJRefresh'
  pod 'AttributedString'
  pod 'MBProgressHUD'
  
  # 分页
  pod 'Parchment'
 
    # 占位图
  pod 'CYLTableViewPlaceHolder'
  # 图片浏览器
  pod 'JXPhotoBrowser'
  pod 'HBDNavigationBar', '~> 1.9.3'
  pod 'IQKeyboardManagerSwift', '6.3.0'
  pod 'AttributedString'
  pod 'SwiftDate'
  #左右滑动切换视图
  pod 'SegementSlide', :git => 'https://github.com/Jhin-zhou/SegementSlide.git'
  pod 'TZImagePickerController'
  #微信开放平台SDK
  pod 'WechatOpenSDK'
  pod 'MMKV'
  pod 'Qiniu'
  
  pod "McPicker"
  
  
  # 界面调试
  pod 'LookinServer', :configurations => ['Debug']
  
  


end
