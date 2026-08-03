<?php

namespace App\Http\Controllers;

use App\Events\BookingCreated;
use App\Events\CardCharged;
use App\Events\MyEvent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf as FacadePdf;
use App\Models\CardSystem\CardGroup;
use App\Models\CardSystem\Card;
use App\Notifications\CardChargedNotification;
use Illuminate\Support\Facades\Notification;

class cardController extends Controller
{
    //
    public function card()
    {
        return view('cards.generate_cards');
        return response()->json([
            'message' => 'it is in card.'
        ], 200);
    }

    public function createCard(Request $request)
    {
        // Validate the request data
        $validatedData = $request->validate([
            'codeLength' => [
                'required',
                'numeric',
                'min:8',
                'max:20',
            ],
            'price' => [
                'required',
                'numeric',
                'min:1'
            ],
            'formula' => 'required|in:letters_numbers,numbers,letters',
            'card_count' => [
                'required',
                'numeric',
                'min:1'
            ],
        ], [
            // Custom error messages
            'codeLength.required' => 'The code length field is mandatory.',
            'codeLength.numeric'  => 'The code length must be a numeric value.',
            'codeLength.min'      => 'The code length must be at least 8 characters.',
            'codeLength.max'      => 'The code length cannot be greater than 20 characters.',

            'price.required'      => 'The price field is required.',
            'price.numeric'       => 'The price must be a valid number.',
            'price.min'           => 'The price must be at least 1.',

            'formula.required'    => 'Please select a valid formula option.',
            'formula.in'          => 'The selected formula is invalid. Choose from letters_numbers, numbers, or letters.',

            'card_count.required' => 'The card number field is required.',
            'card_count.numeric'  => 'The card number must be a numeric value.',
            'card_count.min'      => 'The card number must be at least 1.',
        ]);

        // Define character set based on the formula
        $characters = '';
        if ($request->formula == 'letters_numbers') {
            $characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
            $formula = 'both';
        } elseif ($request->formula == 'letters') {
            $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
            $formula = 'letters';
        } elseif ($request->formula == 'numbers') {
            $characters = '0123456789';
            $formula = 'numbers';
        }

        // Create a new CardGroup record
        $cardGroup = CardGroup::create([
            'price' => $request->price,
            'formula' => $formula,
            'count' => $request->card_count
        ]);

        $charactersNumber = strlen($characters);
        $codeLength = $request->codeLength;

        // Generate and save each card
        for ($i = 0; $i < $request->card_count; $i++) {
            $code = '';

            // Generate a unique code of the required length
            while ($codeLength > strlen($code)) {
                $position = rand(0, $charactersNumber - 1);
                $code .= $characters[$position];
            }

            // Create each card and link it to the CardGroup
            Card::create([
                'group_id' => $cardGroup->id,
                'code' => $code,
                'is_charged' => false,
            ]);
        }

        // Flash success message to the session
        session()->flash('success', 'Cards created successfully!');

        // Redirect back or to another route
        return redirect()->back();
    }

    public function chargeCard(Request $request)
    {
        // Get the authenticated user
        $user = Auth::user();
        // Find the card by its code and ensure it hasn't been charged
        $card = Card::where('code', $request->code)->where('is_charged', false)->first();
        if ($card) {
            $amount = $card->group->price;            
            $userId = $user->id;
            $user = User::where('id', $userId)->first();
            $user->userBalance()->create([
                'amount' => $amount,
                'user_id' => $userId,
                'balance_type' => 1,
                'status' => 1
            ]);

            // Mark the card as charged
            $card->is_charged = true;
            $card->save();

            $systemUsers = User::where('is_sys_adm', '1')->get();
            Notification::send($systemUsers, new CardChargedNotification($card, $user));
            event(new CardCharged($systemUsers,$card,$user));
            
            // Redirect back with success message
            return redirect()->back()->with('success', 'تم شحن البطاقة بنجاح.');
        } else {
            // If the card doesn't exist or is already charged
            return redirect()->back()->with('error', 'لم يتم العثور على البطاقة أو تم شحنها بالفعل.');
        }
    }


    public function getcards(Request $request)
    {
        // Start with a base query
        $query = CardGroup::query();

        // Apply filters if they exist
        if ($request->filled('group_id')) {
            $query->where('id', $request->group_id);
        }

        if ($request->filled('count_from') && $request->filled('count_to')) {
            $query->whereBetween('count', [$request->count_from, $request->count_to]);
        } elseif ($request->filled('count_from')) {
            $query->where('count', '>=', $request->count_from);
        } elseif ($request->filled('count_to')) {
            $query->where('count', '<=', $request->count_to);
        }

        if ($request->filled('formula')) {
            $query->where('formula', $request->formula);
        }

        // Price range filter
        if ($request->filled('price_from') && $request->filled('price_to')) {
            $query->whereBetween('price', [$request->price_from, $request->price_to]);
        } elseif ($request->filled('price_from')) {
            $query->where('price', '>=', $request->price_from);
        } elseif ($request->filled('price_to')) {
            $query->where('price', '<=', $request->price_to);
        }

        // Date range filter
        if ($request->filled('date_from') && $request->filled('date_to')) {
            $query->whereBetween('created_at', [$request->date_from, $request->date_to]);
        } elseif ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        } elseif ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        // Fetch the filtered cards
        $groups = $query->get();

        // Return the view with the filtered data
        return view('cards.allCards', ['groups' => $groups]);
    }

    public function exportPdf($group_id)
    {
        // Get cards with the specified group_id
        $cards = Card::where('group_id', $group_id)->get();

        // Load the view with the filtered data
        $pdf = FacadePdf::loadView('cards.pdf', compact('cards'));

        return $pdf->download('filtered_cards_list.pdf'); // Download the generated PDF
    }
}
