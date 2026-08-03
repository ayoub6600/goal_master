
var Manager;

(function ($) {
    "use strict";
    var dTable = null;
    var _id = null;
    $(document).ready(function () {
        Manager.GetDataList(0);

        //add  modal
        $("#btnAdd").on("click",function () {
            _id = null;
            $('#thumbnail').attr('required',"required");
            $('#thumbnail').attr('data-validation-required-message',"Thumbnail is required");
            Manager.ResetForm();
            $("#frmModal").modal('show');
        });

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            event.stopPropagation();
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
        $('#cmn_type_id').val(rowData.cmn_type_id);
        $('#price').val(rowData.price);
        $('#discount').val(rowData.discount);
        $('#quantity').val(rowData.quantity);
        $('#thumbnail_img').attr("src",JsManager.BaseUrl()+'/'+rowData.thumbnail);
        $('#thumbnail').removeAttr('required');
        $('#thumbnail').removeAttr('data-validation-required-message');
        $('#status').val(rowData.status);

        $("#frmModal").modal('show');
    });

    $(document).on("change","#thumbnail",function(){
        const [file] = this.files;
        $('#thumbnail_img').attr("src",URL.createObjectURL(file));
    })


    //delete
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        Manager.Delete(rowData.id);
    });

    Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
            $('#thumbnail_img').attr("src",'');
        },
        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "products";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed, true);

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
                    buttons: [],
                    scrollY: true,
                    scrollCollapse: true,
                    lengthMenu: [[5, 100, 500, -1], [5, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [] },
                        { "className": "dt-center", "targets": [] },
                        {orderable:false, targets : [1,2,3,4,5,6]}
                    ],
                    order: [[0, 'desc']],
                    columns: [
                        {
                            data: 'id',
                            name: 'id',
                            visible : false,
                        },
                        {
                            data: 'thumbnail',
                            name: 'thumbnail',
                            title: 'Image',
                            width: 100,
                            render: function (data, type, row) {
                                return '<img src="'+JsManager.BaseUrl()+'/'+data+'" width="50">';
                            }
                        },
                        {
                            data: 'name',
                            name: 'name',
                            title: 'Name',
                            width: 200,
                            render: function (data, type, row) {
                                return data;
                            }
                        }, 

                        {
                            data: 'type',
                            name: 'type',
                            title: 'Type',
                            width: 100,
                            render: function (data, type, row) {
                                return data.name;
                            }
                        },                       

                        {
                            data: 'price',
                            name: 'price',
                            title: 'Price',
                            width: 100,
                            render: function (data, type, row) {
                                return data;
                            }
                        },
                        {
                            data: 'discount',
                            name: 'discount',
                            title: 'Discount %',
                            width: 100,
                            render: function (data, type, row) {
                                return data;
                            }
                        },
                        {
                            data: 'quantity',
                            name: 'quantity',
                            title: 'Quantity',
                            width: 100,
                            render: function (data, type, row) {
                                return data;
                            }
                        },
                        {
                            data: 'status',
                            name: 'status',
                            title: 'Status',
                            width: 100,
                            render: function (data, type, row) {
                                var orderStatus={
                                    status0 : 'Disable',
                                    status1 : 'Enable'
                                }
                                return orderStatus['status'+data];
                            }
                        },
                        {
                            data: 'id',
                            name: 'id',
                            title: 'Option',
                            width: 60,
                            render: function (data, type, row) {
                                return EventManager.DataTableCommonButton();
                            }
                        }

                    ],
                    fixedColumns: false,
                    data: data
                });
            } else {
                dTable.clear().rows.add(data).draw();
            }
        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = new FormData(form[0]);
                var serviceUrl = "products";
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
        Update: function (form, id) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = new FormData(form[0]);
                jsonParam.append("_method","PUT");
                var serviceUrl = "products/"+id;
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        _id = null;
                        $("#frmModal").modal('hide');
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
                var jsonParam = { id: id, '_method' : 'delete' };
                var serviceUrl = "products/"+id;
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
        }
    };
})(jQuery);