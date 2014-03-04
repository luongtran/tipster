/*
 * This is a temporally file because we currently don't have template yet
 *require 'bootstrap-2.3.2.min'
 */

$(document).ready(function () {

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