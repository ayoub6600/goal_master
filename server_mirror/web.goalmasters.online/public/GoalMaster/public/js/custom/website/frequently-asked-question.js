(function ($) {
    "use strict";

    var dTable = null;
    var _id = null;
    $(document).ready(function () {
        //load datatable
        Manager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        //add  modal
        $("#btnAdd").on("click", function () {
            Manager.ResetForm();
            $("#frmModal").modal('show');
        });

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            var formData = new FormData(document.querySelector('#inputForm'));
            if (_id == null) {
                Manager.Save(formData);
            } else {
                Manager.Update(formData, _id);
            }
        });

    });


    //show edit info modal
    $(document).on('click', '.dTableEdit', function () {
        Manager.ResetForm();
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;
        $('#id').val(rowData.id);
        $('#question').val(rowData.question);
        $('#answer').val(rowData.answer);
        $('#order').val(rowData.order);
        if (rowData['status'] == 1) {
            $('#status').prop('checked', true);
        }
        else {
            $('#status').prop('checked', false);
        }
        $("#frmModal").modal('show');
    });


    //delete
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        Manager.Delete(rowData.id);
    });


    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
            _id = null;
            $('#id').val("");
        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "website-save-frequently-asked-question";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Manager.ResetForm();
                        Message.Success("save");
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
                var jsonParam = form;
                var serviceUrl = "website-update-frequently-asked-question";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

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
        Delete: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: id };
                var serviceUrl = "website-delete-frequently-asked-question";
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
        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "website-get-frequently-asked-question";
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
                        dTableManager.Border(this, 400);
                    },
                    buttons: [
                        {
                            text: '<i class="fa fa-file-pdf"></i> PDF',
                            className: 'btn btn-sm',
                            extend: 'pdfHtml5',
                            exportOptions: {
                                columns: [3, 4, 5, 6]
                            },
                            title: 'FAQ'
                        },
                        {
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [3, 4, 5, 6]
                            },
                            title: 'FAQ'
                        },
                        {
                            text: '<i class="fa fa-file-excel"></i> Excel',
                            className: 'btn btn-sm',
                            extend: 'excelHtml5',
                            exportOptions: {
                                columns: [3, 4, 5, 6]
                            },
                            title: 'FAQ'
                        }
                    ],

                    scrollY: "400px",
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
                            width: 10,
                            render: function () {
                                return '';
                            }
                        },
                        {
                            name: 'Option',
                            title: 'Option',
                            width: 60,
                            render: function (data, type, row) {
                                return EventManager.DataTableCommonButton();
                            }
                        },
                        {
                            data: 'question',
                            name: 'question',
                            title: 'Question'
                        },
                        {
                            data: 'answer',
                            name: 'answer',
                            title: 'Answer'
                        },
                        {
                            data: 'order',
                            name: 'order',
                            title: 'Order'
                        },
                        {
                            data: 'status',
                            name: 'status',
                            title: 'Status',
                            render: function (data, type, row) {
                                return data == "0" ? "No" : "Yes";
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