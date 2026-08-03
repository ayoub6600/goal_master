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
        $("#btnAdd").on("click",function () {
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
        $('#site_menu_id').val(rowData.site_menu_id);
        $('#name').val(rowData.c_name);
        $('#route').val(rowData.route);
        $('#remarks').val(rowData.remarks);
        $('#order').val(rowData.order);
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
            $('#id').val('')
            $('#about-image-view').attr("src", "");
            _id = null;
        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "website-save-menu";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
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
                var serviceUrl = "website-update-menu";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
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
        Delete: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: id };
                var serviceUrl = "website-delete-menu";
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
        LoadMenuDropdown: function (data) {
            var arr = [];
            $.each(data, function (i, v) {
                arr.push({ id: v.id, name: v.c_name });
                if (v.site_menu_id > 0) {
                    $.each(data.filter(f => f.site_menu_id == v.id), function (i2, v2) {
                        arr.push({ id: v2.id, name: "=>" + v2.c_name });
                        $.each(data.filter(f => f.site_menu_id == v2.id), function (i3, v3) {
                            arr.push({ id: v3.id, name: "==>" + v3.c_name });
                        });
                    });
                }

            });

            JsManager.PopulateCombo("#site_menu_id", arr, "Parent Menu", 0);
        },

        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "website-get-menu";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                Manager.LoadDataTable(jsonData.data, refresh);
                Manager.LoadMenuDropdown(jsonData.data);

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
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [2, 3, 4, 5, 6, 7]
                            },
                            title: 'Print menu'
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
                            width: 8,
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
                            data: 'p_name',
                            name: 'p_name',
                            title: 'Menu Under',
                            render: function (data, tyep, row) {
                                if (data) {
                                    return data;
                                } else {
                                    return "PARENT MENU";
                                }
                            }
                        },
                        {
                            data: 'c_name',
                            name: 'c_name',
                            title: 'Menu',
                            render: function (data, type, row) {
                                if (row['site_menu_id'] > 0)
                                    return '==> ' + data;
                                return data;

                            }
                        },

                        {
                            data: 'route',
                            name: 'route',
                            title: 'route'
                        },
                        {
                            data: 'remarks',
                            name: 'remarks',
                            title: 'Remarks'
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
