$(document).ready(function () {
    /* Datepicker for birthday all other */
    $.fn.datepicker.defaults.format = "yyyy-mm-dd";
    for (i = 0; i < $('.date-picker').length; i++) {
        var endDate = '';
        var $picker = $($('.date-picker')[i]);
        if ($picker.hasClass('limited')) {
            endDate = $picker.attr('data-max-date');
        }
        $picker.datepicker({
            forceParse: false,
            endDate: endDate
        });
    }

    /* Require checked term & conditions */
    $('form.form-register').on('submit', function () {
        var $cb_term = $(this).find('#cb-term-and-conditions');
        if (!$cb_term.is(':checked')) {
            Helper.alert_warning('You must to aggree with our terms and conditions');
            return false;
        }
    });

    /* Display validate message as tooltip in the register form */
    var $inputs_in_form = $('form.form-register').find('.form-control');
    for (i = 0; i < $inputs_in_form.length; i++) {
        var $input_error = $($inputs_in_form[i]);
        if ($input_error.parent().children('.help-block').length !== 0) {
            var validate_msg = $input_error.parent().children('.help-block').text();
            $input_error.tooltip({
                title: validate_msg,
                placement: 'top',
                trigger: 'manual'
            });
            $input_error.tooltip('show');
            /* Hidden tooltip after the click to the error input */
            $input_error.on('click', function () {
                $(this).tooltip('destroy');
            });
        }
    }

    /* Show confirm to checkout modal after add a tipster to cart */
    $('#modal-confirm-checkout').modal();
    $('#change-tipster').on('click',function(){
        $('#modal-change-tipster').modal();
    });
    $('#change-plan').on('click',function(){
        $('#modal-change-plan').modal();
    });

    $('.lk-toggle-sign-up-box').on('click', function () {
        $('.modal[aria-hidden="false"]').modal('hide');
        $('#sign-up-modal-box').modal({
            keyboard: false
        });
    });
    $('.lk-toggle-sign-in-box').on('click', function () {
        $('.modal[aria-hidden="false"]').modal('hide');
        $('#sign-in-modal-box').modal({
            keyboard: false
        });
    });

    /* Auto expand dropdown */
    $('#menu-main li.dropdown:not(.open)').mouseover(function () {
        $(this).addClass('open');
    });

    /* Load the link of select box as links */
    $('.select-as-links').on('change', function () {
        window.location = $(this).children('option:selected').attr('data-url');
        return false;
    });

    /* Languages selection */
    $('.lk-change-lang:not(.current)').on('click', function () {
        var lang = $(this).attr('data-lang');
        var url = $(this).attr('data-url');
        var current_location = window.location.pathname;
        $.ajax({
            type: 'POST',
            dataType: 'json',
            url: url,
            data: {locale: lang},
            success: function (response) {
                window.location = current_location;
            },
            error: function (response) {
                Help.alert_server_error();
            }
        });
    });

    /* Check-in befor go to cart page*/
    $('#lk-view-cart.empty').on('click', function () {
        Helper.alert_warning('Your cart is empty!');
        return false;
    });

    /* Sign in/up submiting */
    $('#sign-up-modal-box #sign-up-form').on('submit', function () {
        var $form = $(this);
        var url = $form.attr('action');
        var $submmiter = $form.find('#submiter');
        $.ajax({
            type: 'POST',
            dataType: 'JSON',
            url: url,
            data: $form.serialize(),
            beforeSend: function () {
                $submmiter.addClass('in-progress');
                $submmiter.attr('disabled', true);
                $('.tooltip ').hide();
            },
            success: function (response) {
                if (response.success) {
                    window.location = response.path;
                } else {
                    // show error as tooltip
                    for (field in response.errors) {
                        var $input_error = $('#' + field);
                        var validate_msg = response.errors[field];
                        $input_error.tooltip({
                            title: validate_msg,
                            placement: 'top',
                            trigger: 'manual',
                            delay: { show: 500}
                        });
                        $input_error.tooltip('show');
                        $input_error.on('click', function () {
                            $(this).tooltip('destroy');
                        });
                    }
                }
            },
            complete: function () {
                $submmiter.removeClass('in-progress');
                $submmiter.attr('disabled', false);
            }
        });
        return false;
    });
    $('#sign-in-modal-box #sign-in-form').on('submit', function () {
        var $form = $(this);
        var url = $form.attr('action');
        var $submmiter = $form.find('#submiter');
        $.ajax({
            type: 'POST',
            dataType: 'JSON',
            url: url,
            data: $form.serialize(),
            beforeSend: function () {
                $submmiter.addClass('in-progress');
                $submmiter.attr('disabled', true);
            },
            success: function (response) {
                if (response.success) {
                    window.location = response.path;
                } else {
                    // show error as message
                    Helper.flash_message('danger', response.error, 5000, '#sign-in-message-container');
                }
            },
            complete: function () {
                $submmiter.removeClass('in-progress');
                $submmiter.attr('disabled', false);
            },
            error: function (res) {
            }
        });
        return false;
    });


    $('#form-receive-tip-methods').on('submit', function () {
        var $check_boxs = $(this).find('input[type=checkbox]');
        var valid = false;
        for (i = 0; i < $check_boxs.length; i++) {
            if ($check_boxs.is(':checked')) {
                valid = true;
                break;
            }
        }
        if (!valid) {
            Helper.alert_warning('Please choose at leat one method');
            return false;
        }
    });
    $('#form-select-payment').on('submit', function () {

        var valid = $('#cb-term-and-conditions').is(':checked');
        if (!valid) {
            Helper.alert_warning("Please accept term and conditions about paypal payment .... !");
            return false;
        }

    })


    /* Background switching */
    // order following: football, tennis, basket,
//    if (localStorage.getItem('bgs') == null) {
//        // AJAX REQUEST TO GET BACKGROUND LIST
//
//        localStorage["bgs"] = JSON.stringify(bgs);
//    }
//    var bg_urls = JSON.parse(localStorage["bgs"]);
    var bgs = [
        '/backgrounds/01.jpg',
        '/backgrounds/02.jpg',
        '/backgrounds/03.jpg',
        '/backgrounds/06.jpg',
        '/backgrounds/08.png',
        '/backgrounds/09.png',
        '/backgrounds/10.jpg',
        '/backgrounds/11.jpg'
    ];
    var current_url_index = 0;
    setInterval(
        function () {
//            var random_index = Math.random() * 5 | 0;
            if ((current_url_index + 1) == bgs.length) {
                current_url_index = 0;
            }
            $('#page_header_mid:not(.fixed-bg)').animate(
                {opacity: 0.6},
                1500,
                function () {
                    $(this)
                        .css({'background-image': 'url("' + bgs[current_url_index] + '")'})
                        .animate(
                        {opacity: 1},
                        1500
                    );
                });

            current_url_index++;
        }, 8000
    );
    var AvatarCropper,
        __bind = function (fn, me) {
            return function () {
                return fn.apply(me, arguments);
            };
        };

    jQuery(function () {
        return new AvatarCropper();
    });

    AvatarCropper = (function () {
        function AvatarCropper() {
            this.updatePreview = __bind(this.updatePreview, this);
            this.update = __bind(this.update, this);
            $('#cropbox').Jcrop({
                aspectRatio: 1,
                setSelect: [0, 0, 600, 600],
                onSelect: this.update,
                onChange: this.update
            });
        }

        AvatarCropper.prototype.update = function (coords) {
            $('#user_crop_x').val(coords.x);
            $('#user_crop_y').val(coords.y);
            $('#user_crop_w').val(coords.w);
            $('#user_crop_h').val(coords.h);
            return this.updatePreview(coords);
        };

        AvatarCropper.prototype.updatePreview = function (coords) {
            return $('#preview').css({
                width: Math.round(100 / coords.w * $('#cropbox').width()) + 'px',
                height: Math.round(100 / coords.h * $('#cropbox').height()) + 'px',
                marginLeft: '-' + Math.round(100 / coords.w * coords.x) + 'px',
                marginTop: '-' + Math.round(100 / coords.h * coords.y) + 'px'
            });
        };

        return AvatarCropper;

    })();
});
