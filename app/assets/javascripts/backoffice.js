/*
 = require jquery
 = require jquery_ujs
 = require_tree ../../../vendor/assets/javascripts/framework/bootstrap
 = require helper
 = require highcharts
 = require select2
 */
$(document).ready(function () {
    $('.select2able').each(function () {
        options = {};
        if ($(this).attr('data-no-search'))
            options['minimumResultsForSearch'] = -1; // Hide the seach box
        $(this).select2(options);
    });
    $('#select-sport-for-tip').on('change', function () {
        var $select_elm = $(this).children(':selected');
        $('#lk-create-new-tip').attr('href', $select_elm.attr('data-url')).removeClass('disabled');
    });

    /* Charts */
});