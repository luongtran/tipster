$(document).ready(function () {
    if (typeof FB !== "undefined") {
        // In your onload handler add this call
        FB.init({
            appId: '548927411872156',
            status: true,
            xfbml: true
        });

        var make_request_coupon = function (data_request) {
            $.ajax({
                type: 'POST',
                url: '/subscribe/get_coupon_code',
                dataType: 'json',
                data: data_request,
                success: function (response) {
                    if (response.success) {
                        Helper.dialog_message({
                            type: 'success',
                            title: 'Information',
                            content: "“Well done, you have now a voucher of 3€"
                        });
                    } else {
                        $('#message_return').text(response.message);
                    }
                }
            });
        };

        /* Handler like FB event */
        FB.Event.subscribe('edge.create', function (href, html_element) {
            make_request_coupon({
                source: 'facebook',
                href: href
            });
        });
        //FB.Event.subscribe('edge.remove', function(href, widget) {
        //   alert('Unliked');
        // });
        //FB.Event.subscribe('message.send', function(response){
        //  alert('commented');
        //});

        /* Check FB login status */
        FB.getLoginStatus(function (response) {
            console.log(response);
            if (response.status === 'connected') {
                // the user is logged in and has authenticated your
                // app, and response.authResponse supplies
                // the user's ID, a valid access token, a signed
                // request, and the time the access token
                // and signed request each expire
                var uid = response.authResponse.userID;
                var accessToken = response.authResponse.accessToken;
            } else if (response.status === 'not_authorized') {
                // the user is logged in to Facebook,
                // but has not authenticated your app
            } else {
                $('.fb-login-button').show();
            }
        });
    }
    if (typeof twttr !== "undefined") {
        /* Handler tweet on twitter */
        twttr.events.bind('tweet', function (event) {
            make_request_coupon({
                source: 'twitter'
            });
        });
    }

    $(document).on('click', "#apply_code", function () {
        var coupon_code = $("#code").val();
        $.ajax({
            type: 'POST',
            url: '/subscribe/apply_coupon_code',
            dataType: 'json',
            data: {code: coupon_code},
            beforeSend: function () {
            },
            success: function (response) {
                if (response.success) {
                    $('#total_price').text(parseFloat($('#total_price').text()) - 3);
                    alert(response.message);
                }
                else {
                    $("#message_return").text(response.message);
                    alert(response.message);
                }
            },
            error: function () {
                console.log("AJAX ERROR");
            }
        });
    });
});
