<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تصدير التقرير</title>
</head>
<body>
    <div class="header">
        <p class="text-right">وقت التقرير: {{ now()->format('Y-m-d H:i:s') }}</p>
    </div>
    <table>
        <thead>
            <tr>
                <th class="narrow-column">#</th>
                <th class="wide-column">اسم العميل</th>
                <th class="wide-column">رقم الهاتف</th>
                <th class="wide-column">اسم الموظف</th>
                <th class="wide-column">الفرع</th>
                <th class="wide-column">الخدمة</th>
                <th class="wide-column">التاريخ</th>
                <th class="wide-column">الوقت</th>
                <th class="wide-column">المبلغ المستحق</th>
                @if ($online == true)
                <th class="wide-column">تكلفه الخدمة</th>
                <th class="wide-column">المبلغ المدفوع</th>
                @endif
                <th class="wide-column">طريقة الدفع</th>
                <th class="wide-column">المسامح كريم</th>
                <th class="wide-column">الملاحظات</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($services as $index => $service)
            
                @php
                    // تحديد طريقة الدفع بناءً على الـ status و cmn_payment_type_id
                    if ($service['cmn_payment_type_id'] == 1) {
                        $paymentMethod = ($service['status'] == 2 || $service['status'] == 4) ? 1 : 3;
                    } else {
                        $paymentMethod = 2;
                    }

                    // خريطة طرق الدفع
                    $paymentTypeMapping = [
                        1 => 'نقدا',       
                        2 => 'عن طريق الانترنت',
                        3 => 'غير مدفوع',       
                    ];
                @endphp

                <tr>
                    <td>{{ $index + 1 . " id : " . $service['id'] }}</td>
                    <td>{{ $service['customer'] }}</td>
                    <td>{{ $service['customer_phone_no'] }}</td>
                    <td>{{ $service['employee'] }}</td>
                    <td>{{ $service['branch'] }}</td>
                    <td>{{ $service['service'] }}</td>
                    <td>{{ $service['date'] }}</td>
                    <td>{{ $service['start_time'] }} - {{ $service['end_time'] }}</td>
                    @if ($online == true )
                        @if($service['online_done'] > 0)
                            <td>{{ abs($service['total_amount'] - $service['due']) }}</td>
                            <td>{{ $service['total_amount'] }}</td>
                            <td> خالص </td>
                        @else
                            <td>{{ $service['due'] }}</td>
                            <td>{{ $service['total_amount'] }}</td>
                            <td>غير خالص</td>
                        @endif
                        @else
                        <td>{{ $service['due'] }}</td>

                    @endif
                    <td>{{ $paymentTypeMapping[$paymentMethod] }}</td>
                    <td>{{ $service['forgiveness_amount'] }}</td>
                    <td>{{ $service['remarks'] }}</td>
                </tr>
            @endforeach
            <tr class="total-row">
                <td colspan="8">الإجمالي</td>
                @if ($online == true )
                <td>{{ $services->where('online_done', '<=', 0)->sum('due') }}</td>
                @else
                    <td colspan="2">{{ $services->sum('due')}}</td>
                @endif

            </tr>

            <tr class="total-row">
                <td colspan="8">اجمالي المسامحه</td>
                    <td colspan="2">{{$services->sum('forgiveness_amount')}}</td>
           </tr>

            <tr class="total-row">
                <td colspan="8">اجمالي الربح</td>
                <td colspan="2">{{ abs($services->sum('due') - $services->sum('forgiveness_amount')) }}</td>
            </tr>


        </tbody>
    </table>
</body>
</html>
