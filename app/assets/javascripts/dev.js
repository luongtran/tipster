/*
 * This is a temporally file because we currently don't have template yet
 *require 'bootstrap-2.3.2.min'
 */

$(document).ready(function () {
    /* Display validate message as tooltip in the register form */
    var $inputs_in_form = $('form.form-register').find('.form-control');
    for (i = 0; i < $inputs_in_form.length; i++) {
        var $input_error = $($inputs_in_form[i]);
        if ($input_error.parent().children('.help-block').length !== 0) {
            var validate_msg = $input_error.parent().children('.help-block').text();
            $input_error.tooltip({
                title: validate_msg,
                placement: 'top',
                trigger: 'focus'
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
        $.ajax({
            type: "POST",
            url: url,
            data: {locale: lang},
            success: function (response) {
                console.log(response);
            },
            error: function () {
                console.log("Error on change language! ");
            }
        });
    });
});