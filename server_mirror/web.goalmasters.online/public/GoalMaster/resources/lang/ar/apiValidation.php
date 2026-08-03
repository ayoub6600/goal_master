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

    'validation_errors' => 'أخطاءالتحقق',  
    'The name field is required.' => 'حقل الاسم مطلوب.',  
    'The name must be at least 5 characters.' => 'يجب أن يكون الاسم على الأقل 5 أحرف.',  
    'The name may not be greater than 255 characters.' => 'يجب ألا يزيد الاسم عن 255 حرفًا.',  

    'The username field is required.' => 'حقل اسم المستخدم مطلوب.',  
    'The username has already been taken.' => 'اسم المستخدم مستخدم بالفعل.',  
    'The username must be at least 5 characters.' => 'يجب أن يكون اسم المستخدم على الأقل 5 أحرف.',  
    'The username may not be greater than 255 characters.' => 'يجب ألا يزيد اسم المستخدم عن 255 حرفًا.',  
    'The selected username is invalid.' => 'اسم المستخدم المحدد غير صالح.',  

    'The password field is required.' => 'حقل كلمة المرور مطلوب.',  
    'The password must be at least 8 characters.' => 'يجب أن تكون كلمة المرور على الأقل 8 أحرف.',  
    'The password confirmation does not match.' => 'تأكيد كلمة المرور غير متطابقه.',  

    'The phone number field is required.' => 'حقل رقم الهاتف مطلوب.',  
    'The phone number must be a number.' => 'يجب أن يكون رقم الهاتف رقمًا.',  
    'The phone number has already been taken.' => 'رقم الهاتف مستخدم بالفعل.',  
    'The phone number format is invalid.' => 'تنسيق رقم الهاتف غير صالح. يجب أن يبدأ بـ 09 ويتبعه 8 أرقام.',  
    'The selected phone number is invalid.' => 'رقم الهاتف المحدد غير صالح.',
    'The phone field is required.' => 'حقل رقم الهاتف مطلوب.',  
    'The phone must be a number.' => 'يجب أن يكون رقم الهاتف رقمًا.', 
    'The phone format is invalid.' => 'تنسيق رقم الهاتف غير صالح. يجب أن يبدأ بـ 09 ويتبعه 8 أرقام.',  
    'The selected phone is invalid.' => 'رقم الهاتف غير موجود في النظام.', 

    'prohibited_unless' => 'يجب تقديم اسم المستخدم أو رقم الهاتف.',  
    'The username field is required when phone number is not present.' => 'حقل اسم المستخدم مطلوب عند عدم وجود رقم الهاتف.',
    'The phone number field is required when username is not present.' => 'حقل رقم الهاتف مطلوب عند عدم وجود اسم المستخدم.',
   

    'code is not valid' => 'الكود غير صالح.',  
    'The code field is required.' => 'حقل الكود مطلوب.',  
    'The code must be a number.' => 'يجب أن يكون الكود رقمًا.', 
    'The code must be 6 digits.' => 'يجب أن يتكون الكود من 6 أرقام.',  
    'The code is valid' => 'الكود صالح.',  
    'OTP sent successfully' => 'تم ارسال الكود بنجاح',
   
    'The forget field must be true or false.' => 'يجب أن يكون حقل النسيان صحيحًا أو خطأ.',  
    'Invalid reset token' => 'رمز إعادة التعيين غير صالح.',  
    'Password changed successfully' => 'تم تغيير كلمة المرور بنجاح.',  
    'The reset token field is required and must be a valid string existing in users.' => 'حقل رمز إعادة التعيين مطلوب ويجب أن يكون سلسلة نصية موجودة في المستخدمين.',  
    'The selected reset token is invalid.' => 'رمز إعادة التعيين المحدد غير صالح.',  
    'The old password field is required.' => 'حقل كلمة المرور القديمة مطلوب.',
    'The old password must be between 8 and 35 characters when provided.' => 'يجب أن تكون كلمة المرور القديمة بين 8 و 35 حرفًا عند تقديمها.',  
    'The password field is required, must be at least 8 characters, and must match the password confirmation.' => 'حقل كلمة المرور مطلوب، ويجب أن يكون على الأقل 8 أحرف، ويجب أن يتطابق مع تأكيد كلمة المرور.',  
    'Invalid old password' => 'كلمة المرور القديمة غير صحيحة.',  
    'Token has expired, please log in again.' => 'انتهت صلاحية الرمز، يرجى تسجيل الدخول مرة أخرى.',  
    'Token is invalid or missing.' => 'الرمز غير صالح أو مفقود.',  

    'Profile Updated Successfully' => 'تم تحديث الملف الشخصي بنجاح.',  
    'Something went wrong' => 'حدث خطأ ما.',  
    'User logged out successfully' => 'تم تسجيل الخروج بنجاح.',
    'Profile updated successfully' => 'تم تحديث الملف الشخصي بنجاح.',  
   
    'Please provide at least one filter parameter: day, time, or date range.' => 'يرجى تقديم معلمة تصفية واحدة على الأقل: اليوم، الوقت، أو نطاق التاريخ.',  
    'Available time slots for the selected day:' => 'الأوقات المتاحة لليوم المحدد:',  
    'The requested appointment is not available on the selected day. Alternative days for the same time:' => 'الموعد المطلوب غير متاح في اليوم المحدد. الأيام البديلة لنفس الوقت:',  
    'The requested appointment is not available. Alternative time slots for the day:' => 'الموعد المطلوب غير متاح. الأوقات البديلة لهذا اليوم:',  
    'The requested appointment is available.' => 'الموعد المطلوب متاح.',  
    'Available time slots for the given date range:' => 'الأوقات المتاحة للفترة الزمنية المحددة:',  
    'Days available for the requested time:' => 'الأيام المتاحة للوقت المطلوب:',  
    'The branch field must be a valid integer.' => 'يجب أن يكون حقل الفرع عددًا صحيحًا صالحًا.',  
    'The selected branch does not exist.' => 'الفرع المحدد غير موجود.',  
    'The start time must be in the format YYYY-MM-DD.' => 'يجب أن يكون وقت البدء بالتنسيق YYYY-MM-DD.',  
    'The end time must be in the format YYYY-MM-DD.' => 'يجب أن يكون وقت الانتهاء بالتنسيق YYYY-MM-DD.',  
    'The booking start date is required.' => 'تاريخ بدء الحجز مطلوب.',  
    'The booking start date must be in the format YYYY-MM-DD.' => 'يجب أن يكون تاريخ بدء الحجز بالتنسيق YYYY-MM-DD.',  
    'The booking end date is required.' => 'تاريخ انتهاء الحجز مطلوب.',  
    'The booking end date must be in the format YYYY-MM-DD.' => 'يجب أن يكون تاريخ انتهاء الحجز بالتنسيق YYYY-MM-DD.',  
    'The booking start field is required.' => 'حقل بدء الحجز مطلوب.',  
    'The booking end field is required.' => 'حقل انتهاء الحجز مطلوب.', 
     
    'The start time field must have a value.' => 'يجب أن يحتوي حقل وقت البدء على قيمة.',  
    'The end time field must have a value.' => 'يجب أن يحتوي حقل وقت الانتهاء على قيمة.',  
    'The branch must be an integer.' => 'يجب أن يكون الفرع رقمًا صحيحًا.',  
    'The selected branch is invalid.' => 'الفرع المحدد غير صالح.',  
    'The start time does not match the format H:i:s.' => 'وقت البدء لا يتطابق مع التنسيق H:i:s.',  
    'The end time does not match the format H:i:s.' => 'وقت الانتهاء لا يتطابق مع التنسيق H:i:s..',  
    'The branch field must have a value.' => 'يجب أن يحتوي حقل الفرع على قيمة.', 

    'The zone field is required.' => 'حقل المنطقة مطلوب.',  
    'The selected zone is invalid.' => 'المنطقة المحددة غير صالحة.',  
    'The branch field is required.' => 'حقل الفرع مطلوب.',  
    'The category field is required.' => 'حقل الفئة مطلوب.',  
    'The category must be an integer.' => 'يجب أن تكون الفئة رقمًا صحيحًا.',  
    'The selected category is invalid.' => 'الفئة المحددة غير صالحة.',  

    'Notification marked as read' => 'تم وضع الإشعار كمقروء.',  
    'Notification not found' => 'لم يتم العثور على الإشعار.',  
    'All notifications marked as read' => 'تم وضع جميع الإشعارات كمقروءة.',  


    'The service date field is required.' => 'حقل تاريخ الخدمة مطلوب.',  
    'The id field is required.' => 'حقل المعرف مطلوب.',  
    'The service date must be a date after or equal to today.' => 'يجب أن يكون تاريخ الخدمة تاريخًا بعد أو يساوي اليوم.',  
    'The service date is not a valid date.' => 'تاريخ الخدمة ليس تاريخًا صالحًا.',  

    'The date field is required.' => 'حقل التاريخ مطلوب.',
    'The date must be a date after or equal to today.' => 'يجب أن يكون التاريخ بعد اليوم أو يساويه.',
    'The date is not a valid date.' => 'التاريخ غير صالح.',

    'The branch id field is required.' => 'حقل معرف الفرع مطلوب.',
    'The selected branch id is invalid.' => 'الفرع المحدد غير صالح.',

    'The service id field is required.' => 'حقل معرف الخدمة مطلوب.',
    'The selected service id is invalid.' => 'الخدمة المحددة غير صالحة.',

    'The employee id field is required.' => 'حقل معرف الموظف مطلوب.',
    'The selected employee id is invalid.' => 'الموظف المحدد غير صالح.',

    'The payment type field is required.' => 'حقل نوع الدفع مطلوب.',
    'The selected payment type is invalid.' => 'نوع الدفع المحدد غير صالح.',

    'The full name field is required.' => 'حقل الاسم الكامل مطلوب.',
    'The full name may not be greater than 255 characters.' => 'يجب ألا يتجاوز الاسم الكامل 255 حرفًا.',

    'The phone no field is required.' => 'حقل رقم الهاتف مطلوب.',
    'The phone no format is invalid.' => 'تنسيق رقم الهاتف غير صالح. يجب أن يبدأ بـ +218 أو 9 متبوعًا بـ 8 أرقام.',

    'The state field is required.' => 'حقل الحالة مطلوب.',
    'The selected state is invalid.' => 'الحالة المحددة غير صالحة.',

    'The postal code may not be greater than 10 characters.' => 'يجب ألا يتجاوز الرمز البريدي 10 أحرف.',
    'The city may not be greater than 100 characters.' => 'يجب ألا يتجاوز اسم المدينة 100 حرف.',
    'The street address may not be greater than 255 characters.' => 'يجب ألا يتجاوز عنوان الشارع 255 حرفًا.',

    'You do not have enough balance in your account' => 'ليس لديك رصيد كافٍ في حسابك.',
    'You can\'t make payment by user balance without login try another one' => 'لا يمكنك الدفع باستخدام رصيد المستخدم دون تسجيل الدخول، جرب طريقة أخرى.',
    'Failed to save or get customer' => 'فشل في حفظ أو استرجاع بيانات العميل.',
    'The selected service is booked, try another one' => 'الخدمة المحددة محجوزة، جرب خدمة أخرى.',

    'The coupon code may not be greater than 255 characters.' => 'يجب ألا يتجاوز رمز القسيمة 255 حرفًا.',
    
    'Card charged successfully' => 'تم شحن البطاقة بنجاح.',
    'Card not found or already charged' => 'لم يتم العثور على البطاقة أو تم شحنها مسبقًا.',
    'The selected code is invalid.' => 'الكود المحدد غير صالح.',
    'Unauthorized' => 'غير مصرح.',

    'The selected id is invalid.' => 'المعرف المحدد غير صالح.',
    
    'The customer id field is required.' => 'حقل معرف العميل مطلوب.',
    'The selected customer id is invalid.' => 'معرف العميل المحدد غير صالح.',
    

    'The service time field is required.' => 'حقل وقت الخدمة مطلوب.',
    'The service time format is invalid.' => 'تنسيق وقت الخدمة غير صالح. يجب أن يكون بالشكل HH:MM-HH:MM.',

    'The status field is required.' => 'حقل الحالة مطلوب.',
    'The selected status is invalid.' => 'الحالة المحددة غير صالحة.',

    'The paid amount field is required.' => 'حقل المبلغ المدفوع مطلوب.',
    'The paid amount must be at least 0.' => 'يجب ألا يقل المبلغ المدفوع عن 0.',

    'The payment type id field is required.' => 'حقل معرف نوع الدفع مطلوب.',
    'The selected payment type id is invalid.' => 'معرف نوع الدفع المحدد غير صالح.',

    'The isForceBooking field is required.' => 'حقل الحجز الإجباري مطلوب.',
    'The isForceBooking field must be true or false.' => 'يجب أن يكون الحجز الإجباري صحيحًا أو خطأ.',

    'The remarks may not be greater than 500 characters.' => 'يجب ألا تتجاوز الملاحظات 500 حرف.',
   
    'The booking id field is required.' => 'حقل معرف الحجز مطلوب.',
    'The selected booking id is invalid.' => 'معرف الحجز المحدد غير صالح.',
    'The :field amount cannot exceed the maximum allowed value: :maxAmount' => 'لا يمكن أن يتجاوز مبلغ :field الحد الأقصى المسموح به: :maxAmount.',
   
    'server_error' => 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.',

    'due_exceeded' => ' المبلغ المستحق لا يمكن أن يتجاوز الحد الأقصى المسموح به:',
    'extra_input_exceeded' => 'المبلغ الإضافي لا يمكن أن يتجاوز الحد الأقصى المسموح به:',

  ];