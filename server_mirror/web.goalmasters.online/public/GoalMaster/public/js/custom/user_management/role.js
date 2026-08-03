(function ($) {
    "use strict";
        var dTable = null;
        var _id = null;

        $(document).ready(function () {
            //load datatable
            RoleManager.GetDataList(0);

            //generate datatabe serial no
            dTableManager.dTableSerialNumber(dTable);

            //add role modal
            $("#btnAddRole").on("click", function () {
                _id = null;
                RoleManager.ResetForm();
                $("#frmRoleModal").modal('show');
            });

            //save or update
            JsManager.JqBootstrapValidation('#roleForm', (form, event) => {
                event.preventDefault();
                if (_id == null) {
                    RoleManager.Save(form);
                } else {
                    RoleManager.Update(form, _id);
                }
            });

        });

        //show edit role info modal
        $(document).on('click', '.dTableEdit', function () {
            var rowData = dTable.row($(this).parent()).data();
            _id = rowData.id;
            $('#name').val(rowData.name);
            if (rowData.is_default_user_role == 1) {
                $("#isDefaultRoleYes").prop('checked', true);
            } else {
                $("#isDefaultRoleNo").prop('checked', true);
            }

            if (rowData['status'] == 1) {
                $('#statusYes').prop('checked', true);
            }
            else {
                $('#statusNo').prop('checked', true);
            }

            $("#frmRoleModal").modal('show');
        });


        //delete role
        $(document).on('click', '.dTableDelete', function () {
            var rowData = dTable.row($(this).parent()).data();
            RoleManager.Delete(rowData.id);
        });

        //go to role permission
        $(document).on('click', '.dTableSetRolePermisssion', function () {
            var rowData = dTable.row($(this).parent()).data();
            window.location = JsManager.BaseUrl() + "/role-permission?id=" + rowData.id;
        });

        var RoleManager = {
            ResetForm: function () {
                $("#roleForm").trigger('reset');
            },
            Save: function (form) {
                if (Message.Prompt()) {
                    JsManager.StartProcessBar();
                    var jsonParam = form.serialize();
                    var serviceUrl = "save-role";
                    JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                    function onSuccess(jsonData) {
                        if (jsonData.status == "1") {
                            Message.Success("save");
                            form.trigger('reset');
                            RoleManager.GetDataList(1); //reload datatable
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
                    var serviceUrl = "update-role";
                    JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                    function onSuccess(jsonData) {
                        if (jsonData.status == "1") {
                            Message.Success("update");
                            _id = null;
                            form.trigger('reset');
                            RoleManager.GetDataList(1); //reload datatable
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
                    var serviceUrl = "delete-role-info";
                    JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                    function onSuccess(jsonData) {
                        if (jsonData.status == "1") {
                            Message.Success("delete");
                            RoleManager.GetDataList(1); //reload datatable
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
                var serviceUrl = "get-role";
                JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    RoleManager.LoadDataTable(jsonData.data, refresh);
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
                                    columns: [2, 3, 4, 5]
                                },
                                title: 'User List'
                            },
                            {
                                text: '<i class="fa fa-print"></i> Print',
                                className: 'btn btn-sm',
                                extend: 'print',
                                exportOptions: {
                                    columns: [2, 3, 4, 5]
                                },
                                title: 'User List'
                            },
                            {
                                text: '<i class="fa fa-file-excel"></i> Excel',
                                className: 'btn btn-sm',
                                extend: 'excelHtml5',
                                exportOptions: {
                                    columns: [2, 3, 4, 5]
                                },
                                title: 'User List'
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
                                width: 200,
                                render: function (data, type, row) {
                                    var rolePermission = '<button class="btn btn-primary btn-datatable-padding float-left dTableSetRolePermisssion ml-2" title="Click to edit"><i class="fas fa-user-cog"></i> اعطى صلاحيات</button>';
                                    return EventManager.DataTableCommonButton() + rolePermission;
                                }
                            },

                            {
                                data: 'name',
                                name: 'name',
                                title: 'Name'
                            },
                            {
                                data: 'is_default_user_role',
                                name: 'is_default_user_role',
                                title: 'Is Default User Role',
                                render: function (data, type, row) {
                                    var status = data ? "Yes" : "No";
                                    return status;
                                }
                            },

                            {
                                data: 'status',
                                name: 'status',
                                title: 'Status',
                                width: 50,
                                render: function (data, type, row) {
                                    var status = data ? "Active" : "Inactive";
                                    return status;
                                }
                            },
                            {
                                data: 'created_at',
                                name: 'created_at',
                                title: 'Created Date'
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