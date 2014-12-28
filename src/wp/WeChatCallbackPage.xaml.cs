/*
    Cordova WeChat Plugin
    https://github.com/vilic/cordova-plugin-wechat

    by VILIC VANE
    https://github.com/vilic

    MIT License
*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Shell;
using MicroMsg.sdk;
using Cordova.Extension.Commands;
using WPCordovaClassLib.Cordova;

namespace Cordova.Extension {
    public partial class WeChatCallbackPage : WXEntryBasePage {
        public WeChatCallbackPage() {
            InitializeComponent();
        }

        public override void On_GetMessageFromWX_Request(GetMessageFromWX.Req request) {
            // not implemented
            goBack();
        }

        public override void On_SendMessageToWX_Response(SendMessageToWX.Resp response) {
            WeChat.response = response;
            goBack();
        }

        public override void On_SendAuth_Response(SendAuth.Resp response) {
            // not implemented
            goBack();
        }

        void goBack() {
            if (NavigationService.CanGoBack) {
                NavigationService.GoBack();
            } else {
                NavigationService.Navigate(new Uri("/MainPage.xml", UriKind.Relative));
                NavigationService.RemoveBackEntry();
            }
        }
    }
}