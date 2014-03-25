/* Loading content via AJAX */
/* Author: Lht */

$(document).ready(function () {
        var ajax_method = 'GET';
        var $content_by_ajaxs = $('.remote-data:not(.loaded)');
        if ($content_by_ajaxs.length !== 0) {
            for (i = 0; i < $content_by_ajaxs.length; i++) {
                var $content_ajax_able = $($content_by_ajaxs[i]);
                if (typeof($content_ajax_able.attr('data-url')) == 'undefined') {
                    break;
                }
                var url = $content_ajax_able.attr('data-url');
                $.ajax({
                    type: ajax_method,
                    url: url,
                    beforeSend: function () {
                        Helper.add_loading_indicator($content_ajax_able);
                    },
                    success: function (response) {
                        if (response.success) {
                            $content_ajax_able.append(response.html);
                        } else {
                            Helper.alert_warning('Error while loading');
                        }
                    },
                    complete: function () {
                        Helper.destroy_loading_indicator($content_ajax_able);
                        $content_ajax_able.addClass('loaded');
                    },
                    error: function () {
                        Helper.alert_server_error();
                    },
                });
            }
        }
    }
)
;