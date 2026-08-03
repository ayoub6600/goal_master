
//(function ($) {
    "use strict";
    var dTable = null;
    var _id = null;
    var _resId = null;
    var _permiId = null;

    $(document).ready(function () {
        //load datatable
        MenuManager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        //add new menu
        $("#btnAddNewMenu").on("click", function () {
            _id = null;
            MenuManager.ResetForm();
            $("#frmMenuModal").modal('show');
        });

        //save or update
        JsManager.JqBootstrapValidation('#menuForm', (form, event) => {
            event.preventDefault();
            if (_id == null) {
                MenuManager.SaveMenu(form);
            } else {
                MenuManager.UpdateMenu(form, _id);
            }
        });

        JsManager.JqBootstrapValidation('#permissionForm', (form, event) => {
            event.preventDefault();
            if (_permiId == null) {
                MenuManager.SavePermission(form);
            } else {
                MenuManager.UpdatePermission(form, _permiId, _resId);
            }
        });

    });


    //show edit menu info modal
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;
        $('#name').val(rowData.name);
        $('#displayName').val(rowData.display_name);
        $('#faIcon').val(rowData.icon);
        $('#level').val(rowData.level);
        $('#secResourceId').val(rowData.sec_resource_id);
        $('#menuSerial').val(rowData.serial);
        $('#routeName').val(rowData.method);

        if (rowData['status'] == 1) {
            $('#statusYes').prop('checked', true);
        }
        else {
            $('#statusNo').prop('checked', true);
        }

        $("#frmMenuModal").modal('show');
    });


    //delete menu
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        MenuManager.DeleteMenu(rowData.id);
    });


    //Add new permission
    $(document).on('click', '.dTableAddNewPermission', function () {
        var rowData = dTable.row($(this).parent()).data();
        _resId = rowData.id;
        MenuManager.ResetPermissionForm();
        $("#frmPermissionModal").modal('show');
    });

    function editPermission(obj) {
        var data = $(obj).data('permissioneditdata');
        $("#permissionName").val(data.permission_name);
        $("#permissionRouteName").val(data.route_name);
        _permiId = data.id;
        _resId = data.sec_resource_id;
        if (data.status == 1) {
            $('#permiStatusYes').prop('checked', true);
        }
        else {
            $('#permiStatusNo').prop('checked', true);
        }
        $("#frmPermissionModal").modal('show');
    }
    function deletePermission(id) {
        MenuManager.DeletePermission(id);
    }


    var MenuManager = {
        ResetPermissionForm: function () {
            $("#permissionForm").trigger('reset');
        },
        ResetForm: function () {
            $("#roleForm").trigger('reset');
        },
        SaveMenu: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "save-resource";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        form.trigger('reset');
                        MenuManager.GetDataList(1); //reload datatable
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
        UpdateMenu: function (form, id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&id=" + id;
                var serviceUrl = "update-resource";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        _id = null;
                        form.trigger('reset');
                        MenuManager.GetDataList(1); //reload datatable
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
        DeleteMenu: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: id };
                var serviceUrl = "delete-resource";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        MenuManager.GetDataList(1); //reload datatable
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

        SavePermission: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&secResourceId=" + _resId;
                var serviceUrl = "save-permission";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        _resId = null;
                        Message.Success("save");
                        form.trigger('reset');
                        MenuManager.GetDataList(1); //reload datatable
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
        UpdatePermission: function (form, id, resId) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&id=" + id + '&secResourceId=' + resId;
                var serviceUrl = "update-permission";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        _resId = null;
                        _permiId = null;
                        form.trigger('reset');
                        MenuManager.GetDataList(1); //reload datatable
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
        DeletePermission: function (id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = { id: id };
                var serviceUrl = "delete-permission";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        MenuManager.GetDataList(1); //reload datatable
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
            var serviceUrl = "get-menu-and-permission";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                MenuManager.LoadMenuLevelDropDown(jsonData.data.map(a => {
                    return {
                        id: a.id,
                        name: ((a.level == 2) ? '==>' + a.display_name : (a.level == 3) ? '===>' + a.display_name : a.display_name)
                    };
                }));

                MenuManager.LoadDataTable(jsonData.data, refresh);
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadDataTable: function (menuData, refresh) {
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-6'B><'col-md-3'l><'col-md-3'f>>" + "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    initComplete: function () {
                        dTableManager.Border(this, 500);
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
                            title: 'View file'
                        },
                        {
                            data: 'display_name',
                            name: 'display_name',
                            title: 'Menu/Display Name',
                            render: function (data, type, row) {
                                return ((row.level == 2) ? '&nbsp &nbsp &nbsp' + data : (row.level == 3) ? '&nbsp &nbsp &nbsp &nbsp &nbsp' + data : '<b>' + data + '</b>');
                            }
                        },
                        {
                            data: 'icon',
                            name: 'icon',
                            width: 100,
                            title: 'Font Awesome Icon',
                            render: function (data, type, row) {
                                return "<i class='" + data + "'> " + (data != null ? data : "") + "</i>";
                            }
                        },
                        {
                            data: 'level',
                            name: 'level',
                            title: 'Menu Level'
                        },
                        {
                            data: 'sec_resource_id',
                            name: 'sec_resource_id',
                            title: 'Menu Under',
                            render: function (data, type, row) {
                                var parent = "Parent";
                                var menu = menuData.filter(f => f.id == data)[0];
                                if (menu != null) {
                                    parent = menu.display_name;
                                }

                                return parent;
                            }
                        },

                        {
                            data: 'serial',
                            name: 'serial',
                            title: 'Serial/Order'
                        },
                        {
                            data: 'method',
                            name: 'method',
                            title: 'Route Name'
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
                            name: 'role_permission_infos',
                            data: 'role_permission_infos',
                            title: 'Permission',
                            width: 200,
                            render: function (data, type, row) {
                                var rtr = "";
                                if (row['sec_resource_id']) {
                                    var addNewPermission = '<div class="cp btn-success btn-datatable-padding float-left dTableAddNewPermission ml-2 permission-div" title="Click to add new permission"><i class="fa fa-plus"></i> Add Permission</div>';
                                    $.each(data, function (i, v) {
                                        var deleteBtn = '<i class="cp far fa-trash-alt btn-danger ml-2" title="click to delete permission" onclick="deletePermission(' + v.id + ')"></i>';
                                        var editBtn = "<i class='cp fas fa-edit ml-2' title='click to edit permission' data-permissioneditdata='" + JSON.stringify(v) + "' onclick=editPermission(this);></i>";

                                        rtr += "<div class='" + (v.status == 1 ? "btn-primary" : "btn-danger") + " btn-datatable-padding float-left permission-div'><div class='float-left'>" + v.permission_name + "</div><div class='float-left'>" + deleteBtn + "</div><div class='float-left'>" + editBtn + "</div></div>";
                                    });
                                    return rtr + addNewPermission;
                                }
                                return "";
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
                    ],
                    fixedColumns: false,
                    data: menuData
                });
            } else {
                dTable.clear().rows.add(menuData).draw();
            }
        },
        LoadMenuLevelDropDown: function (data) {
            JsManager.PopulateCombo("#secResourceId", data, "Parent");
        }
    };
//})(jQuery);