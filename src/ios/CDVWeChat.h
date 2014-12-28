//
//  CDVWeChat.h
//  HelloCordova
//
//  Created by VILIC VANE on 12/28/14.
//
//

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