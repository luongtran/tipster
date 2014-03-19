/*
 = require jquery
 = require jquery.turbolinks
 = require jquery_ujs
 = require_tree ../../../vendor/assets/javascripts/framework/bootstrap
 = require helper
 = require select2
 = require turbolinks
 */
$(document).ready(function () {
    $('.select2able').each(function () {
        options = {
            width: 'resolve'
        };

        if ($(this).attr('data-no-search'))
            options['minimumResultsForSearch'] = -1; // Hide the seach box
        $(this).select2(options);
    });

    /* Step 1 */
    $('#select-sport-for-tip').on('change', function () {
        var $select_elm = $(this).children(':selected');
        var url = $select_elm.attr('data-url-for-next-step');
        $.ajax({
            url: url,
            type: 'GET',
            dataType: 'JSON',
            success: function (response) {
                console.log('Get areas successed');
                $('#select-area-for-tip').empty();
                for (i = 0; i < response.areas.length; i++) {
                    var option_html = '<option value=' + response.areas[i].id + ' data-url-for-next-step=' + response.areas[i].url + '">'
                        + response.areas[i].name + '</option>';
                    $('#select-area-for-tip').append(option_html);
                }
                $('#select-area-for-tip').select2('destroy');
                $('#select-area-for-tip').select2({
                    width: 'resolve'
                });
            }
        });
    });

    /* Step 2 */
    $('#select-area-for-tip').on('change', function () {
        var $select_elm = $(this).children(':selected');
        var url = $select_elm.attr('data-url-for-next-step');
        $.ajax({
            url: url,
            type: 'GET',
            dataType: 'JSON',
            success: function (response) {

                $('#btn-get-matches').removeClass('disabled');
                console.log('Get areas competitions');
                $('#select-competition-for-tip').empty();
                for (i = 0; i < response.competitions.length; i++) {
                    var option_html = '<option value="' + response.competitions[i].id + '">' + response.competitions[i].name + '</option>';
                    $('#select-competition-for-tip').append(option_html);
                }
                $('#select-competition-for-tip').select2('destroy');
                $('#select-competition-for-tip').select2({
                    width: 'resolve'
                });
            }
        });
    });
    $('#select-competition-for-tip').on('change', function () {
        $('#btn-get-matches').removeClass('disabled');
    });
    $('#btn-get-matches').on('click', function () {
        var $form = $('#form-get-matches');
        $.ajax({
            url: $form.attr('action'),
            data: $form.serialize(),
            type: 'GET',
            success: function (response) {
                console.log('get matches successed');
            }
        });
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

    $('.tr-details-toggable').on('click', function () {
        if (!$(this).hasClass('loaded')) {
            var match_id = $(this).attr('data-id');
            console.log('match id: ' + match_id);
            var html = '<tr class="warning"> <td colspan="4"> Details here ... </td></tr>';
            $(this).after(html);
            $(this).addClass('loaded');
        }
    });
    /* Charts */
});