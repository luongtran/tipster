/*
 = require jquery
 = require jquery_ujs
 = require helper
 = require select2
 */
$(document).ready(function () {
    $('select').select2();
    $('#select-sport-for-tip').on('change', function () {
        var $select_elm = $(this).children(':selected');
        $('#lk-create-new-tip').attr('href', $select_elm.attr('data-url')).removeClass('disabled');
    });


});