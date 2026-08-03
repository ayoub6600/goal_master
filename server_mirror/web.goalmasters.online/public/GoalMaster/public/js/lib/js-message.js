var msgObj = {
    Title: "default title",
    Message: "Default Message",
    Type: "Success",
    Icon: "far fa-check-circle",
    Url: '',
    Target: ''
};

var Message = {
    Prompt: function (customMsg) {
        if (typeof (customMsg) == "undefined")
            customMsg = "هل تريد الاستمرار؟";

        var yesNo;
        if (confirm(customMsg)) {
            yesNo = true;
        } else {
            yesNo = false;
        }
        return yesNo;
    },

    Success: function (event, url, target) {
        var saveMsg = "Successfully saved.";
        var updateMsg = "Successfully updated.";
        var deleteMsg = "Successfully deleted.";
        var cancelMsg = "Successfully cancelled";
        var rejectMsg = "Successfully rejected";
        var addMsg = "Successfully Added";


        msgObj.Title = "Success";
        msgObj.Type = "success";
        msgObj.Icon = "far fa-check-circle";
        msgObj.Url = url;
        msgObj.Target = target;

        if (event == "save") {
            msgObj.Message = saveMsg;
            Message.MainMessage(msgObj);
        } else if (event == "update") {
            msgObj.Message = updateMsg;
            Message.MainMessage(msgObj);
        } else if (event == "delete") {
            msgObj.Message = deleteMsg;
            Message.MainMessage(msgObj);
        } else if (event == "cancel") {
            msgObj.Message = cancelMsg;
            Message.MainMessage(msgObj);
        } else if (event == "reject") {
            msgObj.Message = rejectMsg;
            Message.MainMessage(msgObj);
        } else if (event == "add") {
            msgObj.Message = addMsg;
            Message.MainMessage(msgObj);
        } else {
            msgObj.Message = event;
            Message.MainMessage(msgObj);
        }
    },

    Error: function (event, url, target) {
        var saveMsg = "Failed to save.";
        var updateMsg = "Failed to update.";
        var deleteMsg = "Failed to delete.";
        var printMsg = "Failed to print";
        var cancelMsg = "Failed to cancel";
        var rejectMsg = "Failed to reject";
        var unknownMsg = "Internal server error.";
        var addMsg = "Failed to add.";

        msgObj.Title = "Error !";
        msgObj.Type = "danger";
        msgObj.Icon = "far fa-times-circle";
        msgObj.Url = url;
        msgObj.Target = target;

        if (event == "save") {
            msgObj.Message = saveMsg;
            Message.MainMessage(msgObj);
        } else if (event == "update") {
            msgObj.Message = updateMsg;
            Message.MainMessage(msgObj);
        } else if (event == "delete") {
            msgObj.Message = deleteMsg;
            Message.MainMessage(msgObj);
        } else if (event == "cancel") {
            msgObj.Message = cancelMsg;
            Message.MainMessage(msgObj);
        } else if (event == "reject") {
            msgObj.Message = rejectMsg;
            Message.MainMessage(msgObj);
        } else if (event == "add") {
            msgObj.Message = addMsg;
            Message.MainMessage(msgObj);
        } else if (event == "unknown") {
            msgObj.Message = unknownMsg;
            Message.MainMessage(msgObj);
        } else if (event == "print") {
            msgObj.Message = printMsg;
            Message.MainMessage(msgObj);
        } else {
            msgObj.Message = event;
            Message.MainMessage(msgObj);
        }
    },

    Warning: function (message, url, target) {
        msgObj.Title = "Warning !";
        msgObj.Type = "warning";
        msgObj.Message = message;
        msgObj.Icon = "fas fa-exclamation-triangle";
        msgObj.Url = url;
        msgObj.Target = target;
        Message.MainMessage(msgObj);
    },

    Notification: function (message, url, target) {
        msgObj.Title = "Warning !";
        msgObj.Type = "info";
        msgObj.Message = message;
        msgObj.Icon = "far fa-bell";
        msgObj.Url = url;
        msgObj.Target = target;
        Message.MainMessage(msgObj);
    },

    SuccessMessage: function (message, url, target) {
        msgObj.Title = "Success";
        msgObj.Type = "success";
        msgObj.Message = message;
        msgObj.Icon = "far fa-check-circle";
        msgObj.Url = url;
        msgObj.Target = target;
        Message.MainMessage(msgObj);
    },

    ErrorMessage: function (message, url, target) {
        msgObj.Title = "Error !";
        msgObj.Type = "danger";
        msgObj.Message = message;
        msgObj.Icon = "far fa-times-circle";
        msgObj.Url = url;
        msgObj.Target = target;
        Message.MainMessage(msgObj);
    },

    Exception: function (xhr) {
        var message = "";
        //server side validation
        if (xhr.responseJSON.status == 500) {
            $.each(xhr.responseJSON.data, function (i, v) {
                message += v + "</br>";
            });
        }
        //exception
        else if (xhr.responseJSON.status == 501) {
            var errorEx = xhr.responseJSON.data.errorInfo;
            if (typeof errorEx != "undefined") {
                if (errorEx[1] == 1062) {
                    //unique key
                    message += "This is already exists! (" + errorEx[2] + ")</br>";
                } else if (errorEx[1] == 1048) {
                    message += errorEx[2] + "</br>";
                } else if (errorEx[1] == 1366) {
                    message += "You have wrong input value/Data type mismatch" + "</br>";
                }else if (errorEx[1] == 1451) {
                    message += "This record already in used somewhere else." + "</br>";
                } else {
                    message += errorEx[2] + "</br>";
                }
            } else {
                message += "Internal error please contact with system administrator. </br>";
            }
        }
        //query exception
        else if (xhr.responseJSON.status == 502) {
            var errorQEx = xhr.responseJSON.data.errorInfo;
            if (typeof errorQEx != "undefined") {
                if (errorQEx[1] == 1062) {
                    //unique key
                    message += "This is already exists! (" + errorEx[2] + ")</br>";
                } else if (errorQEx[1] == 1048) {
                    message += errorQEx[2] + "</br>";
                } else {
                    message += errorEx[2] + "</br>";
                }
            } else {
                message += "Internal error please contact with system administrator. </br>";
            }
        } else if (xhr.responseJSON.status == 503) {
            message += "You have no permission";
        } else if (xhr.responseJSON.status == 505) {
            message = xhr.responseJSON.data;
        } else if (xhr.responseJSON.status < 0) {
            //show other & throwable message
            message += xhr.responseJSON.data;
        } else {
            message += "Internal error please contact with system administrator. </br>";
        }


        if (xhr.responseJSON.status == 503) {
            msgObj.Title = "Access denied!";
        } else {
            msgObj.Title = "Error !";
        }
        message = message.trimEnd('</br>');
        msgObj.Type = "danger";
        msgObj.Message = message;
        msgObj.Icon = "far fa-times-circle";
        Message.MainMessage(msgObj);
    },

    MainMessage: function (obj) {
        $.notify({
            title: obj.Title,
            message: obj.Message,
            icon: obj.Icon,
            url: obj.Url,
            target: obj.Target
        }, {
            // settings
            type: obj.Type,
            element: 'body',
            position: null,
            allow_dismiss: true,
            newest_on_top: false,
            showProgressbar: false,
            placement: {
                from: "top",
                align: "center"
            },
            offset: 20,
            spacing: 10,
            z_index: 99999,
            delay: 5000,
            timer: 1000,
            url_target: '_blank',
            mouse_over: null,
            animate: {
                enter: 'animated fadeInDown',
                exit: 'animated fadeOutUp'
            },
            onShow: null,
            onShown: null,
            onClose: null,
            onClosed: null,
            icon_type: 'class'
        });
    }


};

