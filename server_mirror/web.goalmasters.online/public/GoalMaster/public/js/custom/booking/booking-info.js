(function ($) {
    "use strict";
    var dTable = null;
    var _id = null;

    //! Internet payment modal
    $(document).ready(function () {
        $("#btnInternet").on("click", function () {
            // Load branch data if needed
            Manager.LoadBranchModelDropDown();

            // Show the modal
            $("#internetModal").modal('show');
        });

        $("#confirmPayment").on("click", function () {
            if (Message.Prompt()) {  
                JsManager.StartProcessBar(); 

                var dateFrom = $("#dateFromModal").val();
                var dateTo = $("#dateToModal").val();
                var branchId = $("#branchIdModel").val();

                var jsonParam = {
                    date_from: dateFrom,
                    date_to: dateTo,
                    branch_id: branchId,
                    online: true
                };

                var serviceUrl = "get-service-booking-info"; 

                JsManager.SendJson("get", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("Successfully completed the payment process.");
                        $("#internetModal").modal('hide');
                    } else {
                        Message.Error("Failed to complete the payment process.");
                    }
                    JsManager.EndProcessBar(); 
                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar(); 
                    Message.Exception(xhr); 
                }
            }
        });
    });

        

    document.addEventListener("DOMContentLoaded", function() {
        const payed = document.getElementById("payed");
        const tolerance = document.getElementById("tolerance");
        const extraInputDiv = document.getElementById("extraInputDiv");

        extraInputDiv.style.display = "none"; 

        function toggleExtraInput() {
            if (payed.checked) {
                extraInputDiv.style.display = "block";
            } else {
                extraInputDiv.style.display = "none";
            }
        }

        payed.addEventListener("change", toggleExtraInput);
        tolerance.addEventListener("change", toggleExtraInput);
        
        toggleExtraInput();
    });


    $(document).ready(function () {

        //load datatable
        Manager.GetDataList(0);
        Manager.LoadCustomerDropDown();
        Manager.LoadEmployeeDropDown();
        Manager.LoadBranchDropDown();
        
        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        $("#btnFilter").on("click",function () {
            Manager.GetDataList(1);
        });

        $("#serviceId").on("keyup",function (e) {
            if (e.keyCode == 13) {
                Manager.GetDataList(1);
            }
        });

        //save change status
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            Manager.ChangeServiceStatus(form);

        });

        JsManager.JqBootstrapValidation('#inputPayForm', (form, event) => {
            event.preventDefault();
            Manager.ChangeServicePayment(form);

        });
    });

    //show edit info modal
    $(document).on('click', '.dt-button-action', function () {
        Manager.ResetForm();
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;
        $('#booking_id').val(rowData.id);
        $('#span-booking-number').text(rowData.id);
        $('#status').val(rowData.status);

        $("#frmModal").modal('show');
    });

    // function formatDate(date,special_char) {
    //     var d = new Date(date),
    //         month = '' + (d.getMonth() + 1),
    //         day = '' + d.getDate(),
    //         year = d.getFullYear();
    //
    //     if (month.length < 2)
    //         month = '0' + month;
    //     if (day.length < 2)
    //         day = '0' + day;
    //
    //     return [year, month, day].join(special_char);
    // }

    $(document).on('click', '.dt-button-add-pay-action', function () {
        Manager.ResetPaymentForm();
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;
        $('#id').val(rowData.id);
        $('#span-booking-no').text(rowData.id);
        $('#due').val(rowData.due);
        console.log('test frmPayModal');
        // var todayDate = moment(new Date(), 'YYYY-MM-DD');
        // $('#divServiceDate').datetimepicker('destroy');
        // Manager.ServiceDatePicker(todayDate);
        // $("#serviceDate").val(formatDate(todayDate,'-'));

        $("#frmPayModal").modal('show');
    });


    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
        },
        ServiceStatus: function (status) {
            var serviceStatus = ['غير خالص', 'بانتظار قبول الطلب', 'موافق عليه', 'إلغاء', 'خالص'];
            return serviceStatus[status];
        },
        ServiceFontColorClass: function (status) {
            var serviceColor = ['fc_pending', 'fc_processing', 'fc_approved', 'fc_cancel', 'fc_done'];
            return serviceColor[status];
        },
        ResetPaymentForm: function () {
            $("#inputPayForm").trigger('reset');
        },
        ServicePaymentStatus: function (status) {
                                        // 1        2           3
            var servicePaymentStatus = [ 'مدفوع', 'غير مدفوع', 'مدفوع جذئى'];
            return servicePaymentStatus[status -1];
        },
        ServicePaymentFontColorClass: function (status) {
            var servicePaymentColor = ['fc_done', 'fc_cancel', 'fc_pending'];
            return servicePaymentColor[status-1];
        },
        // ServiceDatePicker: function (startDate) {
        //     const date = new Date()
        //     const max_date = new Date(new Date(date).setMonth(date.getMonth() + 1))
        //     $('#divServiceDate').datetimepicker({
        //         format: 'Y-m-d',
        //         inline: true,
        //         timepicker: false,
        //         minDate: new Date(),
        //         startDate: startDate._d,
        //         maxDate : max_date,
        //         onChangeDateTime: function (dp, $input) {
        //             $("#serviceDate").val($input.val());
        //         }
        //     });
        // },

        ChangeServiceStatus: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "change-service-booking-status";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("Successfully update service status to " + Manager.ServiceStatus($("#status").val()));
                        Manager.ResetForm();
                        $("#frmModal").modal('hide');
                        Manager.GetDataList(1); //reload datatable
                    } else {
                        Message.Error("Failed to update service status for " + Manager.ServiceStatus($("#status").val()));
                    }
                    JsManager.EndProcessBar();
                }
                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Manager.ResetForm();
                    Message.Exception(xhr);
                }
            }
        },
        ChangeServicePayment: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize();
                var serviceUrl = "add-service-booking-payment";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("بنجاح تم إضافه المبلغ : " + $("#due").val());
                        // Message.Success("Successfully add service payment amount " + $("#due").val());
                        Manager.ResetPaymentForm();
                        $("#frmPayModal").modal('hide');
                        Manager.GetDataList(1); //reload datatable
                    }else if(jsonData.status == "0"){
                        Message.Error(jsonData.msg);

                    }else {
                        
                        Message.Error("Failed to add service payment amount " + $("#due").val());
                    }
                    JsManager.EndProcessBar();
                }
                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Manager.ResetPaymentForm();
                    Message.Exception(xhr);
                }
            }
        },
        GetDataList: function (refresh) {
            JsManager.StartProcessBar();
            var jsonParam = {
                dateFrom: $("#dateFrom").val(),
                dateTo: $("#dateTo").val(),
                employeeId: $("#employeeId").val(),
                customerId: $("#customerId").val(),
                serviceStatus: $("#serviceStatus").val(),
                bookingId: $("#serviceId").val(),
                branchId: $("#branchId").val()
            };
            var serviceUrl = "get-service-booking-info";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                Manager.LoadDataTable(jsonData.data, refresh);
                JsManager.EndProcessBar();
            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }
        },
        LoadDataTable: function (data, refresh) {
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-4'i><'col-md-3 mt-2'l><'col-md-5 mt-7'p>>",
                    initComplete: function () {
                        dTableManager.Border(this, 450);
                    },
                    buttons: [],

                    scrollY: "450px",
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
                            data: 'id',
                            name: 'id',
                            title: 'No#'
                        },
                        {
                            data: 'date',
                            name: 'date',
                            title: 'Date',
                            render: function (data, type, row) {
                                return moment(data).format('MMM DD, YYYY');
                            }
                        },
                        {
                            data: 'service',
                            name: 'service',
                            title: 'Service Info',
                            render: function (data, type, row) {
                                return '<div class="flex-1 ml-3 pt-1">' +
                                    '<h6 class="text-uppercase fw-bold mb-1">' +
                                    row['service'] +
                                    '<span class=" float-right ' + Manager.ServiceFontColorClass(row['status']) + ' pl-3">' + Manager.ServiceStatus(row['status']) + '</span>' +
                                    '<span class=" float-right ' + Manager.ServicePaymentFontColorClass(row['payment_status']) + ' pl-3">(' + Manager.ServicePaymentStatus(row['payment_status']) + ')</span>' +
                                    '</h6>' +
                                    '<span class="text-muted">' +
                                    row['customer'] + " | " + row['customer_phone_no'] + " | <span class='text-primary'>" + moment(row['date'] + ' ' + row['start_time']).format('LT') + " to " + moment(row['date'] + ' ' + row['end_time']).format('LT') + "</span><br/>" +
                                    "Due# <span class='text-danger'>" + parseFloat(row['due']).toFixed(2) + "</span> | " + (row['remarks'] == null ? "No remarks found!" : row['remarks'])
                                    + '</span>' +
                                    '</div>';
                            }
                        },
                        {
                            data: 'branch',
                            name: 'branch',
                            title: 'Branch'
                        },
                        {
                            data: 'employee',
                            name: 'employee',
                            title: 'Staff/Employee'
                        },
                        {
                            name: 'Option',
                            title: 'Option',
                            width: 70,
                            render: function (data, type, row) {
                                return '<button class="btn btn-sm btn-primary dt-button-action m-1"><i class="fas fa-location-arrow"></i> Action</button> ' +
                                    ([3,2].includes(row['payment_status']) ?
                                    '<button class="btn btn-sm btn-secondary dt-button-add-pay-action m-1"><i class="fas fa-money-check-alt m-1"></i> إضافه دفعه</button>' : '');
                            }
                        },
                    ],
                    fixedColumns: false,
                    data: data
                });
            } else {
                dTable.clear().rows.add(data).draw();
            }
        },
        LoadBranchDropDown: function () {
            var jsonParam = { branchId: 0 };
            var serviceUrl = "get-branch-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.data.length < 2) {
                    JsManager.PopulateComboSelectPicker("#branchId", jsonData.data);
                } else {
                    JsManager.PopulateComboSelectPicker("#branchId", jsonData.data, 'All Branch');
                }
                $("#branchId").selectpicker('refresh');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadBranchModelDropDown: function () {
            var jsonParam = { branchId: 0 };
            var serviceUrl = "get-branch-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.data.length < 2) {
                    JsManager.PopulateComboSelectPicker("#branchIdModel", jsonData.data);
                } else {
                    JsManager.PopulateComboSelectPicker("#branchIdModel", jsonData.data, 'All Branch');
                }
                $("#branchIdModel").selectpicker('refresh');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadEmployeeDropDown: function () {
            var jsonParam = { branchId: 0 };
            var serviceUrl = "get-employee-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.data.length < 2) {
                    JsManager.PopulateComboSelectPicker("#employeeId", jsonData.data);
                } else {
                    JsManager.PopulateComboSelectPicker("#employeeId", jsonData.data, 'All Employee');
                }
                $("#employeeId").selectpicker('refresh');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadCustomerDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-customer-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateComboSelectPicker("#customerId", jsonData.data, 'All Customer');
                $("#customerId").selectpicker('refresh');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
    };
})(jQuery);