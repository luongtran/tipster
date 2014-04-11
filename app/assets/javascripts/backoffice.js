/*
 = require jquery
 = require jquery.turbolinks
 = require jquery_ujs
 = require_tree ../../../vendor/assets/javascripts/framework/bootstrap
 = require helper
 = require select2
 = require highcharts/highcharts
 = require bootsy
 = require common
 = require google_jsapi
 = require ajaxify
 = require turbolinks
 */
$(document).ready(function () {

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

    /* Auto hide red border after user typed */
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
    $('#available-matches-wrapper').on('click', '.btn-view-bets', function () {
        var $match_div = $(this).closest('.match');
        var $bets_wrapper = $match_div.children('.bets');
        if (!$match_div.hasClass('loaded')) {
            Helper.add_loading_indicator($bets_wrapper);
            $.ajax({
                url: $match_div.attr('data-url'),
                type: 'GET',
                dataType: 'JSON',
                success: function (response) {
                    if (response.success) {
                        $bets_wrapper.html(response.html);
                    } else {
                        Helper.alert_server_error();
                    }
                },
                complete: function () {
                    Helper.destroy_loading_indicator($bets_wrapper);
                },
                error: function () {
                    Helper.alert_server_error();
                }
            });
            $match_div.addClass('loaded');
        }
        // Toggle result
        $bets_wrapper.toggle(200);
    });

    /* Some effet when hovered on buttons */
    $('#available-matches-wrapper').on('mouseover', '.choice-odd-button', function () {
        $(this).removeClass('btn-default');
        $(this).addClass('btn-primary');
    });
    $('#available-matches-wrapper').on('mouseleave', '.choice-odd-button', function () {
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

//    $('body').on('click', '.panel-title a.collapsed', function () {
//        $('body').find('.panel').removeClass('panel-success');
//        $('body').find('.panel').addClass('panel-default');
//
//        $(this).parents('.panel:first').removeClass('panel-default');
//        $(this).parents('.panel:first').addClass('panel-success');
//    });
//
//    $('body').on('click', '.panel-title a:not(.collapsed)', function () {
//        $('body').find('.panel').addClass('panel-default');
//        $(this).parents('.panel:first').removeClass('panel-success');
//    });

    /* Create Post data and show popup to confirm select odd*/
    $('body').on('click', '.choice-odd-button', function () {

        // FIXME: this is a temporally solution
        var $modal = $('#confirm-select-odd-modal');
        var $form = $modal.find('form');

        var $button = $(this);

        var $bookmarker_code = $button.attr('data-bookmarker-code');
        $form.append('<input type="hidden" name="tip[bookmarker_code]" value="' + $bookmarker_code + '"/>');
        var match_name = $button.attr('data-match-name');
        $form.append('<input type="hidden" name="tip[match_name]" value="' + match_name + '"/>');
        var match_id = $button.attr('data-match-id');
        $form.append('<input type="hidden" name="tip[match_id]" value="' + match_id + '"/>');

        var odds_selected = $button.attr('data-odd');
        $form.append('<input type="hidden" name="tip[odds]" value="' + odds_selected + '"/>');

        var choice_name = $button.attr('data-choice-name');
        $form.append('<input type="hidden" name="tip[selection]" value="' + choice_name + '"/>');

        var bet_type_name = $button.attr('data-bet-type-name');
        $form.append('<input type="hidden" name="tip[bet_type_name]" value="' + bet_type_name + '"/>');

        var bet_type_code = $button.attr('data-bet-type-code');
        $form.append('<input type="hidden" name="tip[bet_type_code]" value="' + bet_type_code + '"/>');

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


    function doFilterMatches(form) {
        $result_wrapper = $('#available-matches-wrapper');
        form.addClass('submiting');
        $.ajax({
            url: form.attr('action'),
            type: 'GET',
            data: form.serialize(),
            dataType: 'JSON',
            success: function (response) {
                if (response.success) {
                    $result_wrapper.html('');
                    $result_wrapper.html(response.html);
                } else {
                    Helper.alert_server_error();
                }
            },
            complete: function () {
                form.removeClass('submiting');
            }
        });
    };

    /* Available matches filtering and grouping */
    $('#form-advanced-search, #form-group-method').on('submit', function () {
        doFilterMatches($(this));
        return false;
    });

    /* Prevent double submit */
    $('#form-advanced-search').on('change', 'input, select', function () {
        if (!$('#form-advanced-search').hasClass('submiting')) {
            $('#form-advanced-search').trigger('submit');
        }
    });

    $('#form-group-method').on('change', 'input[name=group_by]', function () {
        if ($(this).attr('id') !== 'switch-advanced-search-form') {
            var $form = $('#form-group-method');
            if (!$form.hasClass('submiting')) {
                $form.trigger('submit');
            }
        }
        return false;
    });

    $('.btn-filter-mode').on('click', function () {
        var $advanced_search_form = $('#advanced-search-form-wrap');
        if ($('#switch-advanced-search-form').is(':checked')) {
            if (!$advanced_search_form.is(':visible')) {
                $advanced_search_form.removeClass('hide');
            }
        } else {
            if ($advanced_search_form.is(':visible')) {
                $advanced_search_form.addClass('hide');
            }
        }
    });

    /* Reset form button*/
    // TODO: Incomplete
    $('#btn-reset-form-advanced-search-match').on('click', function () {
        var $form_search = $('form-advanced-search');
    });

    /* Left menu on available matches page */
    $('label.tree-toggler').click(function () {
        $(this).parent().children('ul.tree').toggle(300);
    });

    /* Toogle tree menu ad do filter by competition */
    $('.competitions-tree-menu').on('click', '.lk-select-competition', function () {
        $('.competitions-tree-menu .lk-select-competition.active').removeClass('active');
        $(this).addClass('active');
        var competition_id = $(this).attr('data-competition-id');
        var sport_code = $(this).attr('data-sport-code');
        var $form = $('#form-filter-available-matches');
        $form.find('.competition').val(competition_id);
        $form.find('.sport').val(sport_code);
        doFilterMatches($form);
        return false;
    });


});