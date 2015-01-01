# Cordova 微信分享插件

Inspired by https://github.com/xu-li/cordova-plugin-wechat  
其实本来 fork 了, 但因为一方面没有支持 Windows Phone, 另一方面 Android 的支持也很有限, 所以重写了.

支持 iOS, WP, Android, 都有回调 (WP 有限制, 具体看下面的例子). 分享内容只支持文本, 图片, 和链接.

另外需要注意的是 Android 不仅需要审核通过, 还需要那什么签名吻合, 所以得要 release 的 keystore 来签名.

## 安装

```sh
cordova plugin add com.wordsbaking.cordova.wechat --variable APP_ID=[你的APPID]
```

如果是 Visual Studio 当前的 Cordova Tools, 貌似暂时没办法设置变量, 可以自行在 plugin.xml 中替换
$APP_ID 为自己的 App ID, 并移除各平台下对应的 `<preference name="APP_ID" />`.

## 配置

### config.xml

可能需要添加一些权限, 比如安卓貌似是要添加这些:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```

反正我没添加, debug/release 都没问题, 不知道提交商店会不会有情况.

### iOS 相关: libWeChatSDK.a

src/ios/libWeChatSDK.a 这个文件有两个版本, 一个是 iPhone Only 的, 要小一些, 应该是最后生产环境用的.
我放进去的是完整版本, 要大一倍 (应该是包含了 x86 架构方便模拟器 debug), 可以自己去下载官方 SDK
然后替换掉 platforms/ios/应用名称/Plugins 目录下的 libWeChatSDK.a.

## 使用

```javascript
// 在 device ready 后.
WeChat
    .share('文本', WeChat.Scene.session, function () {
        console.log('分享成功~');
    }, function (reason) {
        console.log(reason);
    });

// 或者 (更多选项见后).
WeChat
    .share({
        title: '链接',
        description: '链接描述',
        url: 'https://wordsbaking.com/'
    }, WeChat.Scene.timeline, function () {
        console.log('分享成功~');
    }, function (reason) {
        // 分享失败
        console.log(reason);
    });

// WP 下有个问题是, 回调会调用 WP 中的另一个页面,
// 而当回调完成返回 Cordova 的页面时页面会重新加载.
// 为了让 WP 能处理回调结果, 另外添加了方法 getLastResult.
// 其他平台该方法永远失败并且 reason 的值为 'NO_RESULT'.
WeChat
    .getLastResult(function () {
        console.log('分享成功~');
    }, function (reason) {
        if (reason == 'NO_RESULT') {
            // 正常加载
        } else {
            // 分享失败
            console.log(reason);
        }
    });
```

## API 定义

```typescript
declare module WeChat {
    /** 分享场景 */
    enum Scene {
        /** 用户自选, 安卓不支持 */
        chosenByUser,
        /** 聊天 */
        session,
        /** 朋友圈 */
        timeline
    }

    /** 多媒体分享类型, 目前只支持 image, webpage */
    enum ShareType {
        app = 1,
        emotion,
        file,
        image,
        music,
        video,
        webpage
    }
    
    /** 分享选项 */
    interface IMessageOptions {
        /** 多媒体类型, 默认为 webpage */
        type: ShareType;
        /** 标题 */
        title?: string;
        /** 描述 */
        description?: string;
        /** 缩略图的 base 64 字符串 */
        thumbData?: string;
        /** 分享内容的 url, type 为 image 是就是图片的 url, 为 webpage 时就是链接的 url */
        url?: string;
        /** 分享内容的 base 64 字符串, 与 url 二选一 */
        data?: string;
    }

    // 分享.
    function share(text: string, scene: Scene, onfulfill: () => void, onreject: (reason) => void): void;
    function share(options: IMessageOptions, scene: Scene, onfulfill: () => void, onreject: (reason) => void): void;
    
    // 下面两个是我自己用的哈哈哈, 因为需要用到我的 ThenFail Promise 库.
    function share(text: string, scene: Scene): ThenFail<void>;
    function share(options: IMessageOptions, scene: Scene): ThenFail<void>;

    // 用于 WP 下获得回调结果.
    function getLastResult(onfulfill: () => void, onreject: (reason) => void): void;
    
    // 这个也需要 ThenFail 的库, 可以忽略.
    function getLastResult(): ThenFail<void>;
}
```