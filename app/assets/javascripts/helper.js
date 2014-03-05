Helper = {
    scroll_to: function (element, delay_time, container, offset) {
        if (!container)
            container = 'html, body';
        if (!delay_time)
            delay_time = 300;
        if (!offset)
            offset = 10;
        $(container).animate({ scrollTop: $(element).offset().top - offset}, delay_time);
    },

    create_message_panel: function (type, message) {
        var div = $('<div data-alert="alert" class="alert fade in">' +
            '<a href="#" data-dismiss="alert" class="close">&times;</a></div>');
        $(div).addClass("alert-" + type);
        $(div).append(message);
        return $(div);
    },

    /* Maintain
     confirm_delete_modal: function (message, delete_url) {
     var html =
     '<div class="modal fade"> \
     <div class="modal-header"> \
     <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button> \
     <h3 class="text-warning"> Confirmation </h4> \
     </div> \
     <div class="modal-body text-center">  \
     <p style="font-size: 16px;">An error has occurred. The operation could not be completed.</p> \
     </div> \
     <div class="modal-footer"> \
     <form url="' + delete_url '" method="POST">\
     \
     <a href="#" class="btn btn-default" data-dismiss="modal" aria-hidden="true">Close</a> \
     </form>\
     </div> \
     </div>';
     },
     */
    // Append a message panel to #flash element.
    flash_message: function (type, message, delay_time, container, append) {
        var msg = this.create_message_panel(type, message);

        if (!container)
            container = "#flash";
        if (append)
            $(container).append(msg);
        else
            $(container).html(msg);

        if (typeof(delay_time) != "undefined" && delay_time && !isNaN(delay_time)) {
            setTimeout(function () {
                $(msg).fadeOut(function () {
                    $(msg).remove();
                    $(container).show();
                });
            }, delay_time);
        }
    },
    // To prevent double submit on some old browsers like Safari,...
    // This script can combine with Rails option :disable_with => ""
    prevent_double_submit: function () {
        $("form").on("submit", function (e) {
            if ($(this).hasClass("submitting")) {
                return false;
            }
            $(this).addClass("submitting");
            return true;
        });
    },
    alert_server_error: function () {
        var html =
            '<div class="modal fade"> \
             <div class="modal-dialog"> \
                <div class="modal-content"> \
                    <div class="modal-body text-center text-danger">  \
                     <p> An error has occurred. The operation could not be completed. </p> \
                      <a href="#" class="btn btn-default" data-dismiss="modal" aria-hidden="true">Close</a> \
                    </div> \
                </div> \
           </div> \
      </div>';
        $(html).modal('show');
    },
    alert_warning: function (content) {
        if (content == 'undefined') {
            return false;
        }
        var html =
            '<div class="modal fade"> \
             <div class="modal-dialog"> \
                <div class="modal-content"> \
                    <div class="modal-body text-center text-warning">  \
                       <p style="font-size: 15px;">' + content + '</p> \
                       <a href="#" class="btn btn-default" data-dismiss="modal" aria-hidden="true">Close</a> \
                    </div> \
                </div> \
           </div> \
      </div>';
        $(html).modal('show');
    },
    dialog_message: function (options) {
        // All options.
        var default_options = {
            type: 'normal',
            title: "Alert",
            content: ""
        };
        if (!options) {
            options = {};
        }
        // Set default options.
        options = jQuery.extend(default_options, options);
        var html =
            '<div class="modal fade"> \
                 <div class="modal-dialog"> \
                     <div class="modal-content"> \
                         <div class="modal-header"> \
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button> \
                            <h4 class="modal-title">' + options.title + '</h4> \
                         </div> \
                         <div class="modal-body text-center text-' + options.type + '">  \
                            <p style="font-size: 15px;">' + options.content + '</p> \
                         </div> \
                         <div class="modal-footer"> \
                            <a href="#" class="btn btn-default" data-dismiss="modal" aria-hidden="true">Close</a> \
                         </div> \
                     </div> \
                 </div> \
            </div>';
        $(html).modal('show');
    },

    escape_html: function (html) {
        if (html) return $('<div />').text(html).html();
    }
};
