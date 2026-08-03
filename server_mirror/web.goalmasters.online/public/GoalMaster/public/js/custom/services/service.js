(function ($) {
    "use strict";
    var dTable = null;

    $(document).ready(function () {

        //load datatable
        ServiceManager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);


        //load branch name dropdown
        // ServiceManager.LoadServiceCategoryDropDown();
        ServiceManager.LoadBranchDropDown();




        //add  modal
        $("#btnAdd").on("click",function () {
            ServiceManager.ResetForm();
            $("#frmModal").modal('show');
        });

        //save or update
        JsManager.JqBootstrapValidation('#inputForm', (form, event) => {
            event.preventDefault();
            var formData = new FormData(document.querySelector('#inputForm'));
            if ($('#id').val() == null || $('#id').val() == '') {
                ServiceManager.Save(formData);
            } else {
                ServiceManager.Update(formData);
            }
        });
    });


    //photo preview
    $(document).on('change', '#serviceimage', function () {
        var output = document.getElementById('imagepreview');
        output.src = URL.createObjectURL(event.target.files[0]);
        output.onload = function () {
            URL.revokeObjectURL(output.src) // free memory
        }
    });
    
    //on cahnge branch -> load reated service
    $("#cmn_branch_id").on("change", function () {
        ServiceManager.LoadServiceCategoryDropDown($(this).val());
    });




    //show edit info modal
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();

        $('#id').val(rowData.id);
        $('#cmn_branch_id').val(rowData.cmn_branch_id);
        $('#sch_service_category_id').val(rowData.sch_service_category_id);
        $('#imagepreview').attr("src", rowData.image);

        $('#title').val(rowData.title);
        $('#price').val(rowData.price);
        $('#appoinntment_limit_type').val(rowData.appoinntment_limit_type);
        $('#appoinntment_limit').val(rowData.appoinntment_limit);

        let duration_in_time = rowData.duration_in_time;
        $('#duration_in_days').val(rowData.duration_in_days);
        $('#durationTimeHour').val(parseInt(JsManager.TimeToHour(duration_in_time)));
        $('#durationTimeMinute').val(parseInt(JsManager.TimeToMinute(duration_in_time)));

        let time_slot_in_time = rowData.time_slot_in_time;
        $('#time_slot_in_time_hour').val(parseInt(JsManager.TimeToHour(rowData.time_slot_in_time)));
        $('#time_slot_in_time_minute').val(parseInt(JsManager.TimeToMinute(time_slot_in_time)));


        let padding_time_before = rowData.padding_time_before;
        $('#padding_time_before_hour').val(parseInt(JsManager.TimeToHour(padding_time_before)));
        $('#padding_time_before_minute').val(parseInt(JsManager.TimeToMinute(padding_time_before)));

        let padding_time_after = rowData.padding_time_after;
        $('#padding_time_after_hour').val(parseInt(JsManager.TimeToHour(padding_time_after)));
        $('#padding_time_after_minute').val(parseInt(JsManager.TimeToMinute(padding_time_after)));

        let minimum_time_required_to_booking_in_time = rowData.minimum_time_required_to_booking_in_time;
        $('#minimum_time_required_to_booking_in_hour').val(parseInt(JsManager.TimeToHour(minimum_time_required_to_booking_in_time)));
        $('#minimum_time_required_to_booking_in_minute').val(parseInt(JsManager.TimeToMinute(minimum_time_required_to_booking_in_time)));

        let minimum_time_required_to_cancel_in_time = rowData.minimum_time_required_to_cancel_in_time;
        $('#minimum_time_required_to_cancel_in_hour').val(parseInt(JsManager.TimeToHour(minimum_time_required_to_cancel_in_time)));
        $('#minimum_time_required_to_cancel_in_minute').val(parseInt(JsManager.TimeToMinute(minimum_time_required_to_cancel_in_time)));


        $('#minimum_time_required_to_booking_in_days').val(rowData.minimum_time_required_to_booking_in_days);
        $('#minimum_time_required_to_cancel_in_days').val(rowData.minimum_time_required_to_cancel_in_days);

        $('#visibility').val(rowData.visibility);
        $('#sch_service_categoriy_id').val(rowData.sch_service_categoriy_id);
        $('#appoinntment_limit_limitType').val(rowData.appoinntment_limit_limitType);
        $('#remarks').val(rowData.remarks);

        $("#frmModal").modal('show');
    });


    //delete
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        ServiceManager.Delete(rowData.id);
    });


    var ServiceManager = {

        ResetForm: function () {
            $("#inputForm").trigger('reset');
            $('#imagepreview').attr("src", "");
            $("#id").val('');

        },

        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "service-save";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {

                    if (jsonData.status == "1") {
                        Message.Success("save");
                        ServiceManager.ResetForm();
                        ServiceManager.GetDataList(1); //reload datatable
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

        Update: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form;
                var serviceUrl = "service-update";
                JsManager.SendJsonWithFile("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {

                    if (jsonData.status == "1") {
                        Message.Success("update");
                        ServiceManager.ResetForm();
                        ServiceManager.GetDataList(1); //reload datatable
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
                var serviceUrl = "service-delete";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    JsManager.EndProcessBar();
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        ServiceManager.GetDataList(1); //reload datatable
                    } else {
                        Message.Error("delete");
                    }

                }

                function onFailed(xhr, status, err) {
                    JsManager.EndProcessBar();
                    Message.Exception(xhr);
                }
            }
        },


        LoadServiceCategoryDropDown: function (branchId) {
            var jsonParam = '';
            var serviceUrl = "get-site-service-category";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                
                
                var filteredCategories = jsonData.data.filter(function (category) {
                    return category.cmn_branch_id == branchId; // Assuming 'branch_id' is a property of the category
                });
                JsManager.PopulateCombo("#sch_service_category_id", filteredCategories, "Select Category", '');

                // JsManager.PopulateCombo("#sch_service_category_id", jsonData.data, "Select Category", '');
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        
        
        LoadBranchDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-branch";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#cmn_branch_id", jsonData.data,"إختر ادارة", '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        


        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-service";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                ServiceManager.LoadDataTable(jsonData.data, refresh);
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
                                columns: [2, 3, 4, 5, 6]
                            },
                            title: 'Service List'
                        },
                        {
                            text: '<i class="fa fa-print"></i> Print',
                            className: 'btn btn-sm',
                            extend: 'print',
                            exportOptions: {
                                columns: [2, 3, 4, 5, 6]
                            },
                            title: 'Service List'
                        },
                        {
                            text: '<i class="fa fa-file-excel"></i> Excel',
                            className: 'btn btn-sm',
                            extend: 'excelHtml5',
                            exportOptions: {
                                columns: [2, 3, 4, 5, 6]
                            },
                            title: 'Service List'
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
                            render: function (data, limitType, row) {
                                return EventManager.DataTableCommonButton();
                            }
                        },
                        {
                            data: 'title',
                            name: 'title',
                            title: 'Title'
                        },
                        {
                            data: 'category',
                            name: 'category',
                            title: 'Category'
                        },
                        {
                            data: 'price',
                            name: 'price',
                            title: 'Service Price'
                        },
                        {
                            data: 'image_url',
                            name: 'image_url',
                            title: 'Service Image',
                            orderable: false,
                            searchable: false,
                            render: function(data, type, row) {
                                if(data) {
                                    return '<img src="' + data + '" alt="service image" style="width:50px; height:50px; object-fit:cover; border-radius:4px;" />';
                                } else {
                                    return '<img src="/img/ball.png" alt="default image" style="width:50px; height:50px; object-fit:cover; border-radius:4px;" />';
                                }
                            }
                        },

                        // {
                        //     data: 'duration_in_days',
                        //     name: 'duration_in_days',
                        //     title: 'Service duration',
                        //     render: function (data, limitType, row) {
                        //         return data + " days, " + JsManager.TimeToHourMinute(row["duration_in_time"]);
                        //     }
                        // },
                        {
                            data: 'time_slot_in_time',
                            name: 'time_slot_in_time',
                            title: 'Service duration',
                            // render: function (data, limitType, row) {
                            //     return data + " days, " + JsManager.TimeToHourMinute(row["duration_in_time"]);
                            // }
                        },
                        {
                            data: 'visibility',
                            name: 'visibility',
                            title: 'Visibility',
                            render: function (data, type, row) {
                                let visibility;
                                if (row["visibility"] == 1) {
                                    visibility = "Public";
                                } else {
                                    visibility = "Private";
                                }
                                return visibility;
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
