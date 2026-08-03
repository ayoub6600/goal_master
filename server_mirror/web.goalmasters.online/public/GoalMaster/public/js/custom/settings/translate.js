
(function ($) {
    "use strict";

    var dTable = null;
    $(document).ready(function () {

        //load datatable
        Manager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        $("#btnSave").on('click', function () {          
            var arr = [];
            $.each($('#tableElement tbody tr'), function (rowIdx, val) {
                if ($(val).find('.lang_value').val() != "") {
                    var obj = new Object();
                    obj.lang_value= $(val).find('.lang_value').val();
                    obj.id= $(val).find('.id').val();
                    obj.en_trans_id= $(val).find('.en_trans_id').val();
                    obj.lang_id= $(val).find('.lang_id').val();                    
                    arr.push(obj);
                }
            });
            if (arr.length > 0) {
                Manager.Save(arr);               
            }
            else {
                Message.Warning("No data found to save change");
            }
        });

    });


    var Manager = {

        Save: function (data) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                 var jsonParam = {translate:data};
                var serviceUrl = "save-translated-language";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                    } else {
                        Message.Error("save");
                    }
                    JsManager.EndProcessBar();

                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },

        GetDataList: function (refresh) {
            var jsonParam = { id: Utility.GetUrlParamValue('id') };
            var serviceUrl = "language-translation-list";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                Manager.LoadDataTable(jsonData.data, refresh);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },


        LoadDataTable: function (data, refresh) {
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    initComplete: function () {
                        dTableManager.Border(this, 500);
                    },
                    buttons: [],

                    scrollY: "500px",
                    scrollX: true,
                    scrollCollapse: true,
                    lengthMenu: [[40], [40]],
                    columnDefs: [
                        { visible: false, targets: [] },
                        { "className": "dt-center", "targets": [] }
                    ],
                    columns: [
                        {
                            data: null,
                            name: '',
                            'orderable': false,
                            'searchable': false,
                            title: '#SL',
                            width: 8,
                            render: function () {
                                return '';
                            }
                        },
                        {
                            data: 'lang_key',
                            name: 'lang_key',
                            title: 'Language Key',
                            width: 400
                        },
                        {
                            data: 'lang_value',
                            name: 'lang_value',
                            title: 'Language Value',
                            render: function (data, type, row, meta) {
                                return '<input  name="translate[' + meta.row + '][lang_value]" type="text" value="' + data + '" class="lang_value form-control input-full" style="height:2.25rem !important">' +
                                    '<input  name="translate[' + meta.row + '][id]" type="number" value="' + row['id'] + '" class="d-none id">' +
                                    '<input  name="translate[' + meta.row + '][en_trans_id]" type="number" value="' + row['en_trans_id'] + '" class="d-none en_trans_id">' +
                                    '<input name="translate[' + meta.row + '][lang_id]" type="number" value="' + row['lang_id'] + '" class="d-none lang_id">';
                            }
                        }

                    ],
                    fixedColumns: false,
                    data: data
                });
            } else {
                dTable.clear().rows.add(data).draw();
            }
        }
    };
})(jQuery);