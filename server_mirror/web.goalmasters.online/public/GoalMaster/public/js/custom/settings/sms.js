(function ($) {
    "use strict";
    $('#enable-twilio').click(function(){
        var $item = $(this);
        if($item.prop("checked")){
            $('#twilio_sid').attr('required','required');
            $('#twilio_token').attr('required','required');
            $('#twilio_phone_no').attr('required','required');
        }else{
            $('#twilio_sid').removeAttr('required');
            $('#twilio_token').removeAttr('required');
            $('#twilio_phone_no').removeAttr('required');
        }
    });

    if($('#enable-twilio:checked').length){
        $('#twilio_sid').attr('required','required');
        $('#twilio_token').attr('required','required');
        $('#twilio_phone_no').attr('required','required');
    }else{
        $('#twilio_sid').removeAttr('required');
        $('#twilio_token').removeAttr('required');
        $('#twilio_phone_no').removeAttr('required');
    }
})(jQuery);