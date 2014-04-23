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

    /* Auto hide red border after user typed */
    $('.form-group.has-error .form-control').on('keydown', function () {
        $(this).closest('.form-group.has-error').removeClass('has-error');
        $(this).next('.help-block').fadeOut(500);
    });

    /* Loading bet from Betclic */
    $('body').on('click', '.btn-view-odds', function () {
        var $_this = $(this);
        var $match_div = $_this.closest('.match');
        var $bets_wrapper = $match_div.children('.bets');
        if (!$match_div.hasClass('loaded')) {
            Helper.add_loading_indicator($bets_wrapper);
            $.ajax({
                url: $_this.data('url'),
                type: 'GET',
                dataType: 'JSON',
                beforeSend: function () {
                    $_this.addClass('disabled');
                },
                success: function (response) {
                    if (response.success) {
                        $bets_wrapper.html(response.html);
                    } else {
                        Helper.alert_server_error();
                    }
                },
                complete: function () {
                    $_this.removeClass('disabled');
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
    $('#bookmarker-matches-wrapper').on('mouseover', '.btn-choice-odd', function () {
        $(this).removeClass('btn-default');
        $(this).addClass('btn-primary');
    });
    $('#bookmarker-matches-wrapper').on('mouseleave', '.btn-choice-odd', function () {
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
    $('body').on('click', '.btn-choice-odd', function () {
        console.log('selected odd');
        // FIXME: this is a temporally solution
        var $modal = $('#confirm-select-odd-modal');
        var $form = $modal.find('form');

        var $button = $(this);
        var match_name = $button.data('match-name');
        var match_id = $button.data('match-id');
        $form.find('input[name="tip[match_id]"]').val(match_id);

        var odds_selected = $button.data('odds');
        $form.find('input[name="tip[odds]"]').val(odds_selected);
        $form.find('#tip-odds').text(odds_selected);

        var selection = $button.data('selection');
        $form.find('input[name="tip[selection]"]').val(selection);
        $form.find('#tip-selection').text(selection);

        var bet_type_name = $button.data('bet-type-name');
        $form.find('#tip-bet-type-name').text(bet_type_name);

        var bet_type_code = $button.data('bet-type-code');
        $form.find('input[name="tip[bet_type_code]"]').val(bet_type_code);

        var $container = $modal.find('.selection-infor');

        html = '<div class="text-center"> <strong class="match-name text-success">'
            + match_name + '</strong>'
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

    /* Search bookmarker matchs */

    function doSearchBookmarkerMatches(form) {
        var $form = $(form);
        var $result_containner = $($form.data('update-html-for'));

        $form.addClass('submiting');
        $.ajax({
            url: $form.attr('action'),
            type: $form.attr('method'),
            data: $form.serialize(),
            dataType: 'JSON',
            success: function (response) {
                if (response.success) {
                    $result_containner.html('');
                    $result_containner.html(response.html);
                } else {
                    Helper.alert_server_error();
                }
            },
            complete: function () {
                $form.removeClass('submiting');
            }
        });
    }

    $('.form-search-bookmarker-matches').on('submit', function () {
        console.log('submit');
        doSearchBookmarkerMatches(this);
        return false;
    });
});