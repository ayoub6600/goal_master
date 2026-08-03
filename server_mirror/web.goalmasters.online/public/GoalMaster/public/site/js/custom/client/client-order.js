
var ClientOrder;

(function ($) {
    "use strict";
    var dTable;
    $(document).ready(function () {
        ClientOrder.GetDataList(0);
    });

    ClientOrder = {
        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "client-orders";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed, true);

            function onSuccess(jsonData) {
                ClientOrder.LoadDataTable(jsonData.data, refresh);
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
                        {orderable:false, targets : [1,2,3,4,5]}
                    ],
                    order: [[0, 'desc']],
                    columns: [
                        {
                            data: 'id',
                            name: 'id',
                            visible : false,
                        },

                        {
                            data: 'code',
                            name: 'code',
                            title: 'Order No',
                            width: 200,
                            render: function (data, type, row) {
                                return data;
                            }
                        },

                        {
                            data: 'amount',
                            name: 'amount',
                            title: 'Total',
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
                                    status1 : 'Processing',
                                    status2 : 'Shipped',
                                    status3 : 'Deliverd',
                                    status4 : 'Cancled',
                                }
                                return orderStatus['status'+data];
                            }
                        },
                        {
                            data: 'created_at',
                            name: 'created_at',
                            title: 'Date',
                            width: 100,
                            render: function (data, type, row) {
                                return moment(data).format('ll');
                            }
                        },

                        {
                            data: 'id',
                            name: 'id',
                            title: 'Option',
                            width: 60,
                            render: function (data, type, row) {
                                return '<a href="'+JsManager.BaseUrl()+'/client-order/'+data+'">Details</a>';
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