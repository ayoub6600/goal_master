var cal = null;
(function ($) {
    "use strict";
    var dTable = null;

    $(document).ready(function () {

        Manager.LoadDataTable([],"0");

        $('#load-employee').on("click",function(){
            JsManager.StartProcessBar();
            var jsonParam = 'year='+$('#year').val()+'&month='+$('#month').val()+'&sch_employee_id='+$('#sch_employee_id').val();
            var serviceUrl = "salaries-load";
            JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    Manager.LoadDataTable(jsonData.data);
                } else {
                    Message.Error("Failed to load");
                }
                JsManager.EndProcessBar();
            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }
        });

    });

    $(document).on("change",'.calculate-sum',function(){
        Manager.CalculateTotalPayable(this);
        Manager.CalculateTotalNetPayable(this);
    });

    $(document).on("click",'#save',function(){
        if($('#tableElement_wrapper .employee-chk:checked').length < 1){
            Manager.Error("Please select an item");
            return false;
        }
        var postData = {
                            data : [],
                            year : $('#year').val(),
                            month : $('#month').val(),
                            sch_employee_id : $('#sch_employee_id').val(),
                        };
        $('#tableElement_wrapper .employee-chk:checked').each(function(ind, el){
            var $item = $(el).closest('tr');
            postData.data.push({
                sch_employee_id : $item.find('.employee-chk').val(),
                addition : $item.find('.addition').val(),
                deduction : $item.find('.deduction').val(),
                is_paid : ($item.find('.pay').prop("checked")) ? 1 : 0 
            });
        });
        Manager.Save(postData);
    })

    $(document).on("click",'#delete',function(){
        if($('#tableElement_wrapper .employee-chk:checked').length < 1){
            Manager.Error("Please select an item");
            return false;
        }
        var postData = {
                            data : []
                        };
        $('#tableElement_wrapper .employee-chk:checked').each(function(ind, el){
            var $item = $(el).closest('tr');
            if($item.find('.employee-chk').attr('data-id'))
                postData.data.push($item.find('.employee-chk').attr('data-id'));
        });
        if(postData.data.length > 0)
            Manager.Delete(postData);
    })

    $(document).on("click",'.employee-chk-all',function(){
        var $item = $(this);
        $('#tableElement_wrapper').find('.employee-chk').prop("checked",$item.prop("checked"));
    })

    $(document).on("click",'#preview',function(){
        Manager.ShowProcessedSalary();
    })

    $(document).on("click",'#download',function(){
        window.open(JsManager.BaseUrl()+'/salaries-download?year='+$('#year').val()+'&month='+$('#month').val()+'&sch_employee_id='+$('#sch_employee_id').val())
    })

    $(document).on("click",'.pay-all',function(){
        var $item = $(this);
        $('#tableElement_wrapper').find('.pay').prop("checked",$item.prop("checked"));
    })

    var Manager = {
        ResetForm: function () {
            $("#inputForm").trigger('reset');
            $('#empimagepreview').attr("src", "");
            $('#empidcardimageview').attr("src", "");
            $('#emppassportimageview').attr("src", "");
            $("#id").val('');
        },

        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "salaries-store";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        Manager.ShowProcessedSalary(); //reload datatable
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

        Delete: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "salaries-delete";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        Manager.ShowProcessedSalary(); //reload datatable
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
        CalculateTotalPayable : function(item){
            var $item = $(item);
            var row = dTable.row($item.closest('tr')).data();
            var salary = parseFloat(row.salary),
            commission = parseFloat(row.commission_amount);
            var addition = $item.closest('tr').find('.addition').val() != "" ? parseFloat($item.closest('tr').find('.addition').val()) : 0;
            $item.closest('tr').find('.total').val(commission+salary+addition);
        },
        CalculateTotalNetPayable : function(item){
            var $item = $(item);
            var row = dTable.row($item.closest('tr')).data();
            var totalServiceAmount = parseFloat(row.total_service_amount),
            salary = parseFloat(row.salary),
            commission = parseFloat(row.commission_amount);
            var addition = $item.closest('tr').find('.addition').val() != "" ? parseFloat($item.closest('tr').find('.addition').val()) : 0;
            var deduction = $item.closest('tr').find('.deduction').val() != "" ? parseFloat($item.closest('tr').find('.deduction').val()) : 0;
            var totalPayable = commission+salary;
            $item.closest('tr').find('.netpay').val((totalPayable + addition)-deduction);
        },
        LoadDataTable: function (data, refresh) {
            if (refresh == "0") {
                dTable = $('#tableElement').DataTable({
                    dom: "<'row'<'col-md-6'l><'col-md-3'><'col-md-3'f>>" + "<'row'<'col-md-12'tr>>" + "<'row'<'col-md-5'i><'col-md-7 mt-7'p>>",
                    initComplete: function () {
                        dTableManager.Border(this, 350);
                        $(".dTableDelete").hide();
                    },
                    buttons: [
                          
                    ],

                    scrollY: "350px",
                    scrollX: true,
                    scrollCollapse: true,
                    lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "All"]],
                    columnDefs: [
                        { visible: false, targets: [0,1] },
                        { orderable: false, searchable:false,targets: [2,3,4,5,6,7,8,9,10,11,12] }
                    ],
                    columns: [
                        {
                            data:'target_service_amount',
                            name:'target_service_amount'
                        },
                        {
                            data:'pay_commission_based_on',
                            name:'pay_commission_based_on'
                        },
                        {
                            data: 'sch_employee_id',
                            name: 'sch_employee_chk',
                            'orderable': false,
                            'searchable': false,
                            title: 'Select_All <input type="checkbox" class="employee-chk-all" value="1">',
                            width: 8,
                            render: function (data, type, row) {
                                if(row.id != undefined && row.id)
                                    return '<input type="checkbox" class="employee-chk" data-id="'+row.id+'" value="'+data+'">';
                                return '<input type="checkbox" class="employee-chk" value="'+data+'">';
                            }
                        },
                        {
                            data: 'employee_id',
                            name: 'employee_id',
                            title: 'Employee ID',
                            width: 60
                        },
                        {
                            data: 'full_name',
                            name: 'full_name',
                            title: 'Name'
                        },
                        {
                            data: 'salary',
                            name: 'salary',
                            title: 'Basic Salary'
                        },
                        {
                            data: 'total_service_amount',
                            name: 'total_service_amount',
                            title: 'Total Service'
                        },
                        {
                            data: 'commission',
                            name: 'commission',
                            title: 'Commission(%)'
                        },
                        {
                            name: 'commission_amount',
                            data : 'commission_amount',
                            title: 'Commission',
                        },
                        {
                            name: 'addition',
                            title: 'Addition',
                            data: function (row) {
                                if(row.addition != undefined && row.addition)
                                    return '<input type="number" class="calculate-sum addition" min="0" value="'+row.addition+'" placeholder="Addition">';
                                return '<input type="number" class="calculate-sum addition" min="0" value="0" placeholder="Addition">';
                            }

                        },
                        {
                            name: 'total',
                            title: 'Total',
                            data: function (row) {
                                return '<input type="number" class="calculate-sum total" placeholder="Total" readonly>';
                            }

                        },
                        {
                            name: 'deduction',
                            title: 'Deduction',
                            data: function (row) {
                                if(row.deduction != undefined && row.deduction)
                                    return '<input type="number" class="calculate-sum deduction" min="0" value="'+row.deduction+'" placeholder="Deduction">';
                                return '<input type="number" class="calculate-sum deduction" min="0" value="0" placeholder="Deduction">';
                            }

                        },
                        {
                            name: 'netpay',
                            title: 'Net Pay',
                            data: function (row) {
                                return '<input type="number" class="netpay" placeholder="Net Pay" value="0" readonly >';
                            }

                        },
                        {
                            name: 'pay',
                            title: 'Paid <input type="checkbox" class="pay-all" value="1">',
                            width: 8,
                            data: function (row) {
                                if(row.is_paid != undefined && row.is_paid)
                                    return '<input type="checkbox" class="pay" value="1" checked>';
                                return '<input type="checkbox" class="pay" value="1">';
                            }

                        }
                    ],
                    fixedColumns: false,
                    data: data,
                    drawCallback: function( settings ) {
                        $('.calculate-sum').trigger('change');
                    }
                });
            } else {
                dTable.clear().rows.add(data).draw();
                $(".dTableDelete").hide();
            }
        },
        ShowProcessedSalary : function(){
            JsManager.StartProcessBar();
            var jsonParam = 'year='+$('#year').val()+'&month='+$('#month').val()+'&sch_employee_id='+$('#sch_employee_id').val();
            var serviceUrl = "salaries-processed";
            JsManager.SendJson("GET", serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                if (jsonData.status == "1") {
                    Manager.LoadDataTable(jsonData.data); //reload datatable
                } else {
                    Message.Error("Unable to load data");
                }
                JsManager.EndProcessBar();
            }

            function onFailed(xhr, status, err) {
                JsManager.EndProcessBar();
                Message.Exception(xhr);
            }
        }


    };

})(jQuery);
