# FJRouter
[![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-6.0-Orange?style=flat-square)
![](https://img.shields.io/cocoapods/p/FJRouter.svg?style=flat)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FJRouter.svg?style=flat-square)](https://img.shields.io/cocoapods/v/FJRouter.svg)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

## 简介
> 理解中的路由应该包含路由页面跳转管理、通过url获取对应位置的资源

框架包含三大模块:

- [路由页面跳转管理](#路由页面跳转管理)

- [资源管理中心](#资源管理中心)

- [事件总线](#事件总线)

## 基础设施: `url`的参数正则解析
通过提前注册url pattern规则`/path/:{路径参数}`, 通过正则表达式解析并匹配其中的所有参数。eg:

- 单个参数: 注册路径`/users/:userId`, 解析出此url路径的参数数组为`[userId]`, 可以匹配`/users/...`, 如`/users/123`, 可以匹配成功并解析出`userId`为`123`;

- 多个参数: 注册路径`/city/school/:sname/class/:cid`, 解析出此url路径的参数数组为`[sname, cid]`, 可以匹配`/city/school/xxx/class/xxx`, 如`/city/school/清华大学/class/123`, 可以匹配成功并解析出参数为`["sname": "清华大学", "cid": "123"]`;

- 无参数: 注册路径`/settings/detail`, 可以匹配`/settings/detail`,以及携带查询参数的`url`, 如`/settings/detail?q=a`、`/settings/detail?p=1&q=2`...

## 路由页面跳转管理

### 页面跳转`FJRouterJumpable`协议
1: 路由页面跳转是定义为`FJRouterJumpable`的协议, 可以通过`FJRouter.jump()`获取框架内跳转管理中心对象.

2: 支持通过路由路径和已经注册的路由名称进行对应操作
> 当然在这里, 建议通过路由名称相关的api进行操作, 如`go(.name(...))`, `viewController(.name(...))`方法; why:

> 当路由路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误

> 在实际app中, 路由的`URL`格式可能会随着时间而改变, 但是一般路由名称不会去更改

```swift 
通过路由路径获取对应的控制器: 
let vc = try await FJRouter.jump().viewController(.loc("/"), extra: nil)

通过路由名称获取对应的控制器:
let vc2 = try await FJRouter.jump().viewController(.name("root", params: ["id": "123"]), extra: nil)

通过路由路径导航至对应控制器:
try await FJRouter.jump().go(.loc("/"), extra: nil, from: self, ignoreError: true)

通过路由名称导航至对应控制器:
try await FJRouter.jump().go(.name("root"), extra: nil, from: self, ignoreError: true)
```

3: 支持路由回调
> 路由回调是使用`Combine`框架实现的

> 不需要提前注册回调方法, 只需要在收到`Combine`事件流中区分对应的事件

```swift
let callback = try await FJRouter.jump().go(.name("root"), extra: nil, from: self, ignoreError: true)
callback.sink(receiveCompletion: { cop in
    print("cop----全部", cop)
}, receiveValue: { item in
    print("value----全部", item)
}).store(in: &cancels)


触发:需要viewController方调用
try? dispatchFJRouterCallBack(name: "haha", value: ())
dismiss(animated: true, completion: { [weak self] in
    try? self?.dispatchFJRouterCallBack(name: "completion", value: 123)
})
```

### 路由模型model:`FJRoute`
> 每一个路由都通过`FJRoute`对象进行配置.

#### 路由匹配路径`path`
1: 如果是起始父路由, 其`path`必须以`/`为前缀

2: 支持路径参数, 路由参数将被解析并储存在`JJRouterState`中, 用于[builder](#构建路由方式-builder)和[redirect](#路由拦截器-redirect)

#### 路由的名称: `name`
如果赋值, 必须提供唯一的字符串名称, 且不能为空

#### 构建路由方式: `builder`
1: 此参数是`block`形式的类型别名
```swift
public typealias Builder = (@MainActor @Sendable (_ info: BuilderInfo) -> UIViewController?)
```

2: 此参数可以为`nil`, 但是为`nil`时, 重定向参数`redirect`不能为`nil`

3: `builder`可以根据路由信息`BuilderInfo`返回对应的控制器.

#### 显示路由控制器的方式: `animator`
1: 此参数是`block`形式的类型别名
```swift 
public typealias Animator = (@MainActor @Sendable (_ info: AnimatorInfo) -> any FJRouteAnimator)
```
2: 用于在使用`go(...)`方法进行跳转时, 页面的展现方式。

3: 可以使用框架已内置的动画方式对象, 或者可以使用自己实现的协议对象, 具体参考[FJRouteAnimator](#路由显示动画协议-fjrouteanimator)。

4: 没有`push`和`present`的概念; 所有的动画细节均隐藏在协议对象里:

> `FJRoute.SystemPushAnimator`对应`push`

> `FJRoute.SystemPresentAnimator`对应`present`

#### 路由拦截器: `redirect`

1: 有些路由地址需要拦截器，例如对于没有登录的用户，有些页面就无法访问.eg: 
```swift
let loginRoute = try! FJRoute(path: "/login", name: "login", builder: { info in
    return UIViewController()
}, redirect: [FJRouteCommonRedirector(redirect: { state in
    let hasLogin = xxx
    if hasLogin { // true, 即代表已经登录, 此时允许可以跳转至login路由
        return .pass
     }
    // hasLogin: false, 即代表未登录, 此时页面在未登录相关的页面, 如登录/注册/发送验证码...等页面, 此时不允许跳转至login路由, 防止多重的跳转至登录
    return .interception
})])
```

2: 此参数是个数组, 可以添加多个, 按顺序检查; 比如:登录检查, 用户权限检查......多个条件重定向逻辑可以分开写;职能单一, 方便测试

3: 此参数可以为空, 但是为空时, 构建控制器参数`builder`不能为`nil`

#### 关联的子路由: `routes`

1: 所谓子路由就是: 一个大的路由页面下面的多个相关联的路由。如设置页面下的设置项a,b,c,d...

2: 子路由还一个好处是, 可以减少拼写相同的path路径。如
```swift
设置项：FJRoute(path: "/user/settings", name: "user_settings", xxx)
设置项a：FJRoute(path: "/user/settings/a", name: "user_settings_a", xxx)
设置项b：FJRoute(path: "/user/settings/b", name: "user_settings_a", xxx)
设置项c：FJRoute(path: "/user/settings/c", name: "user_settings_c", xxx)
...

上述所有路由可以总结为一个设置项路由:
try FJRoute(path: "/user/settings", name: "user_settings", xxx, routes: [
    FJRoute(path: "a", name: "user_settings_a", xxx),
    FJRoute(path: "b", name: "user_settings_b", xxx),
    FJRoute(path: "c", name: "user_settings_c", xxx),
    ...
])
```

3: 子路由也支持此当前路由的参数

4: 强烈建议子路由的`path`不要以`/`为开头

```swift
let route = try FJRoute(path: "/play/:id", builder: ({ _  in ViewControllerPlay() }), routes: [
    FJRoute(path: "feature1", builder: ({ _  in ViewControllerPlay1() })),
    FJRoute(path: "feature2", name: "bfeature2", builder: ({ _ in ViewControllerPlay2() })),
    FJRoute(path: "feature3/:name", builder: ({ _  in ViewControllerPlay3() })),
    FJRoute(path: "feature3", name: "bfeature3", builder: ({ _  in ViewControllerPlay4() })),
    FJRoute(path: "feature3", name: "bfeature3-1", builder: ({ _  in ViewControllerPlay5() })),
    FJRoute(path: "feature4/:name", name: "feature4", builder: ({ _  in ViewControllerPlay6() })),
])
```

### 路由显示动画协议: `FJRouteAnimator`

1: 此协议只有一个方法

```swift
/// 开始路由转场动画
/// - Parameters:
///   - fromVC: 要跳转到的源控制器
///   - toVC: 匹配到的路由指向的控制器
///   - matchState: 匹配到的路由信息
@MainActor func startAnimatedTransitioning(from fromVC: UIViewController?, to toVC: UIViewController, state matchState: FJRouterState)
```

2: 内置动画显示方式:
> 以`FJRoute.xxxxAnimator`为开头的实例对象

- 设置app window的rootViewController: `FJRoute.AppRootControllerAnimator`

- 系统present动画进行显示: `FJRoute.SystemPresentAnimator`

- 系统push进行显示: `FJRoute.SystemPushAnimator`

- 根据情况自动选择动画方式: `FJRoute.AutomaticAnimator`

- 自定义`custom`的`present`转场动画: `FJRoute.CustomPresentationAnimator`

- 自定义转场动画进行push: `FJRoute.CustomPushAnimator`

- 自定义`fullScreen`的`present`转场动画: `FJRoute.FullScreenPresentAnimator`

- 系统push/pop动画风格的present/dismiss转场动画, 支持侧滑dismiss: `FJRoute.PresentSameAsPushAnimator`

- 刷新与匹配控制器相同类型的上一个控制器动画: `FJRoute.RefreshSamePreviousAnimator`
  ```swift
    try await FJRouter.shared.registerRoute(FJRoute(path: "/four", name: "four", builder: { sourceController, state in
        FourViewController()
    }, animator: { info in
        if let pvc = info.fromVC, pvc is FourViewController { // 或者其它判断条件
            return FJRoute.RefreshSamePreviousAnimator { @Sendable previousVC, state in
                previousVC.view.backgroundColor = .random()
                previousVC.updatexxxx()
            }
        }
        return FJRoute.SystemPushAnimator()
    }))
  ```

### 路由重定向协议: `FJRouteRedirector`

1: 此协议只有一个方法: 根据匹配状态进行判断返回对应路由的url路径

```swift
/// 重定向行为: interception: 不可以跳转, 即路由守卫/pass: 不需要重定向/new(xxx)需要重定向到新路由路径: 如果返回的是`nil`, 也不需要重定向
func redirectRouteNext(state: FJRouterState) async -> FJRouteRedirectorNext
```

2: app已经内置了一个通用的重定向: `FJRouteCommonRedirector`

3: 路由循环重定向, 框架内部在进行路由匹配的时候, 如果检测到巡航重定向, 则会抛出错误。如:
```
a->b->c->d->a
```

4: 最大重定向次数: 框架内部在进行单个路由匹配的时候, 会记录重定向次数, 如果次数大于设定的值, 会抛出错误。默认最大重定向次数为5, 可以通过如下代码进行设置修改:
```swift
await FJRouter.jump().setRedirectLimit(50)
```


### 注册、跳转事例代码:
```swift
注册
static func register() async throws {
    try await FJRouter.jump().registerRoute(FJRoute(path: "/", name: "root", builder: { @MainActor @Sendable _ in ViewController()}, animator: { info in
            FJRoute.AutomaticAnimator(navigationController: UINavigationController())
        }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/first", name: "first", builder: { _ in FViewController() }, animator: { _ in FJRoute.SystemPushAnimator() }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/second", name: "second", builder: { _ in SViewController() }, animator: { _ in
        FJRoute.CustomPresentationAnimator(navigationController: UINavigationController())
    }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/third", name: "third", builder: { _ in TViewController() }, animator: { _ in FJRoute.SystemPresentAnimator(fullScreen: true, navigationController: UINavigationController()) }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/four", name: "four", builder: { _ in FourViewController() }, animator: { info in
        if let pvc = info.fromVC, pvc is FourViewController {
            return FJRoute.RefreshSamePreviousAnimator { @Sendable previousVC, state in
                previousVC.view.backgroundColor = .random()
            }
        }
        return FJRoute.SystemPushAnimator()
    }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/five", name: "five", builder: { _ in FiveViewController() }, animator: { _ in FJRoute.  CustomPresentationAnimator(navigationController: UINavigationController()) { @Sendable ctx in
        ctx.usingBottomPresentation()
    }}))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/six", name: "six", builder: { _ in SixViewController() }, animator: { info in
        return FJRoute.PresentSameAsPushAnimator(navigationController: UINavigationController())
    }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/seven", name: "seven", builder: { _ in SevenViewController() }, animator: { info in
        return FJRoute.PresentSameAsPushAnimator(navigationController: UINavigationController())
    }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/eight", name: "eight", builder: { _ in EightViewController() }, animator: { info in
        return FJRoute.AutomaticAnimator()
    }))
        
    try await FJRouter.jump().registerRoute(FJRoute(path: "/nine", name: "nine", builder: { _ in NineViewController() }, animator: { info in
        return FJRoute.SystemPushAnimator()
    })) 
}
```

```swift 
跳转
FJRouter.jump().go(.name("first"))

let callback = await FJRouter.jump().go(.name("second"), extra: nil, from: self, ignoreError: true)
callback.sink(receiveCompletion: { cop in
    print("cop----全部", cop)
}, receiveValue: { item in
    print("value----全部", item)
}).store(in: &cancels)

FJRouter.jump().go(.loc("/six"))
```

## 资源管理中心

### 资源管理`FJRouterResourceable`协议:

1: 资源管理是定义为`FJRouterResourceable`的协议, 可以通过`FJRouter.resource()`获取框架资源管理中心对象.

2: 建议使用try FJRouterResource(path: "/xxx", name: "xxx", value: xxx), get(name: xxx)方法进行相关操作。

> 当资源路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误

> 在实际app中, 资源的`URL`格式可能会随着时间而改变, 但是一般资源名称不会去更改

### 存放资源:

```swift 
func put(_ resource: FJRouterResource) async throws
```

1: 资源可以是int, string, enum, uiview, uiviewcontroller, protocol...

2: 资源必须是`Sendable`修饰的对象

3: 存放资源的时候可以携带参数

4: 适用于全局只会存放一次的资源: 如单例中或者`application:didFinishLaunchingWithOptions`中, 或者存放的资源内部具体的值是个固定值, 不会随着时间/操作更改

5: 如果每次存放资源可能会更改, 建议使用`put(_ resource: FJRouterResource, uniquingPathWith: xxx)`方法

6: 事例代码:

```swift 
let r1 = try FJRouterResource(path: "/intvalue1", name: "intvalue1", value: { _ in 1 })
try await FJRouter.resource().put(r1)

let r3 = try FJRouterResource(path: "/intOptionalvalue2", name: "intOptionalvalue2") { @Sendable info -> Int? in
    return nil
}
try await FJRouter.resource().put(r3)

let r5 = try FJRouterResource(path: "/intOptionalvalue3/:optional", name: "intOptionalvalue3", value: { @Sendable info -> Int? in
    let isOptional = info.pathParameters["optional"] == "1"
    return isOptional ? nil : 1
})
try await FJRouter.resource().put(r5)

存放协议
let r6 = try FJRouterResource(path: "/protocolATest/:isA", name: "protocolATest", value: { @Sendable info -> ATestable in
    let isA = info.pathParameters["isA"] == "1"
    return isA ? AModel() : BModel()
})
try await FJRouter.resource().put(r6)
```

### 根据策略存放资源

```swift 
func put(_ resource: FJRouterResource, uniquingPathWith combine: @Sendable (_ current: @escaping FJRouterResource.Value, _ new: @escaping FJRouterResource.Value) -> FJRouterResource.Value) async
```

1: 如果已经存放过相同`path`的资源, 不会抛出`FJRouter.PutResourceError.exist`错误, 会按照`combine`策略进行合并

2: 适用于可能多处/多处存放: 如某个viewController, 出现的时候才去存储资源, 但是因为viewController可能会多次进入, 而且每次存放的资源的具体值均不相同, 使用此方法可以有效的存储, 不会抛出`FJRouter.PutResourceError.exist`错误

3: 资源的名称会优先使用新的资源name, 如果新的资源name为nil, 才会使用旧资源name

4: 事例代码
```swift 
// 使用旧值
await FJRouter.resource().put(r) { (currnet, _) in currnet }
// 使用新值
await FJRouter.resource().put(r) { (_, new) in new }
```

### 获取资源

1: 可以通过路径和资源名称获取资源

```swift 
func get<Value>(_ uri: FJRouter.URI, inMainActor mainActor: Bool) async throws(FJRouter.GetResourceError) -> Value where Value: Sendable
```

2: 事例代码
```swift
let intvalue1: Int = try await FJRouter.resource().get(.loc("/intvalue1"), inMainActor: false)
let intvalue3: Int? = try await FJRouter.resource().get(.loc("/intvalue1"), inMainActor: true)
let intOptionalvalue3: Int? = try await FJRouter.resource().get(.loc("/intOptionalvalue2"), inMainActor: false)
let stringvalue1: String = try await FJRouter.resource().get(.name("intvalue1"), inMainActor: false)
let aTestable1: ATestable = try await FJRouter.resource().get(.loc("/protocolATest/1"), inMainActor: false)
let aTestable2: ATestable = try await FJRouter.resource().get(.name("/protocolATest/0"), inMainActor: true)
let aTestable3: BModel = try await FJRouter.resource().get(.name("/protocolATest/0"), inMainActor: false)
```

### 更新资源
1: 可以通过路径和资源名称更新资源
```swift 
func update(byPath path: String, value: @escaping FJRouterResource.Value) async throws

func update(byName name: String, value: @escaping FJRouterResource.Value) async throws
```

2: 如果没有存放过相同path的资源, 会抛出`FJRouter.GetResourceError.notFind`错误

3: 事例代码
```swift
try await impl.update(byName: "sintvalue1", value: { _ in 66 })
```

### 删除资源

```swift 
func delete(byPath path: String) async throws

func delete(byName name: String) async throws
```

1: 必须是已经存放过的资源, 删除不存在的资源会抛出`FJRouter.GetResourceError.notFind`错误

2: 可以根据名称或者路由删除

3: 事例代码:

```swift
try await FJRouter.resource().delete(byPath: "/intvalue1")
try await FJRouter.resource().delete(byName: "intOptionalvalue1")
```

## 事件总线

### 事件总线`FJRouterEventable`协议

1: 事件总线协议定义为`FJRouterEventable`的协议, 可以通过`FJRouter.event()`获取事件总线管理对象.

2: 建议使用onReceive(path: "xxx", name: "xxx"), emit(name: xxx)方法进行相关操作。

> 当事件路径比较复杂,且含有参数的时候, 如果通过硬编码的方法直接手写路径, 可能会造成拼写错误,参数位置错误等错误

> 在实际app中, 事件的`URL`格式可能会随着时间而改变, 但是一般事件名称不会去更改

### 监听事件

1: 监听动作是通过系统`Combine`框架进行响应, 不持有监听者

2: 可以一对多的进行监听, 即可以在多处监听

3: 事例代码
```swift
无参
let seekSuccess = try await FJRouter.event().onReceive(path: "/seek/success", name: "onSeekSuccess")
seekSuccess.receive(on: OperationQueue.main)
.sink(receiveValue: { info in
    print("onSeekSuccess=>", info)
}).store(in: &self.cancels)

有参
let seekProgress = try await FJRouter.event().onReceive(path: "/seek/:progress", name: "onSeekProgress")
seekProgress.receive(on: OperationQueue.main)
.sink(receiveValue: { info in
    print("onSeekProgress=>", info)
}).store(in: &self.cancels)
```

### 触发事件

1: 可以通过事件路径和名称进行触发

2: 事例代码
```swift
通过事件url路径触发事件
//无参
try await FJRouter.event().emit("/seek/success", extra: 5)
//有参: 1就是监听"/seek/:progress"中的progress字段
try await FJRouter.event().emit("/seek/1", extra: nil)

通过事件名称触发事件
//无参
try await FJRouter.event().emit(.name("onSeekProgress"), extra: nil)
// 有参
try await FJRouter.event().emit(.name("onSeekProgress", params: ["progress": "1"]), extra: nil)
```

## 安装
> 从2.0.2分支开始, 要求swfitVersion>=6, 即必须使用xcode 16.0版本以上

### Swift Package Manager
> 使用 **Swift PM** 的最简单的方式是找到 Project Setting -> Swift Packages 

> 搜索 `https://github.com/zgjff/FJRouter` 并添加

### CocoaPods
在 Podfile 文件中添加 FJRouter:
```rb
pod 'FJRouter'
```
然后运行 `pod install`。
