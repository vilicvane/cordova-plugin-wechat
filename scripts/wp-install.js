var fs = require('fs');

module.exports = function (context) {
    var options = context.opts;
    
    var appXamlCsFile = options.projectRoot + '\\platforms\\wp8\\App.xaml.cs';
    var appXamlCsCode = fs.readFileSync(appXamlCsFile, 'utf-8');

    if (context.hook == 'after_plugin_install') {
        if (/\bWeChatAssociationUriMapper\b/.test(appXamlCsCode)) {
            return;
        }

        appXamlCsCode = appXamlCsCode
            .replace(/^((?:(?![\r\n])\s)*)RootFrame\s*=\s*new\s+PhoneApplicationFrame\(\);/m, function (m, spaces) {
                return m + '\r\n\r\n' +
                    spaces + '// Added by com.wordsbaking.cordova.wechat plugin.\r\n' +
                    spaces + 'RootFrame.UriMapper = new WeChatAssociationUriMapper(RootFrame.UriMapper);\r\n';
            });
    } else {
        appXamlCsCode = appXamlCsCode
            .replace(/\r?\n(?:(?:(?![\r\n])\s)*\/\/.+\r?\n)?\s*RootFrame\s*\.\s*UriMapper\s*=\s*new\s+WeChatAssociationUriMapper\(\s*RootFrame\s*\.\s*UriMapper\s*\)\s*;\s*\r?\n/m, '');
    }
        
    fs.writeFileSync(appXamlCsFile, appXamlCsCode);
};