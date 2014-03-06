/*
 * This is a temporally file because we currently don't have template yet
 * require 'bootstrap-2.3.2.min'
 */

$(document).ready(function () {
    $('#user_birthday').datepicker({
        forceParse: false,
        format: 'yyyy-mm-dd'
    });
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

    /* Tipster filter statuses select box */
    $('#tipster_statuses_filer').on('change', function () {
        window.location = $('#tipster_statuses_filer option:selected').attr('data-url');
        return false;
    });

    /* Languages selection */
    $('.lk-change-lang').on('click', function () {
        var lang = $(this).attr('data-lang');
        var url = $(this).attr('data-url');
        var current = window.location.pathname;
        $.ajax({
            type: "POST",
            dataType: 'json',
            url: url,
            data: {locale: lang,current_page: current},
            success: function (response) {
                if (response.success){
                 window.location = response.location;
                }
            },
            error: function (res) {
                console.log(res);
                console.log("Error on change language! ");
            }
        });
    });

    /* Check-in befor go to cart page*/
    $('#lk-view-cart.empty').on('click', function () {
        Helper.alert_warning('Your cart is empty!');
        return false;
    });
});
