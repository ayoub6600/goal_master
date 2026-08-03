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
            _id = null;
            Manager.ResetForm();
            $("#frmModal").modal('show');
            Manager.LoadZoneDropDown();
        });

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

    //show edit info modal
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;
        $('#name').val(rowData.name);
        $('#phone').val(rowData.phone);
        $('#email').val(rowData.email);
        $('#lat').val(rowData.lat);
        $('#long').val(rowData.long);
        $('#zone_id').val(rowData.zone_id);
        $('#address').val(rowData.address);
        $('#order').val(rowData.order);
        if (rowData['status'] == 1) {
            $('#statusYes').prop('checked', true);
        }
        else {
            $('#statusNo').prop('checked', true);
        }


        $("#frmModal").modal('show');
        Manager.LoadZoneDropDown();
    });


    //delete
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        Manager.Delete(rowData.id);
    });


    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var formData = new FormData(form[0]);
                var serviceUrl = "branch-save";
                $.ajax({
                    url: serviceUrl,
                    type: 'POST',
                    data: formData,
                    contentType: false,
                    processData: false,
                    success: onSuccess,
                    error: onFailed
                });

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        Manager.ResetForm();
                        Manager.GetDataList(1); //reload datatable
                        $("#frmModal").modal('hide');
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
                var formData = new FormData(form[0]);
                formData.append('id', id);
                var serviceUrl = "branch-update";
                $.ajax({
                    url: serviceUrl,
                    type: 'POST',
                    data: formData,
                    contentType: false,
                    processData: false,
                    success: onSuccess,
                    error: onFailed
                });

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        _id = null;
                        Manager.ResetForm();
                        Manager.GetDataList(1); //reload datatable
                        $("#frmModal").modal('hide');
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
                var serviceUrl = "branch-delete";
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
            var serviceUrl = "get-branch";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                Manager.LoadDataTable(jsonData.data, refresh);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },


        LoadZoneDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-zone";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {

                JsManager.PopulateCombo("#zone_id", jsonData.data);
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
                            title: 'Branch List'
                        },
                        {
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [2, 3]
                            },
                            title: 'Branch List'
                        },
                        {
                            text: '<i class="fa fa-file-excel"></i> Excel',
                            className: 'btn btn-sm',
                            extend: 'excelHtml5',
                            exportOptions: {
                                columns: [2, 3]
                            },
                            title: 'Branch List'
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
                            name: 'Option',
                            title: 'Option',
                            width: 60,
                            render: function (data, type, row) {
                                return EventManager.DataTableCommonButton();
                            }
                        },
                        {
                            data: 'name',
                            name: 'name',
                            title: 'Name'
                        },
                        {
                            data: 'phone',
                            name: 'phone',
                            title: 'Phone'
                        },
                        {
                            data: 'email',
                            name: 'email',
                            title: 'Email'
                        },
                        {
                            data: 'address',
                            name: 'address',
                            title: 'Address'
                        },
                        {
                            data: 'image_url',
                            name: 'image',
                            title: 'Image',
                            width: '100px',
                            render: function (data, type, row) {
                                if (data) {
                                    return '<img src="' + data + '" alt="Image" style="height: 50px; width: 50px; object-fit: cover; border-radius: 5px;" />';
                                }
                                return '';
                            }
                        },
                        {
                            data: 'zone',
                            name: 'zone',
                            title: 'Zone',
                            render: function (data, type, row) {
                                if(row['zone_id'] ){
                                    return row['zone']['name'];

                                }
                                return '';
                            }
                        },
                        {
                            data: 'map_url',
                            name: 'map_url',
                            title: 'Map Url',
                            render: function (data, type, row) {
                               if(row['lat'] && row['long']){
                                    var map_url = "https://www.google.com/maps/search/?api=1&query="+row['lat']+","+ row['long'];
                                    return '<a target="_blank" href="' + map_url + '">Google Map</a>'
                               }
                               return '';
                            }
                        },
                        {
                            data: 'order',
                            name: 'order',
                            title: 'Order'
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