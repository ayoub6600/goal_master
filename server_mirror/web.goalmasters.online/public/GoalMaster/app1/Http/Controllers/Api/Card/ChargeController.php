<?php

namespace App\Http\Controllers\Api\Card;

use Exception;
use App\Models\User;
use App\Events\CardCharged;
use Illuminate\Http\Request;
use App\Models\CardSystem\Card;
use App\Http\Requests\CardRequest;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Notification;
use App\Notifications\CardChargedNotification;

class ChargeController extends Controller
{
    
    /**
     * Charge a card for the authenticated user.
     *
     * @param CardRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function chargeCard(CardRequest $request)
    {
        // Get the authenticated user
        $user = Auth::guard('api')->user();
        $validated = $request->validated();
        
        // Find the card by its code and ensure it hasn't been charged
        $card = Card::where('code', $validated['code'])->where('is_charged', false)->first();
        
        if (!$card) {
            return response()->json([
                'status' => 'false',
                'message' => __('messages.Card not found or already charged')
            ], 500);
        }
        
        DB::beginTransaction();
        try {
            $amount = $card->group->price;
            $userId = $user->id;
            
            // Update user balance
            $user->userBalance()->create([
                'amount' => $amount,
                'user_id' => $userId,
                'balance_type' => 1,
                'status' => 1
            ]);

            // Mark the card as charged
            // $card->is_charged = true;
            // $card->save();
            
            
            // Mark the card as charged
            $card->update(['is_charged' => true]);
            
            // Notify system admins
            $systemAdmins = User::where('is_sys_adm', 1)->get();

            Notification::send($systemAdmins, new CardChargedNotification($card, $user));
            // $systemAdmins->notify(new CardChargedNotification($card, $user));
            // Fire event
            event(new CardCharged($systemAdmins, $card, $user));
            
            DB::commit();
            
            return response()->json([
                'status' => 'true',
                'message' => __('messages.Card charged successfully'),
                'balance' => [
                    'add_amount' => $amount,
                    'total' => $user->userBalance->sum('amount'),
                ],
            ], 200);
        } catch (Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'false',
                'message' => __('messages.Card not found or already charged'),
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
