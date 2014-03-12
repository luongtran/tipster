/*
 = require jquery
 = require jquery_ujs
 = require helper
 */
$(document).ready(function () {
    $('#select-sport-for-tip').on('change', function () {
        var $select_elm = $(this).children(':selected');
        $('#lk-create-new-tip').attr('href', $select_elm.attr('data-url')).removeClass('disabled');
    });
});