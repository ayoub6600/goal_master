<?php

namespace App\Http\Controllers\Slider;

use App\Enums\UserType;
use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Customer\CmnCustomer;
use App\Models\Slide;
use Exception;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Booking\SchServiceBooking;
use App\Models\Customer\CmnUserBalance;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Support\Facades\DB;

class SliderController extends Controller
{

    public function index()
    {
        $slides = Slide::all();
        return view('slider.index' , compact('slides'));
    }

    public function show($id)
    {
        $slide = Slide::findOrFail($id);
        return response()->json($slide);
    }


    public function create()
    {
        return view('slider.form')->with('slide', null);
    }


    public function edit($id)
    {
        $slide = Slide::findOrFail($id);
        return view('slider.form', compact('slide'));
    }

    public function store(Request $request)
    {


        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'url' => 'nullable|url|max:255',
            'status' => 'required|in:active,inactive',
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048', // 2MB
        ]);

        $slide = new Slide($validatedData);
        $slide->save();

        if ($request->hasFile('image')) {
            $slide->addMediaFromRequest('image')->toMediaCollection('slider_images');
        }

        return redirect()->route('slider.index')->with('success', 'تم إضافة الشريحة بنجاح');
    }

    public function update(Request $request, $id)
    {
        $slide = Slide::findOrFail($id);

        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'url' => 'nullable|url|max:255',
            'status' => 'required|in:active,inactive',
            'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $slide->update($validatedData);

        if ($request->hasFile('image')) {
            $slide->clearMediaCollection('slider_images');
            $slide->addMediaFromRequest('image')->toMediaCollection('slider_images');
        }

        return redirect()->route('slider.index')->with('success', 'تم تحديث الشريحة بنجاح');
    }


    //destroy
    public function destroy($id)
    {
        $slide = Slide::findOrFail($id);
        $slide->clearMediaCollection('slider_images');
        $slide->delete();

        return redirect()->route('slider.index')->with('success', 'تم حذف الشريحة بنجاح');
    }

}
