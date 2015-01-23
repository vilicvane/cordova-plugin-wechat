package com.wordsbaking.cordova.wechat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Base64;

import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.SendMessageToWX;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.mm.sdk.openapi.WXMediaMessage;
import com.tencent.mm.sdk.openapi.WXTextObject;
import com.tencent.mm.sdk.openapi.WXImageObject;
import com.tencent.mm.sdk.openapi.WXWebpageObject;

/*
    Cordova WeChat Plugin
    https://github.com/vilic/cordova-plugin-wechat

    by VILIC VANE
    https://github.com/vilic

    MIT License
*/

public class WeChat extends CordovaPlugin {

    public static final String WECHAT_APPID_KEY = "wechatappid";

    public static final String ERR_WECHAT_NOT_INSTALLED = "ERR_WECHAT_NOT_INSTALLED";
    public static final String ERR_INVALID_OPTIONS = "ERR_INVALID_OPTIONS";
    public static final String ERR_UNSUPPORTED_MEDIA_TYPE = "ERR_UNSUPPORTED_MEDIA_TYPE";
    public static final String ERR_USER_CANCEL = "ERR_USER_CANCEL";
    public static final String ERR_AUTH_DENIED = "ERR_AUTH_DENIED";
    public static final String ERR_SENT_FAILED = "ERR_SENT_FAILED";
    public static final String ERR_UNSUPPORT = "ERR_UNSUPPORT";
    public static final String ERR_COMM = "ERR_COMM";
    public static final String ERR_UNKNOWN = "ERR_UNKNOWN";
    public static final String NO_RESULT = "NO_RESULT";

    public static final int SHARE_TYPE_APP = 1;
    public static final int SHARE_TYPE_EMOTION = 2;
    public static final int SHARE_TYPE_FILE = 3;
    public static final int SHARE_TYPE_IMAGE = 4;
    public static final int SHARE_TYPE_MUSIC = 5;
    public static final int SHARE_TYPE_VIDEO = 6;
    public static final int SHARE_TYPE_WEBPAGE = 7;

    public static final int SCENE_CHOSEN_BY_USER = 0;
    public static final int SCENE_SESSION = 1;
    public static final int SCENE_TIMELINE = 2;

    public static IWXAPI api;
    public static CallbackContext currentCallbackContext;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        String appId = preferences.getString(WECHAT_APPID_KEY, "");
        api = WXAPIFactory.createWXAPI(webView.getContext(), appId, true);
        api.registerApp(appId);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
            throws JSONException {
        if (action.equals("share")) {
            share(args, callbackContext);
        } else {
            return false;
        }
        return true;
    }

    private void share(JSONArray args, CallbackContext callbackContext)
            throws JSONException, NullPointerException {
        // check if installed
        if (!api.isWXAppInstalled()) {
            callbackContext.error(ERR_WECHAT_NOT_INSTALLED);
            return;
        }

        JSONObject params = args.getJSONObject(0);

        if (params == null) {
            callbackContext.error(ERR_INVALID_OPTIONS);
            return;
        }

        SendMessageToWX.Req request = new SendMessageToWX.Req();

        request.transaction = String.valueOf(System.currentTimeMillis());

        int paramScene = params.getInt("scene");

        switch (paramScene) {
            case SCENE_SESSION:
                request.scene = SendMessageToWX.Req.WXSceneSession;
                break;
            // wechat android sdk does not support chosen by user
            case SCENE_CHOSEN_BY_USER:
            case SCENE_TIMELINE:
            default:
                request.scene = SendMessageToWX.Req.WXSceneTimeline;
                break;
        }

        WXMediaMessage message = null;

        String text = null;
        JSONObject messageOptions = null;

        if (!params.isNull("text")) {
            text = params.getString("text");
        }

        if (!params.isNull("message")) {
            messageOptions = params.getJSONObject("message");
        }

        if (messageOptions != null) {
            String url = null;
            String data = null;

            if (!messageOptions.isNull("url")) {
                url = messageOptions.getString("url");
            }

            if (!messageOptions.isNull("data")) {
                data = messageOptions.getString("data");
            }

            int type = SHARE_TYPE_WEBPAGE;

            if (!messageOptions.isNull("type")) {
                type = messageOptions.getInt("type");
            }

            switch (type) {
                case SHARE_TYPE_APP:
                    break;
                case SHARE_TYPE_EMOTION:
                    break;
                case SHARE_TYPE_FILE:
                    break;
                case SHARE_TYPE_IMAGE:
                    WXImageObject imageObject = new WXImageObject();
                    if (url != null) {
                        imageObject.imageUrl = url;
                    } else if (data != null) {
                        imageObject.imageData = Base64.decode(data, Base64.DEFAULT);
                    } else {
                        callbackContext.error(ERR_INVALID_OPTIONS);
                        return;
                    }
                    message = new WXMediaMessage(imageObject);
                    break;
                case SHARE_TYPE_MUSIC:
                    break;
                case SHARE_TYPE_VIDEO:
                    break;
                case SHARE_TYPE_WEBPAGE:
                default:
                    WXWebpageObject webpageObject = new WXWebpageObject();
                    webpageObject.webpageUrl = url;
                    message = new WXMediaMessage(webpageObject);
                    break;
            }

            if (message == null) {
                callbackContext.error(ERR_UNSUPPORTED_MEDIA_TYPE);
                return;
            }

            if (!messageOptions.isNull("title")) {
                message.title = messageOptions.getString("title");
            }

            if (!messageOptions.isNull("description")) {
                message.description = messageOptions.getString("description");
            }

            if (!messageOptions.isNull("thumbData")) {
                String thumbData = messageOptions.getString("thumbData");
                message.thumbData = Base64.decode(thumbData, Base64.DEFAULT);
            }
        } else if (text != null) {
            WXTextObject textObject = new WXTextObject();
            textObject.text = text;

            message = new WXMediaMessage(textObject);
            message.description = text;
        } else {
            callbackContext.error(ERR_INVALID_OPTIONS);
            return;
        }

        request.message = message;

        try {
            boolean success = api.sendReq(request);
            if (!success) {
                callbackContext.error(ERR_UNKNOWN);
                return;
            }
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
            return;
        }

        currentCallbackContext = callbackContext;
    }
}