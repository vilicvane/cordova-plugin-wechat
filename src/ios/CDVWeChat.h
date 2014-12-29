/*
    Cordova WeChat Plugin
    https://github.com/vilic/cordova-plugin-wechat

    by VILIC VANE
    https://github.com/vilic

    MIT License
*/

#import <Cordova/CDV.h>
#import "WXApi.h"

enum CDVWeChatShareType {
    CDVWeChatShareTypeApp = 1,
    CDVWeChatShareTypeEmotion,
    CDVWeChatShareTypeFile,
    CDVWeChatShareTypeImage,
    CDVWeChatShareTypeMusic,
    CDVWeChatShareTypeVideo,
    CDVWeChatShareTypeWebpage
};

@interface CDVWeChat: CDVPlugin <WXApiDelegate>

@property (nonatomic, strong) NSString *currentCallbackId;
@property (nonatomic, strong) NSString *wechatAppId;

- (void)share:(CDVInvokedUrlCommand *)command;
- (void)getLastResult:(CDVInvokedUrlCommand *)command;

@end