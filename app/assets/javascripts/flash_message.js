(function () {
    $(function () {
        var flashCallback;
        flashCallback = function () {
            return $(".alert").fadeOut();
        };
        $(".alert").bind('click', (function (_this) {
            return function (ev) {
                return $(".alert").fadeOut();
            };
        })(this));
        return setTimeout(flashCallback, 7000);
    });
}).call(this);