<?php

namespace App\Http\Controllers\Wallet;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Http\Requests\WalletRequest;
use Illuminate\Support\Facades\Auth;
use App\Models\Customer\CmnUserBalance;
use App\Http\Requests\Requesttransaction;

class UserWalletController extends Controller
{


  public function sendMoney(WalletRequest $request)
{
    $validated = $request->validated();
    $sender = Auth::guard('api')->user();

    // البحث عن المستلم
    $receiver = User::where('phone_number', $validated['receiver_phone_number'])->first();

    if (!$receiver) {
        return response()->json([
            'status'  => false,
            'message' => 'المستلم غير موجود',
        ], 404);
    }

    // منع إرسال الفلوس لنفسك
    if ($receiver->id === $sender->id) {
        return response()->json([
            'status'  => false,
            'message' => 'لا يمكنك إرسال نقود لنفسك',
        ], 422);
    }

    try {
        DB::transaction(function () use ($validated, $sender, $receiver) {

            // حساب الرصيد الكلي المتاح
            $totalCredit = $sender->balancesApi()
                ->where('balance_type', 1) // إضافة
                ->lockForUpdate()
                ->sum('amount');

            $totalDebit = $sender->balancesApi()
                ->where('balance_type', 0) // خصم
                ->lockForUpdate()
                ->sum('amount');

            $availableBalance = bcsub($totalCredit, $totalDebit, 2);


            // التحقق من الرصيد
            if (bccomp($availableBalance, $validated['amount'], 2) === -1) {
                throw new \Exception('رصيدك غير كافي لاتمام العملية');
            }

            // خصم من المرسل
            $sender->balancesApi()->create([
                'balance_type'      => 0, // خصم
                'user_id'           => $sender->id,
                'amount'            => $validated['amount'],
                'reference_user_id' => $receiver->id, // الشخص اللي راح له الفلوس
                'type' => "transfer",

            ]);

            // إضافة للمستقبل
            $receiver->balancesApi()->create([
                'balance_type'      => 1, // إضافة
                'user_id'           => $receiver->id,
                'amount'            => $validated['amount'],
                'reference_user_id' => $sender->id, // الشخص اللي جاي منه الفلوس
                'type' => "transfer",

            ]);
        });

        return response()->json([
            'status'  => true,
            'message' => 'تم تحويل النقود بنجاح',
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'status'  => false,
            'message' => $e->getMessage(),
        ], 400);
    }
}



    public function transaction()
    {
        try {
            $transactions = CmnUserBalance::where('balanceable_type', User::class)
                ->with('user','referenceUser')
                ->where('balanceable_id', auth()->id())
                ->where('status', 1) // ✅ العمليات الناجحة فقط
                ->orderBy('created_at', 'desc')
                ->paginate(10);

            // ✅ حساب الإضافات والخصومات
            $totalAdded = $transactions->where('balance_type', 1)->sum('amount');
            $totalDeducted = $transactions->where('balance_type', 0)->sum('amount');

            $countAdded = $transactions->where('balance_type', 1)->count();
            $countDeducted = $transactions->where('balance_type', 0)->count();

            $currentBalance = $totalAdded - $totalDeducted;

            return response()->json([
                'status' => true,
                'message' => 'Transactions retrieved successfully',
                'data' => $transactions, // نفس اللي عندك
                'summary' => [
                    'added_count' => $countAdded,
                    'deducted_count' => $countDeducted,
                    'total_added' => $totalAdded,
                    'total_deducted' => $totalDeducted,
                    'current_balance' => $currentBalance
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'An error occurred while processing the transaction',
                'error' => $e->getMessage()
            ], 500);
        }
    }
  
  
      public function store(Requesttransaction $request)
    {
          try{
            $data = $request->validated();
            $user = Auth::guard('api')->user();
            // ?todo add user balance
            $user->userBalance()->create([
                'amount' => $data['amount'],
                'user_id' => $user->id,
                'balance_type' => 1,
                'status' => 1,
                'type' => 'credit',

            ]);
            return response()->json([
                            'status' => 'true',
                            'message' => __('messages.Card charged successfully'),
                            'balance' => [
                                'add_amount' => $data['amount'],
                                'balance' => $user->getBalanceWithLock(),
                            ],
                        ], 200);
            // return response()->json(['status'=>'true' , 'msg'=>'تم الشحن بنجاح' , 'balance'=>$balance]);

          }catch(\Exception $ex){
                return response()->json(['status' => "false" , 'msg'=>$ex->getMessage()]);
          }

    }



}