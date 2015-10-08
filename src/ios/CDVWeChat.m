/*
    Cordova WeChat Plugin
    https://github.com/vilic/cordova-plugin-wechat

    by VILIC VANE
    https://github.com/vilic

    MIT License
*/

#import <Foundation/Foundation.h>
#import "CDVWeChat.h"

NSString* WECHAT_APPID_KEY = @"wechatappid";
NSString* ERR_WECHAT_NOT_INSTALLED = @"ERR_WECHAT_NOT_INSTALLED";
NSString* ERR_INVALID_OPTIONS = @"ERR_INVALID_OPTIONS";
NSString* ERR_UNSUPPORTED_MEDIA_TYPE = @"ERR_UNSUPPORTED_MEDIA_TYPE";
NSString* ERR_USER_CANCEL = @"ERR_USER_CANCEL";
NSString* ERR_AUTH_DENIED = @"ERR_AUTH_DENIED";
NSString* ERR_SENT_FAILED = @"ERR_SENT_FAILED";
NSString* ERR_COMM = @"ERR_COMM";
NSString* ERR_UNSUPPORT = @"ERR_UNSUPPORT";
NSString* ERR_UNKNOWN = @"ERR_UNKNOWN";
NSString* NO_RESULT = @"NO_RESULT";

const int SCENE_CHOSEN_BY_USER = 0;
const int SCENE_SESSION = 1;
const int SCENE_TIMELINE = 2;

@implementation CDVWeChat

- (void)pluginInitialize {
    NSString* appId = [[self.commandDelegate settings] objectForKey:WECHAT_APPID_KEY];
    [WXApi registerApp: appId];
}

- (void)share:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* result = nil;
    
    if (![WXApi isWXAppInstalled]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_WECHAT_NOT_INSTALLED];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return ;
    }
    
    NSDictionary* params = [command.arguments objectAtIndex:0];
    if (!params) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_INVALID_OPTIONS];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return ;
    }
    
    SendMessageToWXReq* request = [SendMessageToWXReq new];
    
    if ([params objectForKey:@"scene"]) {
        int paramScene = [[params objectForKey:@"scene"] integerValue];
        
        switch (paramScene) {
            case SCENE_SESSION:
                request.scene = WXSceneSession;
                break;
            case SCENE_CHOSEN_BY_USER:
            case SCENE_TIMELINE:
            default:
                request.scene = WXSceneTimeline;
                break;
        }
    } else {
        request.scene = WXSceneTimeline;
    }
    
    NSDictionary* messageOptions = [params objectForKey:@"message"];
    NSString* text = [params objectForKey:@"text"];
    
    if ((id)messageOptions == [NSNull null]) {
        messageOptions = nil;
    }
    if ((id)text == [NSNull null]) {
        text = nil;
    }
    
    if (messageOptions) {
        request.bText = NO;
        
        NSString* url = [messageOptions objectForKey:@"url"];
        NSString* data = [messageOptions objectForKey:@"data"];
        
        if ((id)url == [NSNull null]) {
            url = nil;
        }
        if ((id)data == [NSNull null]) {
            data = nil;
        }
        
        WXMediaMessage* message = [WXMediaMessage message];
        id mediaObject = nil;
        
        int type = [[messageOptions objectForKey:@"type"] integerValue];
        
        if (!type) {
            type = CDVWeChatShareTypeWebpage;
        }
        
        switch (type) {
            case CDVWeChatShareTypeApp:
                break;
            case CDVWeChatShareTypeEmotion:
                break;
            case CDVWeChatShareTypeFile:
                break;
            case CDVWeChatShareTypeImage:
                mediaObject = [WXImageObject object];
                if (url) {
                    ((WXImageObject*)mediaObject).imageUrl = url;
                } else if (data) {
                    ((WXImageObject*)mediaObject).imageData = [self decodeBase64:data];
                } else {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_INVALID_OPTIONS];
                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                    return ;
                }
                break;
            case CDVWeChatShareTypeMusic:
                break;
            case CDVWeChatShareTypeVideo:
                break;
            case CDVWeChatShareTypeWebpage:
            default:
                mediaObject = [WXWebpageObject object];
                ((WXWebpageObject*)mediaObject).webpageUrl = url;
                break;
        }
        
        if (!mediaObject) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_UNSUPPORTED_MEDIA_TYPE];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return ;
        }
        
        message.mediaObject = mediaObject;
        
        message.title = [messageOptions objectForKey:@"title"];
        message.description = [messageOptions objectForKey:@"description"];
        
        NSString* thumbData = [messageOptions objectForKey:@"thumbData"];
        
        if ((id)thumbData == [NSNull null]) {
            thumbData = nil;
        }
        
        if (thumbData) {
            message.thumbData = [self decodeBase64:thumbData];
        }
        
        request.message = message;
    } else if (text) {
        request.bText = YES;
        request.text = text;
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_INVALID_OPTIONS];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return ;
    }
    
    BOOL success = [WXApi sendReq:request];
    
    if (success) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_UNKNOWN];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    self.currentCallbackId = command.callbackId;
}

- (NSData*)decodeBase64:(NSString*)base64String {
    NSString* dataUrl =[NSString stringWithFormat:@"data:application/octet-stream;base64,%@", base64String];
    NSURL* url = [NSURL URLWithString: dataUrl];
    return [NSData dataWithContentsOfURL:url];
}

- (void)onResp:(BaseResp*)resp {
    if (!self.currentCallbackId) {
        return;
    }
    
    CDVPluginResult* result = nil;
    
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch (resp.errCode) {
            case WXSuccess:
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                break;
            case WXErrCodeUserCancel:
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_USER_CANCEL];
                break;
            case WXErrCodeSentFail:
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_SENT_FAILED];
                break;
            case WXErrCodeAuthDeny:
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_AUTH_DENIED];
                break;
            case WXErrCodeUnsupport:
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_UNSUPPORT];
                break;
            case WXErrCodeCommon:
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_COMM];
                break;
            default:
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERR_UNKNOWN];
                break;
        }
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:self.currentCallbackId];
    
    self.currentCallbackId = nil;
}

- (void)handleOpenURL:(NSNotification*)notification {
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:self.wechatAppId]) {
        [WXApi handleOpenURL:url delegate:self];
    }
}

- (void)isInstalled:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[WXApi isWXAppInstalled]];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

@end