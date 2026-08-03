(function ($) {
    "use strict";

    var dTable = null;
    var _id = null;
    $(document).ready(function () {

        //load datatable
        Manager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            if (_id == null) {
                Manager.Save(form);
            } else {
                Manager.Update(form, _id);
            }
        });

    });

    //delete
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        Manager.Delete(rowData.id);
    });
    //delete
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();
        $("#name").val(rowData.name);
        $("#code").val(rowData.code);
        if (rowData.default_language == 1) {
            $("#default_language").attr("checked", true);
        } else {
            $("#default_language").attr("checked", false);
        }
        _id = rowData.id;
    });

    $(document).on('change', '.clsChkStatus', function () {
        var rowData = dTable.row($(this).parents('td')).data();
        if ($(this).prop("checked")) {
            Manager.UpdateStatus(rowData.id, 1);
        } else {
            Manager.UpdateStatus(rowData.id, 0);
        }
    });


    var Manager = {
        ResetForm: function () {
            _id = null;
            $("#inputForm").trigger('reset');
        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "save-language";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        Manager.ResetForm();
                        Manager.GetDataList(1); //reload datatable
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
        Update: function (form, id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&id=" + id;
                var serviceUrl = "update-language";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        _id = null;
                        Manager.ResetForm();
                        Manager.GetDataList(1); //reload datatable
                    } else {
                        Message.Error("update");
                    }
                    JsManager.EndProcessBar();

                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },
        Delete: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: id };
                var serviceUrl = "delete-language";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        Manager.GetDataList(1); //reload datatable
                    } else {
                        Message.Error("delete");
                    }
                    JsManager.EndProcessBar();

                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },
        UpdateStatus: function (id, status) {
            JsManager.StartProcessBar();
            var jsonParam = { id: id, status: status };
            var serviceUrl = "update-rtl-status";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    Message.Success("update");
                    Manager.GetDataList(1); //reload datatable
                } else {
                    Message.Error("update");
                }
                JsManager.EndProcessBar();

            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }
        },

        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "language-list";
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
                    dom: "<'row'<'col-md-6'B><'col-md-3'l><'col-md-3'f>>" + "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    initComplete: function () {
                        dTableManager.Border(this, 350);
                    },
                    buttons: [
                        {
                            text: '<i class="fa fa-file-pdf"></i> PDF',
                            className: 'btn btn-sm',
                            extend: 'pdfHtml5',
                            exportOptions: {
                                columns: [2, 3]
                            },
                            title: 'Language List'
                        },
                        {
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [2, 3]
                            },
                            title: 'Language List'
                        },
                        {
                            text: '<i class="fa fa-file-excel"></i> Excel',
                            className: 'btn btn-sm',
                            extend: 'excelHtml5',
                            exportOptions: {
                                columns: [2, 3]
                            },
                            title: 'Language List'
                        }
                    ],

                    scrollY: "350px",
                    scrollX: true,
                    scrollCollapse: true,
                    lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [] },
                        { "className": "dt-center", "targets": [3] }
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
                            data: 'name',
                            name: 'name',
                            title: 'Name'
                        },
                        {
                            data: 'code',
                            name: 'code',
                            title: 'Code'
                        },
                        {
                            data: 'default_language',
                            name: 'default_language',
                            title: 'Default Language',
                            render: function (data, type, row) {
                                if (row['default_language'] == 1)
                                    return "Yes";
                                return "No";
                            }
                        },
                        {
                            data: 'rtl',
                            name: 'rtl',
                            title: 'RTL',
                            render: function (data, type, row) {
                                var checked = "";
                                if (row['rtl'] != '1')
                                    checked ="checked";
                                return Utility.CheckboxSlider('<input ' + checked + ' class="clsChkStatus rm-slider" type="checkbox"/>');

                            }
                        },
                        {
                            name: 'Option',
                            title: 'Option',
                            width: 100,
                            render: function (data, type, row) {
                                let lang = row['code'] != 'en' ? '<a href="translate-language?id=' + row['id'] + '" class="btn btn-secondary btn-datatable btn-round float-left dTableLanguage mr-2 btn-shadow pt-1" title="Click to translate"><i class="fas fa-language"></i></a>' : "";
                                return lang + " " + EventManager.DataTableCommonButton();
                            }
                        },
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