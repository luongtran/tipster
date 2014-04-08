/*
 = require jquery
 = require jquery.turbolinks
 = require_tree ../../../vendor/assets/javascripts/framework/bootstrap
 = require helper
 = require select2
 = require highcharts/highcharts
 = require bootsy
 = require common
 = require ajaxify
 = require turbolinks
 */

$(document).ready(function () {
    /* Toogle reject tip modal */
    $('.btn-reject-tip').on('click', function () {
        var $modal = $('#reject-tip-modal');
        $modal.find('form').attr('action', $(this).attr('data-url'));
        $modal.modal();
        return false;
    });
    $('#reject-tip-modal form').on('submit', function () {
        var $modal = $('#reject-tip-modal');
        if ($modal.find('#input-reason').val().trim().length === 0) {
            $modal.find('.error-message-container').html('The reason cannot leave blank!');
            return false;
        }
    });
    /* Toogle publish tip modal */
    $('.btn-publish-tip').on('click', function () {
        var $modal = $('#publish-tip-modal');
        $modal.find('form').attr('action', $(this).attr('data-url'));
        $modal.modal();
        return false;
    });

});