# FJRouter

## 安装

### Swift Package Manager
> 使用 **Swift PM** 的最简单的方式是找到 Project Setting -> Swift Packages 并将 FJRouter 添加在其中。
> 搜索 `https://github.com/zgjff/FJRouter` 并

### CocoaPods
在你的 Podfile 文件中添加 FJRouter:
```rb
pod 'FJRouter'
```
然后运行 `pod install`。

## 用法

### 注册路由

#### 1: 关于路由结构`FJRoute`

##### 路由的名称`name`: 建议注册路由的时候给路由设置名称, 原因有两点:
> 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等

> 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改

设置路由的名称之后, 后续的跳转均可以通过`name`进行。

#### 路由路径`path`: 路由路径的解析通过正则进行解析, 支持路径参数设置。eg:
> 路径`/family/:fid`, 可以匹配以`/family/...`开始的url, eg: `/family/123`, `/family/456` and etc.
 
> 路径`/user/:id/book/:bookId`, 可以解析出参数分别需要id, bookId, 可以匹配`/user/../book/...`的url, eg: `/user/123/book/456` and etc.

#### 路由`builder`: 用于构建路由具体的控制器行为。此类型是个构建对应控制器的枚举类型: 包含只创建的`default`和自动创建并处理显示的`display`
```swift
/// 构建路由的`controller`构建器
    public enum Builder: Sendable {
        /// 默认构建方式: 只创建并返回路由的指向`controller`
        ///
        /// 注意不需要在必包内部处理`controller`的显示逻辑
        ///
        /// ```swift
        /// builder: .default({ state in
        ///    let vc = UIViewController()
        ///    return vc
        /// })
        /// ```
        case `default`(_ action: @MainActor @Sendable (_ state: FJRouterState) -> UIViewController)
        
        /// 构建+展示构建方式: 创建, 并且需要在内部处理跳转逻辑并返回路由的指向`controller`。
        /// 要配合路由的`go`或`goNamed`方法进行显示, 不支持手动调用`push`和`present`
        ///
        /// 就算是调用路由的`push`和`present`方法也不会跳转
        ///
        /// 注意一定要在必包内部处理`controller`的显示逻辑: push、present、rootController、自定义转场等等
        ///
        /// ```
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    sourceController.navigationController?.pushViewController(vc, animated: true)
        ///    return vc
        /// })
        ///
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    vc.modalPresentationStyle = .fullScreen
        ///    sourceController.present(vc, animated: true)
        ///    return vc
        /// })
        ///
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    UIApplication.shared.keyWindow?.rootViewController = vc
        ///    return vc
        /// })
        ///
        /// builder: .display({ sourceController, state in
        ///    let vc = UIViewController()
        ///    vc.modalPresentationStyle = .custom
        ///    vc.transitioningDelegate = xxx
        ///    sourceController.present(vc, animated: true)
        ///    return vc
        /// })
        /// ```
        case display(_ action: @MainActor @Sendable (_ sourceController: UIViewController?, _ state: FJRouterState) -> UIViewController)
    }
```



#### 路由拦截器`interceptor`: 这是一个路由拦截器协议, 具体要求如下：
```swift
/// 指向需要重定向的路由。
///
/// 可以携带参数.eg, 目标路由是`/family/:fid`, 则需要完整传入`fid`, 即`/family/123`
func redirectRoute(state: FJRouterState) async -> String
```
框架已经提供了一个通用的拦截器实现`FJRouteCommonInterceptor`


#### 关联的子路由`routes`: 可以见同一个模块下的路由, 放在一起注册。
> 注意: 强烈建议子路由的`path`不要以`/`为开头
```swift
let route = try! FJRoute(path: "settings", builder: ..., routes: [
    try! FJRoute(path: "user", builder: ...),
    try! FJRoute(path: "pwd", builder: ...),
    try! FJRoute(path: "info/:id", builder: ...),
])
```

#### 2: 注册

通过构建路由`FJRoute`对象进行注册:
```swift
FJRouter.shared.registerRoute(route: FJRoute)
```

直接通过路由`path`进行注册:
```swift
FJRouter.shared.registerRoute(path: String, ...)
```

### 设置路由

#### 设置允许最大重定向的次数, 若是匹配的路由重定向次数超过设置值, 则会匹配失败.
```swift 
FJRouter.shared.setRedirectLimit(50)
```

#### 设置路由匹配失败时的显示页面, 框架内部默认使用的错误页面UI较简陋, 可以通过此方法调整设置
```swift
FJRouter.shared.setErrorBuilder { state in
    return UIViewController()
}
```

### 跳转
> 强烈建议跳转的时候使用以goNamed、pushNamed、presentNamed为前缀的方法进行跳转

> 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等

> 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改

```swift 
FJRouter.shared.goNamed("login")
FJRouter.shared.pushNamed("login")
FJRouter.shared.presentNamed("login")
```

#### `go`到匹配路由页面: 框架内部处理跳转到匹配路由页面的方式
> 会优先调用路由的`displayBuilder`方法; 若是`displayBuilder`为`nil`, 框架内部会先尝试`push`, 然后尝试`present`

```swift 
FJRouter.shared.go(location: "/login")
FJRouter.shared.goNamed("user", params: ["id": "123"])
```

#### `push`到匹配路由页面
```swift 
FJRouter.shared.push(location: "/login")
FJRouter.shared.pushNamed("user", params: ["id": "123"])
```

#### `present`到匹配路由页面
```swift 
FJRouter.shared.present(location: "/login")
FJRouter.shared.presentNamed("user", params: ["id": "123"])
```