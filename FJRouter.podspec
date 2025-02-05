Pod::Spec.new do |s|
  s.name         = "FJRouter"
  s.version      = "2.0.0"
  s.summary      = "正则、重定向、支持参数、路由、回调、子路由、资源中心、事件总线"
  s.homepage     = "https://github.com/zgjff/FJRouter"
  s.license      = "MIT"
  s.author       = { "zgj" => "zguijie1005@qq.com" }
  s.source       = { :git => "https://github.com/zgjff/FJRouter.git", :tag => s.version }

  s.description = '1: 方便简单, 使用正则进行匹配, 支持重定向, 支持路由携带参数, 支持回  调, 支持子路由的路由; '    \
                    '2: 方便简单, 使用正则进行匹配, 支持资源的存储和取回的资源管理中心, 资源可以是int, string, enum, uiview, uiviewcontroller, protocol...;'   \
                    '3: 方便简单, 使用正则进行匹配, 监听和触发事件总线'


  s.subspec 'Base' do |ss|
    ss.source_files = 'Sources/Base/*.swift', 'Sources/Base/**/*.{swift}'
  end

  s.subspec 'Jump' do |ss|
    ss.source_files = 'Sources/Jump/*.swift', 'Sources/Jump/**/*.{swift}'
    ss.dependency 'FJRouter/Base'
    #ss.description = '方便简单, 使用正则进行匹配, 支持重定向, 支持路由携带参数, 支持回  调, 支持子路由的路由'
  end

  s.subspec 'Event' do |ss|
    ss.source_files = 'Sources/Event/*.swift', 'Sources/Event/**/*.{swift}'
    ss.dependency 'FJRouter/Base'
    #ss.description = '方便简单, 使用正则进行匹配, 监听和触发事件总线'
  end

  s.subspec 'Resource' do |ss|
    ss.source_files = 'Sources/Resource/*.swift', 'Sources/Resource/**/*.{swift}'
    ss.dependency 'FJRouter/Base'
    #ss.description = '方便简单, 使用正则进行匹配, 支持资源的存储和取回的资源管理中心, 资源可以是int, string, enum, uiview, uiviewcontroller, protocol...;'
  end
  
  s.platform     = :ios, "13.0"
  s.swift_version = '5.9'
end
