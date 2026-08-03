<?php

namespace App\Http\Controllers\Booking;

use App\Http\Controllers\Controller;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Booking\SchServiceBooking;
use App\Models\Booking\SchServiceBookingFeedback;
use Illuminate\Http\Request;

class SchServiceBookingFeedbackController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
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
     * @param  \App\Models\Services\SchServiceBookingInfoFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function show(SchServiceBookingFeedback $schServiceFeedback)
    {
        
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Services\SchServiceBookingInfoFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function edit(SchServiceBookingFeedback $schServiceFeedback)
    {
        if($schServiceFeedback->user_id != auth()->id())
            return abort(404);
        return view('site.client.client-feedback',['feedback' => $schServiceFeedback]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Services\SchServiceBookingInfoFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, SchServiceBookingFeedback $schServiceFeedback)
    {
        if($schServiceFeedback->user_id != auth()->id() || $schServiceFeedback->status != 0)
            return abort(404);
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'feedback' => 'required|string'
        ]);
        $schServiceFeedback->rating = $request->rating;
        $schServiceFeedback->feedback = $request->feedback;
        $schServiceFeedback->status = 1;
        $schServiceFeedback->update();
        return view('site.client.client-feedback',['feedback' => $schServiceFeedback]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Services\SchServiceBookingInfoFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function destroy(SchServiceBookingFeedback $schServiceFeedback)
    {
        //
    }
}
