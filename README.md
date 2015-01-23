# Cordova/PhoneGap 微信分享插件

Inspired by https://github.com/xu-li/cordova-plugin-wechat

支持 iOS, WP, Android, 都有回调. 分享内容只支持文本, 图片, 和链接.

**另外需要注意的是 Android 不仅需要审核通过, 还需要那什么签名吻合, 所以得要 release 的 keystore 来签名.**
关于这个问题写了个指南, 如果 Android 搞不定的可以看看
[Android 微信 SDK 签名问题](https://github.com/vilic/cordova-plugin-wechat/wiki/Android-%E5%BE%AE%E4%BF%A1-SDK-%E7%AD%BE%E5%90%8D%E9%97%AE%E9%A2%98).

## 安装

一定不要忘记加上后面的 `--variable APP_ID=********`.

```sh
cordova plugin add com.wordsbaking.cordova.wechat --variable APP_ID=[你的APPID]
```

另外貌似 Cordova 的变量信息是按平台保存的, 如果安装插件时尚未添加某个平台, 即便之前加上了变量,
之后添加平台时依旧会报错. 此时可以先卸载插件, 添加平台后带上变量重新安装.

如果是 Visual Studio Tools for Apache Cordova, 可以这样配置 App ID:

```xml
<vs:plugin name="com.wordsbaking.cordova.wechat" version="0.3.0">
    <param name="APP_ID" value="[你的APPID]" />
</vs:plugin>
```

## 配置

其实安装后就可以用了! 零配置哟哈哈哈! 下面列一些注意事项.

### config.xml

**可能**需要添加一些权限, 比如安卓貌似是要添加这些:

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
    
    // 下面两个是我自己用的哈哈哈, 因为需要用到我的 [ThenFail (Promises/A+ 实现)](https://github.com/vilic/thenfail).
    function share(text: string, scene: Scene): ThenFail<void>;
    function share(options: IMessageOptions, scene: Scene): ThenFail<void>;
}
```