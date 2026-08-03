
var ClientOrderDetails;

(function ($) {
    "use strict";
    $(document).on("change","#change-status",function(){
        if(confirm("Are you sure you want to change the status?")){
            var jsonParam = {
                status : $('#change-status').val(),
                _method : 'PUT'
            };
            var serviceUrl = "orders/"+orderId;
            JsManager.SendJsonAsyncON('POST', serviceUrl, jsonParam, onSuccess, onFailed, true);

            function onSuccess(jsonData) {
                Message.Success("Successfully updated!");
                window.location.reload();
            }

            function onFailed(xhr, status, err) {
                Message.Exception(xhr);
            }
        }
    })
})(jQuery);