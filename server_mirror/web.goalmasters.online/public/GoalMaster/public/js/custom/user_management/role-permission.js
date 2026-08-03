(function ($) {
    "use strict";
    $(document).ready(function () {
        RolePermissionManager.LoadRoleDropDown();


        // first example
        $("#browser").treeview();

        // second example
        $("#navigation").treeview({
            persist: "location",
            collapsed: false,
            unique: true
        });

        // third example
        $("#red").treeview({
            animated: "fast",
            collapsed: true,
            unique: true,
            persist: "cookie",
            toggle: function () {
            }
        });

        // fourth example
        $("#black, #gray").treeview({
            control: "#treecontrol",
            persist: "cookie",
            cookieId: "treeview-black"
        });

        $("#cmbRole").on("change",function () {
            window.location = JsManager.BaseUrl() + "/role-permission?id=" + $(this).val();
        });

        $("#btnSaveRolePermission").on("click",function () {
            RolePermissionManager.SaveOrUpdatePermission();
        });

        $(".chkPermission").on("change",function () {
            var $item = $(this);
            if ($item.siblings('ul').find(".chkPermission").length > 0) {
                $item.siblings('ul').find(".chkPermission").prop("checked", $item.prop('checked'));
                if ($item.siblings('ul').find(".chkPermission1").length > 0) {
                    $item.siblings('ul').find(".chkPermission1").prop("checked", $item.prop('checked'));
                }
            } else {
                $item.siblings(".chkPermission1").prop("checked", $item.prop('checked'));
            }
        });

        $(".chkPermissionAll").on("change",function () {
            var $item = $(this);
            if ($item.prop("checked")) {
                if ($item.siblings('.chkPermission').prop("checked") == false) {
                    $item.siblings('.chkPermission').prop("checked", true);
                }

                if ($item.closest('ul').closest('li').find('input[type=checkbox]').first().prop("checked") == false) {
                    $item.closest('ul').closest('li').find('input[type=checkbox]').first().prop("checked", true);
                }

                if ($item.closest('ul').closest('li').closest('ul').closest('li').find('input[type=checkbox]').first().prop("checked") == false) {
                    $item.closest('ul').closest('li').closest('ul').closest('li').find('input[type=checkbox]').first().prop("checked", true);
                }
            }
        });

    });



    var RolePermissionManager = {

        SaveOrUpdatePermission: function () {
            var resource = [];
            var rolePermission = [];
            $.each($("#Chk_Parent").siblings('ul').find("input[type=checkbox]"), function (i, v) {
                var resourceId = $(v).data('resid');
                var rolePermissionId = $(v).data('roleprmiid');
                if (typeof (rolePermissionId) != 'undefined') {
                    var objRolePermi = new Object();
                    objRolePermi.SecResourceId = resourceId;
                    objRolePermi.SecRolePermissionInfoId = rolePermissionId;
                    objRolePermi.Status = $(v).prop("checked") ? 1 : 0;
                    rolePermission.push(objRolePermi);
                } else {
                    var objRes = new Object();
                    objRes.SecResourceId = resourceId;
                    objRes.Status = $(v).prop("checked") ? 1 : 0;
                    resource.push(objRes);
                }

            });
            if (resource.length > 0 && rolePermission.length > 0) {
                JsManager.StartProcessBar();
                var jsonParam = { permissionData: { roleId: $("#cmbRole").val(), resource: resource, rolePermission: rolePermission } };
                var serviceUrl = "save-or-update-permission";
                JsManager.SendJson('POST', serviceUrl, jsonParam, onSuccess, onFailed);

                function onSuccess(jsonData) {
                    if (jsonData == "0") {
                        Message.Warning("You have nothing to save");
                    } else {
                        Message.Success("save");
                    }
                    JsManager.EndProcessBar();
                }

                function onFailed(xhr, status, err) {
                    Message.Exception(xhr);
                    JsManager.EndProcessBar();
                }
            }
        },

        LoadRoleDropDown: function () {
            var jsonParam = '';
            var serviceUrl = "get-roles";
            JsManager.SendJson('GET', serviceUrl, jsonParam, onSuccess, onFailed);

            function onSuccess(jsonData) {
                JsManager.PopulateCombo("#cmbRole", jsonData.data, "Select Role");
                if (JsManager.UrlParams('id') != null) {
                    $("#cmbRole").val(JsManager.UrlParams('id'));
                }
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        },
    };
})(jQuery);

function EditSpan(obj) {
    var itm = $(obj).closest('li').find('.txtDisplayName').first();
    itm.removeAttr('disabled').removeAttr('style');
    itm.css({ "border-radius": "2px", "border": "1px solid #f57676", "padding-left": "2px" });
    $(obj).hide();
    $(obj).siblings('.saveIcon').show();
}

function SaveSpan(obj) {
    var jsonParam = {
        roleId: $('#cmbRole').val(),
        resourceId: $(obj).data('resid'),
        displayName: $(obj).closest('li').find('.txtDisplayName').first().val()
    };
    JsManager.StartProcessBar();
    var serviceUrl = "update-resource-display-name";
    JsManager.SendJson('POST', serviceUrl, jsonParam, onSuccess, onFailed);
    function onSuccess(jsonData) {
        jsonData = jsonData.status;
        if (jsonData == "0") {
            Message.Error("save");
        } else if (jsonData == "-1010") {
            Message.Warning("Need to add permission at first");
            var item = $(obj).closest('li').find('.txtDisplayName').first();
            item.removeAttr('disabled').removeAttr('style');
            item.css({ "border": "none", "background": "none" });
            $(obj).hide();
            $(obj).siblings('.editIcon').show();
        } else if (jsonData == "-1011") {
            Message.Warning("Nothing to save");
            var item1 = $(obj).closest('li').find('.txtDisplayName').first();
            item1.removeAttr('disabled').removeAttr('style');
            item1.css({ "border": "none", "background": "none" });
            $(obj).hide();
            $(obj).siblings('.editIcon').show();
        }
        else {
            var itm = $(obj).closest('li').find('.txtDisplayName').first();
            itm.removeAttr('disabled').removeAttr('style');
            itm.css({ "border": "none", "background": "none" });
            $(obj).hide();
            $(obj).siblings('.editIcon').show();
            Message.Success("save");
        }
        JsManager.EndProcessBar();
    }
    function onFailed(xhr, status, err) {
        Message.Exception(xhr);
        JsManager.EndProcessBar();
    }

}