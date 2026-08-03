<?php

namespace App\Http\Controllers\Services;

use App\Http\Controllers\Controller;
use App\Models\Services\SchServiceFeedback;
use Illuminate\Http\Request;

class SchServiceFeedbackController extends Controller
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
     * @param  \App\Models\Services\SchServiceFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function show(SchServiceFeedback $schServiceFeedback)
    {
        
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Services\SchServiceFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function edit(SchServiceFeedback $schServiceFeedback)
    {
        if($schServiceFeedback->user_id != auth()->id())
            return abort(404);
        return view('site.client.client-feedback',['feedback' => $schServiceFeedback]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Services\SchServiceFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, SchServiceFeedback $schServiceFeedback)
    {
        return view('site.client.client-feedback',['feedback' => $schServiceFeedback]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Services\SchServiceFeedback  $schServiceFeedback
     * @return \Illuminate\Http\Response
     */
    public function destroy(SchServiceFeedback $schServiceFeedback)
    {
        //
    }
}
