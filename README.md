# Cordova 微信分享插件

Inspired by https://github.com/xu-li/cordova-plugin-wechat  
其实本来 fork 了, 但因为一方面没有支持 Windows Phone, 另一方面 Android 的支持也很有限, 所以重写了.

跟着就写 iOS.

目前只支持文本, 图片, 和链接分享.

## 安装

```sh
plugman --platform [wp8|android] --project [project-directory] --plugin com.wordsbaking.cordova.wechat
```

## 配置

### config.xml

在 widget 元素下, 添加一个 preference.

```xml
<preference name="WECHAT_APPID" value="你的APPID" />
```

另外因为牵涉到回调, 配置没法完全在 config.xml 中完成, 还需要修改一些插件文件.

### plugin.xml

打开插件的 plugin.xml 文件 (比如可能在目录 plugins/com.wordsbaking.cordova.wechat 下),
在各个平台对应的配置内, 按照注释将相关 App ID 替换为自己的.

Android 平台还需要按照注释修改插件目录下, src/android 目录中的 WXEntryActivity.java 文件的包名,
以及该文件的 source-file 配置对应的 target-dir.

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