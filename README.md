# FJRouter

## 安装

### Swift Package Manager
> 使用 **Swift PM** 的最简单的方式是找到 Project Setting -> Swift Packages 并将 FJRouter 添加。
> 搜索 `https://github.com/zgjff/FJRouter` 

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

#### 路由`builder`: 用于构建路由的指向控制器。
```swift
FJRoute(path: "/", name: "root", builder: { @MainActor @Sendable _ in 
    ViewController() 
}, animator: { @MainActor @Sendable _ in 
    FJRoute.AppRootControllerAnimator(navigationController: UINavigationController()) 
})
```

#### 路由`animator`: 用于显示路由指向控制器的转场动画。
> 只适用与适用go、goNamed进行跳转的方式, 通过获取viewController进行自控跳转时,此参数无任何意义。

> 注册路由时, `animator`参数如果是nil, 回在内部赋值为`FJRoute.AutomaticAnimator`动画

> 框架内部已经内置了多种实现. `FJRoute.XXXXAnimator`


#### 路由拦截器`redirect`: 这是一个路由拦截器协议, 具体要求如下：
```swift
/// 指向需要重定向的路由。
///
/// 可以携带参数.eg, 目标路由是`/family/:fid`, 则需要完整传入`fid`, 即`/family/123`
func redirectRoute(state: FJRouterState) async throws -> String?
```
框架已经提供了一个通用的拦截器实现`FJRouteCommonRedirector`


#### 关联的子路由`routes`: 可以见同一个模块下的路由, 放在一起注册。
> 注意: 强烈建议子路由的`path`不要以`/`为开头
```swift
let route = try! FJRoute(path: "settings", builder: ..., routes: [
    FJRoute(path: "user", builder: ...),
    FJRoute(path: "pwd", builder: ...),
    FJRoute(path: "info/:id", builder: ...),
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
    return CustomErrorViewController()
}
```

### 跳转
> 强烈建议跳转的时候使用以goNamed为前缀的方法进行跳转

> 1: 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等

> 2: 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改

```swift 
FJRouter.shared.goNamed("login")
FJRouter.shared.go("/login")
```

#### `go`到匹配路由页面: 框架内部处理跳转到匹配路由页面的方式
> 根据路由的`animator`参数返回的`FJRouteAnimator`协议的实现

```swift 
FJRouter.shared.go(location: "/login")
FJRouter.shared.goNamed("user", params: ["id": "123"])
```

### 路由回调
> 1: 路由回调是使用`Combine`框架实现的

> 2: 只支持跳转的使用使用`async`异步, 且返回值是`AnyPublisher<FJRouter.CallbackItem, FJRouter.MatchError>`的方法

监听:
```swift
go location
let callback = await FJRouter.shared.go(location: "/second")
callback.sink(receiveCompletion: { cop in
    print("cop----全部", cop)
}, receiveValue: { item in
    print("value----全部", item)
}).store(in: &cancels)

callback.filter({ $0.name == "completion" })
.sink(receiveCompletion: { cop in
    print("cop----特殊:", cop)
}, receiveValue: { item in
    print("value----特殊:", item)
}).store(in: &cancels)

go goNamed
let callback = await FJRouter.shared.goNamed("second")
...
```

触发: 在需要回调的地方,直接调用框架的方法`triggerFJRouterCallBack`
```swift
try? triggerFJRouterCallBack(name: "haha", value: ())
dismiss(animated: true, completion: { [weak self] in
    try? self?.triggerFJRouterCallBack(name: "completion", value: 123)
})
```



### 跳转方式
#### 1: 系统push 
注册路由的时候`animator`设置为`FJRoute.SystemPushAnimator`
#### 2: 系统present 
注册路由的时候`animator`设置为`FJRoute.SystemPresentAnimator`
#### 3: 设置app window的`rootController`
注册路由的时候`animator`设置为`FJRoute.AppRootControllerAnimator`
#### 4: 使用自定义弹窗转场动画
注册路由的时候`animator`设置为`FJRoute.CustomPresentationAnimator`
#### 5: 系统push/pop动画风格的present/dismiss转场动画, 支持侧滑dismiss
注册路由的时候`animator`设置为`FJRoute.PresentSameAsPushAnimator`
#### 6: 根据情况自动选择动画方式
> 如果有`fromVC`且有导航栏, 则进行系统`push`

> 如果有`fromVC`且没有导航栏, 则进行系统`present`

> 如果没有`fromVC`,判定`window`没有`rootController`, 则设置app的`rootController`

注册路由的时候`animator`设置为`FJRoute.AutomaticAnimator`
#### 7: 其它跳转动画
准守并实现`FJRouteAnimator`路由动画协议, 然后在注册路由的时候设置`animator`
