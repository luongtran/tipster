/*
 Containt all functions use for both front-end vs back-end
 Ex: select box, effect, data-picker ...

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
});