
var JsManager = {
    SendJsonWithFile: function (type, serviceUrl, jsonParams, successCalback, errorCallback) {

        $.ajax({
            type: type,
            url: JsManager.BaseUrl() + "/" + serviceUrl,
            data: jsonParams,
            dataType: 'JSON',
            processData: false,
            contentType: false,
            success: successCalback,
            error: errorCallback
        });
    },

    SendJson: function (type, serviceUrl, jsonParams, successCalback, errorCallback) {

        $.ajax({
            cache: false,
            async: true,
            type: type,
            url: JsManager.BaseUrl() + "/" + serviceUrl,
            data: jsonParams,
            success: successCalback,
            error: errorCallback
        });

    },

    SendJsonTraditionlTrue: function (type, serviceUrl, jsonParams, successCalback, errorCallback) {

        $.ajax({
            cache: false,
            async: true,
            type: type,
            url: JsManager.BaseUrl() + "/" + serviceUrl,
            data: jsonParams,
            traditional: true,
            success: successCalback,
            error: errorCallback
        });

    },

    SendJsonAsyncON: function (type, serviceUrl, jsonParams, successCalback, errorCallback, wantJason) {
        wantJason = wantJason !== true ? '*/*' : 'application/json';
        $.ajax({
            cache: false,
            async: false,
            type: type,
            headers: {
                "Accept" : wantJason,
            },
            url: JsManager.BaseUrl() + "/" + serviceUrl,
            data: jsonParams,
            success: successCalback,
            error: errorCallback
        });

    },

    PopulateCombo: function (container, data, defaultText, defaultValue, selectedItemValue) {
        var cbmOptions = "";
        if (defaultText != null) {
            if (typeof defaultValue == "undefined") {
                defaultValue = "";
            }
            cbmOptions = "<option class='right-option' selected value=" + defaultValue + ">" + defaultText + "</option>";
        }
        $.each(data, function () {
            if (typeof selectedItemValue != 'undefined' && this.id == selectedItemValue)
                cbmOptions += '<option class="right-option" selected value=\"' + this.id + '\">' + this.name + '</option>';
            else
                cbmOptions += '<option class="right-option" value=\"' + this.id + '\">' + this.name + '</option>';
        });
        $(container).html(cbmOptions);
    },

    PopulateComboSelectPicker: function (container, data, defaultText, defaultValue, selectedItemValue) {
        var cbmOptions = "";
        if (defaultText != null) {
            if (typeof defaultValue == "undefined") {
                defaultValue = "";
            }
            cbmOptions = "<option selected value=" + defaultValue + ">" + defaultText + "</option>";
        }
        $.each(data, function () {
            if (typeof selectedItemValue != 'undefined' && this.id == selectedItemValue)
                cbmOptions += '<option selected value=\"' + this.id + '\">' + this.name + '</option>';
            else
                cbmOptions += '<option value=\"' + this.id + '\">' + this.name + '</option>';
        });
        $(container).html(cbmOptions);       
        $(container).selectpicker('refresh');
    },

    DateFormatDefault: function (val) {
        return moment(val).format('YYYY-MM-DD')
    },

    TimeToHourMinute: function (time24h) {
        return moment(time24h, "HH:mm:ss").format("HH") + ' hours ' + moment(time24h, "HH:mm:ss").format("mm") + ' minutes';
    },
    TimeToHour: function (time24h) {
        return moment(time24h, "HH:mm:ss").format("HH");
    },
    TimeToMinute: function (time24h) {
        return moment(time24h, "HH:mm:ss").format("mm");
    },
    MomentTime: function (time) {
        return moment('1990-01-01 ' + time);
    },
    ChangeDateFormat: function (value, isTime) {
        var dateFormat = "";
        if (value != "" && value != null) {
            var time = value.replace(/\/Date\(/g, "").replace(/\)\//g, "");
            var date = new Date();
            date.setTime(time);
            var dd = (date.getDate().toString().length == 2 ? date.getDate() : '0' + date.getDate()).toString();
            var mm = ((date.getMonth() + 1).toString().length == 2 ? (date.getMonth() + 1) : '0' + (date.getMonth() + 1)).toString();
            var yyyy = date.getFullYear().toString();
            var timeformat = "";
            if (isTime != 0) {
                timeformat = (date.getHours().toString().length == 2 ? date.getHours() : '0' + date.getHours()) + ':' + (date.getMinutes().toString().length == 2 ? date.getMinutes() : '0' + date.getMinutes()) + ':' + (date.getSeconds().toString().length == 2 ? date.getSeconds() : '0' + date.getSeconds());
                dateFormat = mm + '/' + dd + '/' + yyyy + ' ' + timeformat;
            }
            else {
                dateFormat = mm + '/' + dd + '/' + yyyy;
            }
        }
        return dateFormat;
    },




    DMYToMDY: function (value) {
        var datePart = value.match(/\d+/g);
        var day = datePart[0];
        var month = datePart[1];
        var year = datePart[2];
        return month + '/' + day + '/' + year;
    },
    MDYToDMY: function (value) {
        var datePart = value.match(/\d+/g);
        var month = datePart[0];
        var day = datePart[1];
        var year = datePart[2];
        return day + '/' + month + '/' + year;
    },

    DMYToYMD: function (value) {
        var datePart = value.match(/\d+/g);
        var day = datePart[0];
        var month = datePart[1];
        var year = datePart[2];
        return year + '/' + month + '/' + day;
    },

    MDYToDashDMY: function (value) {
        if (value != "") {
            var datePart = value.match(/\d+/g);
            var month = datePart[0];
            var day = datePart[1];
            var year = datePart[2];
            return day + '-' + month + '-' + year;
        }
    },


    Validate: function (obj) {
        if (obj.length > 0) {
            for (var object of obj) {
                for (var property in object) {
                    if (property.toString() != "Id") {
                        if (object[property] === "" || object[property] === "0" || object[property] === null) {
                            notif({
                                msg: property.toString() + " is required.",
                                type: "warning",
                                position: 'center',
                                autohide: false
                            });
                            return false;
                        }
                    }
                }
            }
            return true;
        }
        return false;
    },

    StartProcessBar: function (msg, width) {
        if (typeof (msg) === "undefined")
            msg = "Please Wait.....";
        if (typeof (width) === "undefined")
            width = "200px";

        var div = "<div id='ui_waitingbar' style='position: fixed;z-index: 99999;padding-top: 20%;top: 0;width: 100%;height: 100%;background: rgba(0, 0, 0, 0.18);left:0'><p style='width: " + width + ";-align: center;background: #f9f9f9;border-radius: 5px;padding: 10px 10px;margin: 0 auto;box-shadow: 2px 2px 15px #807b79;color:#565656;'><img height='30px' src='" + JsManager.BaseUrl() + "/js/lib/assets/img/temp-img/WaitingProcessBar.gif' />&nbsp" + msg + "</p></div>";
        $("#process_notifi").append(div);
    },
    EndProcessBar: function () {
        $("#ui_waitingbar").remove();
    },

    JqBootstrapValidation: function (form, onValidate) {
        $(form).find('input,select,textarea').not('[type=submit]').jqBootstrapValidation(
            {
                preventSubmit: false,
                submitSuccess: onValidate,
                submitError: function ($form, event, errors) {
                    event.preventDefault();
                }
            });
    },

    BaseUrl: function () {
        return $('meta[name="_token"]').attr('url');
    },

    UrlParams: function (k) {
        var p = {};
        location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (s, k, v) { p[k] = v });
        return k ? p[k] : p;
    }

}