
var EventManager;
var dTableManager;
var timeFormat = 'H:i';
var dateFormat = 'Y-m-d';
var dateTimeFormat = 'Y-m-d H:m';
var Utility;

// function isValidEmail(email) {
//     var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
//     return regex.test(email);
// }


(function ($) {
    "use strict";
    $(document).ready(function () {

        //$.datetimepicker.setLocale('el');

        $("#cmbLang").on("change",function(event){
            event.preventDefault();
            document.getElementById('language-change-form').submit();
        });
        $("#app-logout").on("click", function (event) {
            event.preventDefault();
            document.getElementById('logout-form').submit();
        });

        /* menu color change */
        $('.sidebar').removeAttr('data-background-color');
        $('.sidebar').attr('data-background-color', 'dark2');

        $('.logo-header').removeAttr('data-background-color');
        $('.logo-header').attr('data-background-color', 'dark2');
        /*end menu color*/

        $('.datePicker').datetimepicker({
            datepicker: true,
            format: dateFormat,
            timepicker: false
        });

        $('.dateTimepPckerMinDateToday').datetimepicker({
            datepicker: true,
            format: dateTimeFormat,
            timepicker: true,
            minDate: new Date()
        });

        $('.dateTimepPcker').datetimepicker({
            datepicker: true,
            format: dateTimeFormat,
            timepicker: true
        });

        $('.startTime').datetimepicker({
            datepicker: false,
            format: timeFormat,
            step: 5,
            onShow: function (ct) {
                this.setOptions({
                    maxTime: $('.endTime').val() ? $('.endTime').val() : false
                })
            }
        });
        $('.endTime').datetimepicker({
            datepicker: false,
            format: timeFormat,
            step: 5,
            onShow: function (ct) {
                this.setOptions({
                    minTime: $('.startTime').val() ? $('.startTime').val() : false
                })
            }
        });

        $('.startDate').datetimepicker({
            datepicker: true,
            timepicker: false,
            format: dateFormat,
            onShow: function (ct) {
                this.setOptions({
                    maxDate: $('.endDate').val() ? $('.endDate').val() : false
                })
            }
        });
        $('.endDate').datetimepicker({
            datepicker: true,
            timepicker: false,
            format: dateFormat,
            onShow: function (ct) {
                this.setOptions({
                    minDate: $('.startDate').val() ? $('.startDate').val() : false
                })
            }
        });

        /*left side menu active*/
        $(".sidebar .sidebar-content .nav-item ul li").each(function () {
            let path = $(this).find('a').attr('href');
            if (path == window.location.href) {
                $(this).addClass('active');
                $(this).parents('.nav-item').addClass('submenu active');
                $(this).parents('.nav-item').find('div').addClass('show');
            }
        });

         $(".dataTables_filter").remove('Search:');

    });

    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
    });

    $("input").attr("autocomplete", "off");

    Utility = {
        GetUrlParamValue: function (paramKey) {
            var url = new URL(window.location.href);
            return url.searchParams.get(paramKey);
        },
        FileUrl: function (url) {
            if (url == "" || url == null || url.length < 15)
                return siteURL + "js/lib/assets/img/img-not-found.jpg";
            if (url.substring(0, 8).toLowerCase() == "https://" || url.substring(0, 7).toLowerCase() == "http://")
                return url;
            return siteURL + url;

        },
        CheckboxSlider: function (htmlCheckbox) {
            return '<label class="switch">' + htmlCheckbox + '<span class="slider round"></span></label >';
        },

        FullScreenOnOffWindow: function () {


        },
        PrintHtmlPage: function (width, height, htmlText) {
            if ($(".printIframe").length)
                $(".printIframe").remove();
            var iframeEl = $('<iframe class="printIframe" style="display:none;"></iframe>');
            $('body').append(iframeEl);
            var iframeW = iframeEl.contents().find('body');
            var iframeWindow = (iframeEl[0].contentWindow || iframeEl[0].contentDocument);
            htmlText = '<div style="margin:0 auto;width:' + width + ';height:' + height + ';">' + htmlText + '</div>';
            iframeW.append(htmlText);
            iframeWindow.print();

        },
        IsNullToEmpty: function (value) {
            if (value == null)
                return "";
            return value;
        }
    };


    EventManager = {
        DataTableCommonButton: function () {
            return '<button class="btn btn-primary btn-datatable btn-round float-left dTableEdit mr-2" title="Click to edit"><i class="fas fa-edit"></i></button>' +
                '<button class="btn btn-danger btn-datatable btn-round float-left dTableDelete" title="Click to delete"><i class="far fa-trash-alt"></i></button>';
        }

    };

    dTableManager = {
        dTableSerialNumber: function ($dataTable) {
            $dataTable.on('order.dt search.dt', function () {
                $dataTable.column(0, { search: 'applied', order: 'applied' }).nodes().each(function (cell, i) {
                    cell.innerHTML = dTableManager.IndexColumn(i + 1);
                });
            }).draw();
        },
        IndexColumn: function (ind) {
            return '<div class="font-weight" style="vertical-align: middle;" align="center">' + ind + '</div>';
        },
        Border: function (selector, tblHight) {
            $(selector).parent().css({
                'minHeight': tblHight + 'px',
                'borderTop': '1px solid #dbdbdb !important',
                'borderLeft': '1px solid #dbdbdb',
                'borderRight': '1px solid #dbdbdb',
                'borderBottom': '1px solid #dbdbdb'
            });
        }
    };
})(jQuery);

