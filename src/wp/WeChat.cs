/*
    Cordova WeChat Plugin
    https://github.com/vilic/cordova-plugin-wechat

    by VILIC VANE
    https://github.com/vilic

    MIT License
*/

using MicroMsg.sdk;
using System;
using System.Windows.Navigation;
using System.Runtime.Serialization;
using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;
using WPCordovaClassLib.CordovaLib;
using Windows.Phone.Storage.SharedAccess;
using Cordova.Extension.Commands;
using System.Windows;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using Microsoft.Phone.Shell;

class WeChatAssociationUriMapper : UriMapperBase {
    UriMapperBase upper;

    public WeChatAssociationUriMapper(UriMapperBase upperMapper = null) {
        upper = upperMapper;
    }

    public override Uri MapUri(Uri uri) {
        string uriStr = uri.ToString();

        if (uriStr.Contains("/FileTypeAssociation")) {
            int fileIDIndex = uriStr.IndexOf("fileToken=") + 10;
            string fileID = uriStr.Substring(fileIDIndex);
            string incommingFileName = SharedStorageAccessManager.GetSharedFileName(fileID);

            // Path.GetExtension will return String.Empty if no file extension found.
            int extensionIndex = incommingFileName.LastIndexOf('.') + 1;
            string incomingFileType = incommingFileName.Substring(extensionIndex).ToLower();

            if (incomingFileType == WeChat.appId) {
                return new Uri("/WeChatCallbackPage.xaml?fileToken=" + fileID, UriKind.Relative);
            }
        }

        if (upper != null) {
            var upperResult = upper.MapUri(uri);

            if (upperResult != uri) {
                return upperResult;
            }
        }

        return new Uri("/MainPage.xaml", UriKind.Relative);
    }
}

namespace Cordova.Extension.Commands {
    [DataContract]
    enum WeChatShareType {
        [EnumMember]
        app = 1,
        [EnumMember]
        emotion,
        [EnumMember]
        file,
        [EnumMember]
        image,
        [EnumMember]
        music,
        [EnumMember]
        video,
        [EnumMember]
        webpage
    }

    [DataContract]
    enum WeChatScene {
        [EnumMember]
        chosenByUser,
        [EnumMember]
        session,
        [EnumMember]
        timeline
    }

    [DataContract]
    class WeChatMessageOptions {
        [DataMember]
        public WeChatShareType? type;
        [DataMember]
        public string title;
        [DataMember]
        public string description;
        //[DataMember]
        //public string mediaTagName;
        [DataMember]
        public string thumbData;
        [DataMember]
        public string url;
        [DataMember]
        public string data;
    }

    [DataContract]
    class WeChatShareOptions {
        [DataMember]
        public string text;
        [DataMember]
        public WeChatMessageOptions message;
        [DataMember]
        public WeChatScene? scene;
    }

    class WeChat : BaseCommand {
        public static string appId;
        static IWXAPI api;

        public static WeChat current = null;

        public const string WECHAT_APPID_KEY = "wechatappid";
        public const string ERR_INVALID_OPTIONS = "ERR_INVALID_OPTIONS";
        public const string ERR_UNSUPPORTED_MEDIA_TYPE = "ERR_UNSUPPORTED_MEDIA_TYPE";
        public const string NO_RESULT = "NO_RESULT";

        static WeChat() {
            var streamInfo = Application.GetResourceStream(new Uri("config.xml", UriKind.Relative));

            var sr = new StreamReader(streamInfo.Stream);
            var document = XDocument.Parse(sr.ReadToEnd());

            appId = (from results in document.Descendants()
                         where results.Name.LocalName == "preference" && ((string)results.Attribute("name") == WECHAT_APPID_KEY)
                         select (string)results.Attribute("value")).First();

            api = WXAPIFactory.CreateWXAPI(appId);
        }

        public WeChat() {
            current = this;
        }

        public void share(string argsJSON) {
            var args = JsonHelper.Deserialize<string[]>(argsJSON);
            var options = JsonHelper.Deserialize<WeChatShareOptions>(args[0]);

            if (options == null) {
                dispatchResult(PluginResult.Status.JSON_EXCEPTION, ERR_INVALID_OPTIONS);
                return;
            }

            WXBaseMessage message = null;

            var messageOptions = options.message;

            if (messageOptions != null) {
                switch (messageOptions.type) {
                    case WeChatShareType.app:
                        break;
                    case WeChatShareType.emotion:
                        break;
                    case WeChatShareType.file:
                        break;
                    case WeChatShareType.image:
                        if (!String.IsNullOrEmpty(messageOptions.url)) {
                            message = new WXImageMessage(messageOptions.url);
                        } else if (!String.IsNullOrEmpty(messageOptions.data)) {
                            message = new WXImageMessage(Convert.FromBase64String(messageOptions.data));
                        } else {
                            dispatchResult(PluginResult.Status.ERROR, ERR_INVALID_OPTIONS);
                            return;
                        }
                        break;
                    case WeChatShareType.music:
                        break;
                    case WeChatShareType.video:
                        break;
                    case WeChatShareType.webpage:
                    default:
                        message = new WXWebpageMessage(messageOptions.url);
                        break;
                }

                if (message == null) {
                    dispatchResult(PluginResult.Status.ERROR, ERR_UNSUPPORTED_MEDIA_TYPE);
                    return;
                }

                message.Title = messageOptions.title;
                message.Description = messageOptions.description;

                if (!String.IsNullOrEmpty(messageOptions.thumbData)) {
                    message.ThumbData = Convert.FromBase64String(messageOptions.thumbData);
                }
            } else if (options.text != null) {
                message = new WXTextMessage(options.text);
            } else {
                dispatchResult(PluginResult.Status.ERROR, ERR_INVALID_OPTIONS);
                return;
            }

            var scene = options.scene;
            if (scene == null) {
                scene = WeChatScene.timeline;
            }

            try {
                var request = new SendMessageToWX.Req(message, (int)scene);
                api.SendReq(request);
            } catch (WXException e) {
                dispatchResult(PluginResult.Status.ERROR, e.Message);
                return;
            }
        }

        public void dispatchResult(PluginResult.Status status, string message) {
            DispatchCommandResult(new PluginResult(status, message));
        }
    }

}
