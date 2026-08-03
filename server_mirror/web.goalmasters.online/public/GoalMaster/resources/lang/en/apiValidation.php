<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Validation Language Lines
    |--------------------------------------------------------------------------
    |
    | The following language lines contain the default error messages used by
    | the validator class. Some of these rules have multiple versions such
    | as the size rules. Feel free to tweak each of these messages here.
    |
    */
    'validation_errors' => 'Validation Errors',  
    'The name field is required.' => 'The name field is required.',  
    'The name must be at least 5 characters.' => 'The name must be at least 5 characters.',  
    'The name may not be greater than 255 characters.' => 'The name may not be greater than 255 characters.',  

    'The username field is required.' => 'The username field is required.',  
    'The username has already been taken.' => 'The username has already been taken.',  
    'The username must be at least 5 characters.' => 'The username must be at least 5 characters.',  
    'The username may not be greater than 255 characters.' => 'The username may not be greater than 255 characters.',  
    'The selected username is invalid.' => 'The selected username is invalid.',  

    'The password field is required.' => 'The password field is required.',  
    'The password must be at least 8 characters.' => 'The password must be at least 8 characters.',  
    'The password confirmation does not match.' => 'The password confirmation does not match.',  

    'The phone number field is required.' => 'The phone number field is required.',  
    'The phone number must be a number.' => 'The phone number must be a number.',  
    'The phone number has already been taken.' => 'The phone number has already been taken.',  
    'The phone number format is invalid.' => 'The phone number format is invalid. It must start with 09 followed by 8 digits.',  
    'The selected phone number is invalid.' => 'The selected phone number is invalid.',
    'The phone field is required.' => 'The phone field is required.',  
    'The phone must be a number.' => 'The phone must be a number.',  
    'The phone format is invalid.' => 'The phone format is invalid. It must start with 09 followed by 8 digits.',  
    'The selected phone is invalid.' => 'The selected phone does not exist in the system.',

    'The code field is required.' => 'The code field is required.',  
    'The code must be a number.' => 'The code must be a number.',  
    'The code must be 6 digits.' => 'The code must be 6 digits.',  
    'code is not valid' => 'The code is not valid.',  
    'The code is valid' => 'The code is valid.',  
    'OTP sent successfully' => 'OTP sent successfully',
    
    'prohibited_unless' => 'Either the username or phone number must be provided.',  
    'The username field is required when phone number is not present.' => 'The username field is required when phone number is not present.',
    'The phone number field is required when username is not present.' => 'The phone number field is required when username is not present.',
   
    'The forget field must be true or false.' => 'The forget field must be true or false.',  
    'Invalid reset token' => 'Invalid reset token.',  
    'Password changed successfully' => 'Password changed successfully.',  
    'The reset token field is required and must be a valid string existing in users.' => 'The reset token field is required and must be a valid string existing in users.',  
    'The selected reset token is invalid.' => 'The selected reset token is invalid.',  
    'The old password field is required.' => 'The old password field is required.',
    'The old password must be between 8 and 35 characters when provided.' => 'The old password must be between 8 and 35 characters when provided.',  
    'The password field is required, must be at least 8 characters, and must match the password confirmation.' => 'The password field is required, must be at least 8 characters, and must match the password confirmation.',  
    'Invalid old password' => 'Invalid old password.',  
    'Token has expired, please log in again.' => 'Token has expired, please log in again.',  
    'Token is invalid or missing.' => 'Token is invalid or missing.',  

    'Profile Updated Successfully' => 'Profile Updated Successfully.',
    'Something went wrong' => 'Something went wrong.',
    'User logged out successfully' => 'User logged out successfully.',
    'Profile updated successfully' => 'Profile updated successfully.',  
    'Please provide at least one filter parameter: day, time, or date range.' => 'Please provide at least one filter parameter: day, time, or date range.',
    'Available time slots for the selected day:' => 'Available time slots for the selected day:',
    'The requested appointment is not available on the selected day. Alternative days for the same time:' => 'The requested appointment is not available on the selected day. Alternative days for the same time:',  
    'The requested appointment is not available. Alternative time slots for the day:' => 'The requested appointment is not available. Alternative time slots for the day:',  
    'The requested appointment is available.' => 'The requested appointment is available.',  
    'Available time slots for the given date range:' => 'Available time slots for the given date range:',  
    'Days available for the requested time:' => 'Days available for the requested time:', 

    'The branch field must be a valid integer.' => 'The branch field must be a valid integer.',  
    'The selected branch does not exist.' => 'The selected branch does not exist.',  
    'The start time must be in the format YYYY-MM-DD.' => 'The start time must be in the format YYYY-MM-DD.',  
    'The end time must be in the format YYYY-MM-DD.' => 'The end time must be in the format YYYY-MM-DD.',  
    'The booking start date is required.' => 'The booking start date is required.',  
    'The booking start date must be in the format YYYY-MM-DD.' => 'The booking start date must be in the format YYYY-MM-DD.',  
    'The booking end date is required.' => 'The booking end date is required.',  
    'The booking end date must be in the format YYYY-MM-DD.' => 'The booking end date must be in the format YYYY-MM-DD.',  
    'The booking start field is required.' => 'The booking start field is required.',  
    'The booking end field is required.' => 'The booking end field is required.',  

    'The start time field must have a value.' => 'The start time field must have a value.',  
    'The end time field must have a value.' => 'The end time field must have a value.',  
    'The branch must be an integer.' => 'The branch must be an integer.',  
    'The selected branch is invalid.' => 'The selected branch is invalid.',  
    'The start time does not match the format H:i:s.' => 'The start time does not match the format H:i:s.',  
    'The end time does not match the format H:i:s.' => 'The end time does not match the format H:i:s.',  
    'The branch field must have a value.' => 'The branch field must have a value.',
    
    'The zone field is required.' => 'The zone field is required.',  
    'The selected zone is invalid.' => 'The selected zone is invalid.',  
    'The branch field is required.' => 'The branch field is required.',  
    'The category field is required.' => 'The category field is required.',  
    'The category must be an integer.' => 'The category must be an integer.',  
    'The selected category is invalid.' => 'The selected category is invalid.', 
    
    'Notification marked as read' => 'Notification marked as read.',  
    'Notification not found' => 'Notification not found.',  
    'All notifications marked as read' => 'All notifications marked as read.',  

    'The service date field is required.' => 'The service date field is required.',  
    'The id field is required.' => 'The id field is required.',  
    'The service date must be a date after or equal to today.' => 'The service date must be a date after or equal to today.',  
    'The service date is not a valid date.' => 'The service date is not a valid date.',  

    'The date field is required.' => 'The date field is required.',
    'The date must be a date after or equal to today.' => 'The date must be a date after or equal to today.',
    'The date is not a valid date.' => 'The date is not a valid date.',

    'The branch id field is required.' => 'The branch id field is required.',
    'The selected branch id is invalid.' => 'The selected branch is invalid.',

    'The service id field is required.' => 'The service id field is required.',
    'The selected service id is invalid.' => 'The selected service is invalid.',

    'The employee id field is required.' => 'The employee id field is required.',
    'The selected employee id is invalid.' => 'The selected employee id is invalid.',

    'The payment type field is required.' => 'The payment type field is required.',
    'The selected payment type is invalid.' => 'The selected payment type is invalid.',

    'The full name field is required.' => 'The full name field is required.',
    'The full name may not be greater than 255 characters.' => 'The full name may not be greater than 255 characters.',

    'The phone no field is required.' => 'The phone no field is required.',
    'The phone no format is invalid.' => 'The phone no format is invalid. It must start with +218 or 9 followed by 8 digits.',

    'The state field is required.' => 'The state field is required.',
    'The selected state is invalid.' => 'The selected state is invalid.',

    'The postal code may not be greater than 10 characters.' => 'The postal code may not be greater than 10 characters.',
    'The city may not be greater than 100 characters.' => 'The city may not be greater than 100 characters.',
    'The street address may not be greater than 255 characters.' => 'The street address may not be greater than 255 characters.',
    'You do not have enough balance in your account' => 'ليس لديك رصيد كافٍ في حسابك.',
    'You can\'t make payment by user balance without login try another one' => 'لا يمكنك الدفع باستخدام رصيد المستخدم دون تسجيل الدخول، جرب طريقة أخرى.',
    'Failed to save or get customer' => 'فشل في حفظ أو استرجاع بيانات العميل.',
    'The selected service is booked, try another one' => 'الخدمة المحددة محجوزة، جرب خدمة أخرى.',

    'The coupon code may not be greater than 255 characters.' => 'يجب ألا يتجاوز رمز القسيمة 255 حرفًا.',
    'Card not found or already charged' => 'Card not found or already charged.',
    'Card charged successfully' => 'Card charged successfully.',
    'The selected code is invalid.' => 'The selected code is invalid.',  
    'Unauthorized' => 'Unauthorized.',

    'The selected id is invalid.' => 'The selected id is invalid.',

    'The customer id field is required.' => 'The customer id field is required.',
    'The selected customer id is invalid.' => 'The selected customer id is invalid.',

    'The service time field is required.' => 'The service time field is required.',
    'The service time format is invalid.' => 'The service time format is invalid. It must be in the format HH:MM-HH:MM.',

    'The status field is required.' => 'The status field is required.',
    'The selected status is invalid.' => 'The selected status is invalid.',

    'The paid amount field is required.' => 'The paid amount field is required.',
    'The paid amount must be at least 0.' => 'The paid amount must be at least 0.',

    'The payment type id field is required.' => 'The payment type id field is required.',
    'The selected payment type id is invalid.' => 'The selected payment type id is invalid.',

    'The isForceBooking field is required.' => 'The isForceBooking field is required.',
    'The isForceBooking field must be true or false.' => 'The isForceBooking field must be true or false.',

    'The remarks may not be greater than 500 characters.' => 'The remarks may not be greater than 500 characters.',
    
    'The booking id field is required.' => 'The booking id field is required.',
    'The selected booking id is invalid.' => 'The selected booking id is invalid.',
    'The :field amount cannot exceed the maximum allowed value: :maxAmount' => 'The :field amount cannot exceed the maximum allowed value: :maxAmount.',

    'max_amount_exceeded' => 'The :field amount cannot exceed the maximum allowed value: :maxAmount.',
    'server_error' => 'An unexpected error occurred, please try again.',
    'attributes.due amount cannot exceed the maximum allowed value:' => 'The due amount cannot exceed the maximum allowed value: :maxAmount.',
    'attributes.extra_input amount cannot exceed the maximum allowed value:' => 'The extra_input amount cannot exceed the maximum allowed value: :maxAmount.',

];
