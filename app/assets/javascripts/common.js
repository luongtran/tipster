/*
 Containt all functions use for both front-end vs back-end
 Ex: select box, effect, data-picker ...

 */
$(document).ready(function () {
    // To prevent double submit form
    $("form").on("submit", function (e) {
        if ($(this).hasClass("submitting")) {
            return false;
        }
        $(this).addClass("submitting");
        return true;
    });

    $('.select2able').each(function () {
        options = {
            width: 'resolve'
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

    /* For all input,select,radio element has class 'change-immediate'
     * Trigger submit the parent form if it has changed
     */
    $('.change-immediate').on('change', function () {
        $(this).closest('form').trigger('submit');
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


    /* Submit AJAX forms */
    $('.form-ajax').on('submit', function () {
        var $_this = $(this);
        $.ajax({
            url: $_this.attr('action'),
            type: $_this.attr('method'),
            dataType: 'JSON',
            data: $_this.serialize(),
            beforeSend: function () {
                // Disable submitter
                $_this.find('[type=submit]').attr('disabled', true);
                // Clear old messages
                if ($_this.find('.form-messages')) {
                    $_this.find('.form-messages').html('');
                }
            },
            success: function (response) {
                if (response.success) {
                    if ($_this.data('update-html-for')) {
                        var $replace_html_to = $($_this.data('update-html-for'));
                        if (response.html !== 'undefined') {
                            $replace_html_to.html('');
                            $replace_html_to.html(response.html);
                        }
                        // Close modal if the current form wrapp by a modal
                        if ($_this.closest('.modal').length !== 0) {
                            $_this.closest('.modal').modal('hide');
                        }
                    }
                    if (response.message) {
                        Helper.flash_message('success', response.message);
                    }
                } else {
                    if ($_this.find('.form-messages').length !== 0) {
                        Helper.flash_message('error', response.message, $_this.find('.form-messages'));
                    } else {
                        Helper.flash_message('error', response.message);
                    }
                }
            },
            complete: function () {
                // Enable submitter
                $_this.find('[type=submit]').attr('disabled', false);
            }
        });
        return false;
    });

});