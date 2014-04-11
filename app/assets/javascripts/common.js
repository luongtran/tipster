/*
 Containt all functions use for both front-end vs back-end
 Ex: select box, effect, data-picker ...

 */
$(document).ready(function () {
    $('.select2able').each(function () {
        options = {
//            width: 'resolve'
        };
        if ($(this).attr('data-no-search'))
            options['minimumResultsForSearch'] = -1; // Hide the seach box
        $(this).select2(options);
    });

    /* Load the link of select box as links */
    $('.select-as-links').on('change', function () {
        window.location = $(this).children('option:selected').attr('data-url');
        return false;
    });

    /* Datepicker */
    $.fn.datepicker.defaults.format = "yyyy-mm-dd";
    for (i = 0; i < $('.date-picker').length; i++) {
        var endDate = '';
        var startDate = '';
        var $picker = $($('.date-picker')[i]);
        if ($picker.hasClass('limited')) {
            endDate = $picker.attr('data-max-date');
            startDate = $picker.attr('data-min-date');
        }
        $picker.datepicker({
            forceParse: false,
            endDate: endDate,
            startDate: startDate
        });
    }

});