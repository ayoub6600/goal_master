<?php

namespace App\Http\Controllers\Api\Dashboard;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function userBookingsAnalysis()
    {
        try {
            $user = Auth::guard('api')->user();
            $customer = $user->customer;
            if (!$customer) {
                return response()->json(['status' => false,'message' => 'Customer not found']);
            }
    
            $statusAnalysis = $customer->bookings
            ->groupBy('status')  
            ->map(function ($bookings, $status) {
                return $bookings->count(); 
            });

        $statusAnalysis = [
            'Pending' => $statusAnalysis->get(0, 0),       // 0 -> Pending
            'Processing' => $statusAnalysis->get(1, 0),    // 1 -> Processing
            'Approved' => $statusAnalysis->get(2, 0),      // 2 -> Approved
            'Cancel' => $statusAnalysis->get(3, 0),        // 3 -> Cancel
            'Done' => $statusAnalysis->get(4, 0)           // 4 -> Done
        ];

        return response()->json(['status' => true,'data' => $statusAnalysis]);
           
        } catch (\Exception $e) {
            return response()->json(['status' => false,'message' => $e->getMessage()]);
        }
    }
    


    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
