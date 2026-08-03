(function ($) {
    "use strict";

    var dTable = null;
    var _id = null;

    $(document).ready(function () {
        //load user info datatable
        UserManager.GetDataList(0);

        //generate datatabe serial no
        dTableManager.dTableSerialNumber(dTable);

        //load role dropdown
        UserManager.LoadRoleDropDown();
        UserManager.LoadBranchDropDown();
        UserManager.LoadEmployeeDropDown();

        //save or update
        JsManager.JqBootstrapValidation('#userForm', (form, event) => {
            event.preventDefault();
            if (_id == null) {
                UserManager.Save(form);
            } else {
                UserManager.Update(form, _id);
            }
        });

        //add user info modal
        $("#btnAddUser").on("click", function () {
            $(".div-password").find('input').attr('readonly', false);
            $("#frmUserModal").modal('show');

            // $('#branchAndEmployee').addClass('d-none');
            // $('#branchAndEmployee').removeClass('d-block');

            $('#web_user').addClass('d-none');
            $('#web_user').removeClass('d-block');

            $('#system_user').addClass('d-none');
            $('#system_user').removeClass('d-block');

            UserManager.ResetForm();
            _id = null;
        });

        // $('#sec_role_id').on('change', function () {
        // 	if ($(this).val() != 2 && $(this).val() != '') {
        // 		$('#branchAndEmployee').removeClass('d-none');
        // 		$('#branchAndEmployee').addClass('d-block');
        // 	} else {
        // 		$('#branchAndEmployee').addClass('d-none');
        // 		$('#branchAndEmployee').removeClass('d-block');
        //         // UserManager.ResetForm();


        // 		// Dashboard.Common(); // Trigger dashboard refresh for non-custom selections
        // 	}
        // });


        $('#userType').on('change', function () {
            if ($(this).val() == 1) { // System User
                $('#system_user').addClass('d-block').removeClass('d-none');

                $('#sec_role_id').attr('required', 'required');
                $('#sec_role_id').attr('data-validation-required-message', 'User Role is required');

                $('#cmn_branch_id').attr('required', 'required');
                $('#cmn_branch_id').attr('data-validation-required-message', 'User Branch is required');



                $('#web_user').addClass('d-none').removeClass('d-block');

                $('#phone_no').removeAttr('required');
                $('#phone_no').removeAttr('data-validation-required-message');

            }

            else if ($(this).val() == 'WebUser') { // Web User
                $('#web_user').addClass('d-block').removeClass('d-none');

                $('#phone_no').attr('required', 'required');
                $('#phone_no').attr('data-validation-required-message', 'Phone Number is required');


                $('#system_user').addClass('d-none').removeClass('d-block');

                $('#sec_role_id').removeAttr('required');
                $('#sec_role_id').removeAttr('data-validation-required-message');

                $('#cmn_branch_id').removeAttr('required');
                $('#cmn_branch_id').removeAttr('data-validation-required-message');

            }
        });




    });

    //show edit user info modal
    $(document).on('click', '.dTableEdit', function () {
        var rowData = dTable.row($(this).parent()).data();
        _id = rowData.id;
        $('#name').val(rowData.name);
        $('#email').val(rowData.email);
        $('#phone_no').val(rowData.phone_number);
        $('#username').val(rowData.username);
        $('#sec_role_id').val(rowData.sec_role_id);
        $('#cmn_branch_id').selectpicker('val', rowData.userBranch.map((item) => item.id));
        $('#sch_employee_id').selectpicker('val', rowData.sch_employee_id);
        $(".div-password").find('input').val('00000000');
        if (rowData['status'] == 1) {
            $('#statusYes').prop('checked', true);
        }
        else {
            $('#statusNo').prop('checked', true);
        }
        setTimeout(() => {
            $("#password_confirmation").focus();
        }, 400);

        $("#frmUserModal").modal('show');

    });

    //delete user info
    $(document).on('click', '.dTableDelete', function () {
        var rowData = dTable.row($(this).parent()).data();
        UserManager.Delete(rowData.id);
    });

    ////////////////////////////////
    // add balanc to user
    $(document).ready(function () {

        $('#addBalanceForm').on('submit', function (event) {


            event.preventDefault();

            var userId = $('#userId').val();
            var balanceAmount = $('#balanceAmount').val();

            if (balanceAmount === "" || isNaN(balanceAmount)) {
                alert("Please enter a valid balance amount.");
                return;
            }

            $.ajaxSetup({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                }
            });


            $.ajax({
                url: '/user-balance-add',
                type: 'post',
                data: {
                    // _token: '{{ csrf_token() }}',  // Include CSRF token
                    user_id: userId,
                    balance: balanceAmount
                },
                success: function (response) {
                    // Handle the successful response here
                    alert('Balance added successfully: ' + response.message);

                    // Close the modal after adding balance
                    $('#addBalanceModal').modal('hide');

                    // Reset the form fields
                    $('#addBalanceForm')[0].reset();

                    // refresh your DataTable to reflect the updated balance
                    UserManager.GetDataList(1);  // Reload datatable
                },
                error: function (xhr) {
                    // Handle the error response here
                    console.log(xhr.responseText);
                    alert('Error adding balance');
                }
            });
        });
    });
    ////////////////////////////

    //window.
    window.UserManager = {
        ResetForm: function () {
            $("#userForm").trigger('reset');
            $("#cmn_branch_id").selectpicker('refresh');
        },
        Save: function (form) {
            if (Message.Prompt()) {
                JsManager.StartProcessBar();
                var jsonParam = form.serialize() + "&cmn_branch_id=" + $("#cmn_branch_id").val();
                var serviceUrl = "register-new-user";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("save");
                        form.trigger('reset');
                        UserManager.GetDataList(1); //reload datatable
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
                var jsonParam = form.serialize() + '&id=' + id + "&cmn_branch_id=" + $("#cmn_branch_id").val();
                var serviceUrl = "update-user-info";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("update");
                        UserManager.GetDataList(1); //reload datatable
                        _id = null;
                        form.trigger('reset');
                        $("#frmUserModal").modal('hide');
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
                var serviceUrl = "delete-user-info";
                JsManager.SendJson("POST", serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData.status == "1") {
                        Message.Success("delete");
                        UserManager.GetDataList(1); //reload datatable
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

        ////////////////////////
        showAddBalanceModal: function (userId) {
            // Show the modal and populate with the user ID
            $('#addBalanceModal').modal('show');
            $('#userId').val(userId); // Set hidden input with user ID in the form
        },
        //////////////////////////

        GetDataList: function (refresh) {
            var jsonParam = '';
            var serviceUrl = "get-user-info";
            JsManager.SendJsonAsyncON('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                UserManager.LoadDataTable(jsonData.data, refresh);
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
                            width: 70,
                            render: function (data, type, row) {
                                return EventManager.DataTableCommonButton();
                            }
                        },
                        {
                            data: 'username',
                            name: 'username',
                            title: 'User Name'
                        },
                        // {
                        //     data: 'email',
                        //     name: 'email',
                        //     title: 'Email'
                        // },
                        {
                            data: 'role',
                            name: 'role',
                            title: 'User Role'
                        },
                        {
                            data: 'user_type',
                            name: 'user_type',
                            title: 'User Type',
                            render: function (data, type, row) {
                                let val = "System User";
                                if (data == 2)
                                    val = "Web User";
                                return val;
                            }
                        },
                        {
                            data: 'employee',
                            name: 'employee',
                            title: 'Staff For'
                        },
                        {
                            data: 'userBranch',
                            name: 'userBranch',
                            title: 'Branch',
                            render: function (data, type, row) {
                                var branch = '';
                                $.each(data, function (i, v) {
                                    branch += v.name + ", ";
                                })
                                branch = branch.slice(0, -2);
                                return branch;
                            }
                        },
                        /////////////////////////////////////////////
                        {
                            // Column to display the balance
                            data: 'totalBalance',
                            name: 'totalBalance',
                            title: 'Balance',

                        },
                        {
                            //     // Add Balance button
                            data: null,
                            name: 'addBalance',
                            title: 'Add Balance',
                            orderable: false,
                            searchable: false,
                            visible: isAdmin == 1,
                            render: function (data, type, row) {
                                // Add button that triggers modal
                                return '<button class="btn btn-sm btn-primary" onclick="UserManager.showAddBalanceModal(' + row.id + ')">اضافة رصيد</button>';
                            }
                        },
                        //////////////////////////////////

                        {
                            data: 'status',
                            name: 'status',
                            title: 'Status',
                            //width: 50,
                            render: function (data, type, row) {
                                var status = data ? "Active" : "Inactive";
                                return status;
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

        LoadRoleDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-roles";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#sec_role_id", jsonData.data, "اخنر صلاحية");
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },

        LoadBranchDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-site-branch";
            // var serviceUrl = "get-branch-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                JsManager.PopulateComboSelectPicker("#cmn_branch_id", jsonData.data);
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
        LoadEmployeeDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-employee-dropdown";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);
            function onSuccess(jsonData) {
                JsManager.PopulateComboSelectPicker("#sch_employee_id", jsonData.data, 'All', '');
            }
            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
    };
})(jQuery);