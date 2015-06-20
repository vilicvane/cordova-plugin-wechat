/*
    Cordova WeChat Plugin
    https://github.com/vilic/cordova-plugin-wechat

    by VILIC VANE
    https://github.com/vilic

    MIT License
*/

exports.share = function (message, scene, onfulfilled, onrejected) {
    var ThenFail = window.ThenFail;
    var promise;

    if (ThenFail && !onfulfilled && !onrejected) {
        promise = new ThenFail();
    }

    var text = null;

    if (typeof message == 'string') {
        text = message;
        message = null;
    }

    cordova
        .exec(function () {
            if (promise) {
                promise.resolve();
            } else if (onfulfilled) {
                onfulfilled();
            }
        }, function (err) {
            if (promise) {
                promise.reject(err);
            } else if (onrejected) {
                onrejected(err);
            }
        }, 'WeChat', 'share', [
            {
                message: message,
                text: text,
                scene: scene
            }
        ]);

    return promise;
};

exports.Scene = {
    chosenByUser: 0,
    session: 1,
    timeline: 2
};

exports.ShareType = {
    app: 1,
    emotion: 2,
    file: 3,
    image: 4,
    music: 5,
    video: 6,
    webpage: 7
};

exports.login = function (scope, state, onfulfill, onreject) {
    var ThenFail = window.ThenFail;
    var promise;

    if (ThenFail && !onfulfill && !onreject) {
        promise = new ThenFail();
    }

    cordova
        .exec(function () {
            if (promise) {promise.resolve();}
            if (onfulfill) {onfulfill();}
        }, function (err) {
            if (promise) {promise.reject(err);}
            if (onreject) {onreject(err);}
        }, 'WeChat', 'login', [
            {
                scope: scope,
                state: state
            }
        ]);

    return promise;
};

exports.isInstalled = function (onfulfill, onreject) {
    var ThenFail = window.ThenFail;
    var promise;

    if (ThenFail && !onfulfill && !onreject) {
        promise = new ThenFail();
    }

    cordova
        .exec(function (isInstalled) {
            if (promise) {promise.resolve(isInstalled);}
            if (onfulfill) {onfulfill(isInstalled);}
        }, function (err) {
            if (promise) {promise.reject(err);}
            if (onreject) {onreject(err);}
        }, 'WeChat', 'isInstalled', []);

    return promise;
};
