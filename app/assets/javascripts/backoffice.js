/*
 = require jquery
 = require jquery_ujs
 = require_tree ../../../vendor/assets/javascripts/framework/bootstrap
 = require helper
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

    /* Auto hide red border after user typed*/
    $('.form-group.has-error .form-control').on('keydown', function () {
        $(this).closest('.form-group.has-error').removeClass('has-error');
        $(this).next('.help-block').fadeOut(500);
    });

    /* Toggle 'line' field if the selected bet type has line */
    $('#bet-types-select-for-tip').on('change', function () {
        var $selected_elm = $($(this).select2('data').element);
        if ($selected_elm.attr('data-has-line')) {
            $('#line-for-tip').removeClass('hide');
        } else {
            $('#line-for-tip').addClass('hide');
        }
    });

    /* Charts */
});