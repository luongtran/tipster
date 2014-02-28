/*
 * This is a temporally file because we currently don't have template yet
 *require 'bootstrap-2.3.2.min'
 *require 'jquery.bootstrap.wizard.min'
 *require 'prettify'
 */

$(document).ready(function () {
    /* Tipster filter statuses select box */
    $('#tipster_statuses_filer').on('change', function () {
        console.log('changed');
        var $selected_em = $('#tipster_statuses_filer option:selected');
        var url = $selected_em.attr('data-url');
        window.location = url;
        return false;
    });
});
function select_lang(lang){
    $.ajax({
        type: "POST",
        url: '/home/select_language',
        data: {locale: lang},
        success: function(response){
            console.log(response);
        },
        error: function(){
            console.log("Error on change language! ")

        }
    });
}