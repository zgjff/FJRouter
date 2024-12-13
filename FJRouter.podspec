Pod::Spec.new do |s|
  s.name         = "FJRouter"
  s.version      = "1.2.8"
  s.summary      = "正则、重定向、支持参数、子路由"
  s.homepage     = "https://github.com/zgjff/FJRouter"
  s.license      = "MIT"
  s.author       = { "zgj" => "zguijie1005@qq.com" }
  s.source       = { :git => "https://github.com/zgjff/FJRouter.git", :tag => s.version }

  s.description = '方便简单, 使用正则进行匹配, 支持重定向, 支持路由携带参数, 支持子路由的路由框架'

   s.source_files = 'Sources/*.swift', 'Sources/**/*.{swift}'
   s.platform     = :ios, "13.0"
   s.swift_version = '5.0'
  end
