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

    /* Loading bet from Betclic */
    $('#available-matches-wrapper').on('click', '.summary', function () {
        var $match_div = $(this).parent();
        var $bets_wrapper = $match_div.children('.bets');
        if (!$match_div.hasClass('loaded')) {
            Helper.add_loading_indicator($bets_wrapper);
            $.ajax({
                url: $match_div.attr('data-url'),
                type: 'GET',
                dataType: 'JSON',
                success: function (response) {
                    Helper.destroy_loading_indicator($bets_wrapper);
                    $bets_wrapper.html(response.html);
                }
            });
            $match_div.addClass('loaded');
        }
        // Toggle detail tr
        $bets_wrapper.toggle(200);
    });

    /* Some effet when hovered on buttons */
    $('.bets').on('mouseover', 'button', function () {
        $(this).removeClass('btn-default');
        $(this).addClass('btn-primary');
    });
    $('.bets').on('mouseleave', 'button', function () {
        $(this).addClass('btn-default');
        $(this).removeClass('btn-primary');
    });
    $('.lk-select-create-tip-method').on('mouseover', function () {
        $(this).removeClass('btn-default');
        $(this).addClass('btn-primary');
    });
    $('.lk-select-create-tip-method').on('mouseleave', function () {
        $(this).addClass('btn-default');
        $(this).removeClass('btn-primary');
    });

    /* Show popup to confirm select odd*/
    $('#available-matches-wrapper').on('click', '.choice-odd-button', function () {
        var $modal = $('#confirm-select-odd-modal');
        var $form = $modal.find('form');

        var $button = $(this);

        var match_name = $button.attr('data-match-name');
        $form.append('<input type="hidden" name="tip[match_name]" value="' + match_name + '"/>');
        var match_id = $button.attr('data-match-id');
        $form.append('<input type="hidden" name="tip[match_id]" value="' + match_id + '"/>');

        var odds_selected = $button.attr('data-odd');
        $form.append('<input type="hidden" name="tip[odds]" value="' + odds_selected + '"/>');

        var choice_name = $button.attr('data-choice-name');
        $form.append('<input type="hidden" name="tip[choice_name]" value="' + choice_name + '"/>');

        var bet_type_name = $button.attr('data-bet-type-name');
        $form.append('<input type="hidden" name="tip[bet_type_name]" value="' + bet_type_name + '"/>');

        var $container = $modal.find('.selection-infor');

        html = '<div class="text-center"> <strong class="match-name text-success">'
            + match_name + '</strong>'
            + '<p>'
            + '<b>' + bet_type_name + '</b>: ' + '<span class="text-danger">' + choice_name + '</span>'
            + '<br>'
            + '<b>Odds: </b>' + '<span class="text-danger">' + odds_selected + '</span>'
            + '</p>'
            + '</div>';

        $container.html(html);
        $modal.modal();
    });

    /* Toggle modal box for select method for create new tip*/
    $('#lk-toggle-select-create-tip-method').on('click', function () {
        $('#select-create-tip-method-modal').modal();
        return false;
    });
    /* Load the link of select box as links */
    $('.select-as-links').on('change', function () {
        var url = $(this).children('option:selected').attr('data-url');
        return false;
    });


    /* Available matches filtering */
    $('.available-matches-filter').on('change', function () {
        var url = $(this).children('option:selected').attr('data-url');
        var $result_wrapper = $('#available-matches-wrapper');
        $.ajax({
            url: url,
            type: 'GET',
            dataType: 'JSON',
            success: function (response) {
                if (response.success) {
                    $result_wrapper.html('');
                    $result_wrapper.html(response.html);
                }
            }
        });
    });
});