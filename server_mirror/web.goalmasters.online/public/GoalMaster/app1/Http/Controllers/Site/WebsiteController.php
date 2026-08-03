<?php

namespace App\Http\Controllers\Site;

use Exception;
use Illuminate\Http\Request;
use App\Enums\ServiceVisibility;
use App\Models\Website\SiteMenu;
use App\Enums\AppointmentLimitType;
use App\Models\Website\SiteAboutUs;
use App\Http\Controllers\Controller;
use App\Models\Employee\SchEmployee;
use App\Models\Services\SchServices;
use App\Models\Website\SiteGoogleMap;
use App\Models\Website\SiteAppearance;
use App\Models\Website\SitePhotoGallery;
use App\Models\Booking\SchServiceBooking;
use Stevebauman\Location\Facades\Location;
use App\Http\Repository\DateTimeRepository;
use App\Http\Repository\Payment\PaymentRepository;
use App\Models\Website\SiteClientTestimonial;
use App\Models\Website\SiteTermsAndCondition;
use App\Models\Website\SiteFrequentlyAskedQuestion;
use App\Http\Repository\Settings\SettingsRepository;
use App\Http\Repository\Site\SiteRepository;

class WebsiteController extends Controller
{

    public function choosePaymentMethod()
    {
        $pay = new PaymentRepository();
        return view('site.choose-payment-method', ['paymentMethod' => $pay->getPaymentMethod()]);
    }

    public function siteServices()
    {
        return view('site.services', [
            'services' => $this->getSiteService()
        ]);
    }
    public function teamDetails(Request $request)
    {
        $siteRepo = new SiteRepository();
        return view('site.single-team-details', ['teamDetails' => $siteRepo->getEmployeeWiseServiceDetails($request->id)]);
    }

    public function siteTeams()
    {
        return view('site.team', ['teams' => $this->getSiteTeam()]);
    }
    public function sitePhotoGallery()
    {
        return view('site.photo-gallery', ['photoGallery' => $this->getSitePhotoGallery()]);
    }
    public function siteAboutUs()
    {
        $siteRepo = new SiteRepository();
        $websiteCont = new WebsiteController();
        return view('site.about-us', [
            'aboutUs' => $this->getSiteAboutUs(),
            'expertiseEmployee' => $siteRepo->getExpertiseEmployee(),
            'clientTestimonial' => $websiteCont->getClientTestimonial()
        ]);
    }
    public function siteFaq()
    {
        return view('site.faq', ['faq' => $this->getSiteFaq()]);
    }

    public function siteContact()
    {
        return view('site.contact', ['gMapConfig' => $this->getGoogleMapConfig()]);
    }

    public function siteTermsAndCondition()
    {
        return view('site.terms-and-condition', ['termsAndCondition' => $this->getTermsAndCondition()]);
    }

    public function getTermsAndCondition()
    {
        $data = SiteTermsAndCondition::where('status', 1)->select('details')->first();
        return $data;
    }

    public function serviceDetails(Request $request)
    {
        $siteRepo = new SiteRepository();
        $websiteCont = new WebsiteController();
        return view(
            'site.single-service-details',
            [
                'serviceDetails' => $siteRepo->getSiteServiceByServiceId($request->id),
                'topService' => $websiteCont->getTopServices(),
            ]
        );
    }


    public function getMenu()
    {
        $data = SiteMenu::where('status', 1)->select('id', 'name', 'site_menu_id', 'route', 'order')->orderBy('order')->get();
        return $data;
    }
    public function getAppearance()
    {
        $data = SiteAppearance::select(
            'app_name',
            'logo',
            'icon',
            'motto',
            'theam_color',
            'theam_menu_color2',
            'theam_hover_color',
            'theam_active_color',
            'facebook_link',
            'youtube_link',
            'twitter_link',
            'instagram_link',
            'about_service',
            'contact_email',
            'contact_phone',
            'contact_web',
            'address',
            'background_image',
            'login_background_image',
            'meta_title',
            'meta_description',
            'meta_keywords'
        )->first();
        if ($data != null) {
            $data['menu_color'] = $data['theam_color'];
            $data['menu_color2'] = $data['theam_menu_color2'];
        }
        return $data;
    }

    public function getTopServices()
    {
        $data =  SchServiceBooking::join('sch_services', 'sch_service_bookings.sch_service_id', '=', 'sch_services.id')
            ->selectRaw('sch_service_id,
            sch_services.title,
            sch_services.remarks,
            sch_services.image,
            count(sch_service_bookings.sch_service_id) as service_count,
            (select (sum(sf.rating)/count(sf.id)) as avgRating 
            from sch_service_booking_feedback as sf join sch_service_bookings sb 
            on sf.sch_service_booking_id=sb.id 
            where sb.sch_service_id=sch_service_bookings.sch_service_id and sf.status=1) as avgRating,
            (select count(sf.id) as countRating 
            from sch_service_booking_feedback as sf join sch_service_bookings sb 
            on sf.sch_service_booking_id=sb.id 
            where sb.sch_service_id=sch_service_bookings.sch_service_id and sf.status=1) as countRating')
            ->groupBy('sch_service_id', 'sch_services.title', 'sch_services.remarks', 'sch_services.image')
            ->orderByRaw('service_count desc')->take(10)->get();
        return $data;
    }
    public function getClientTestimonial()
    {
        $data =  SiteClientTestimonial::where('status', 1)->select('name', 'image', 'rating', 'description')->get();
        return $data;
    }

    public function getNewJoiningEmployee()
    {
        $data = SchEmployee::leftJoin('hrm_departments', 'sch_employees.hrm_department_id', '=', 'hrm_departments.id')
            ->select('sch_employees.full_name', 'sch_employees.image_url', 'hrm_departments.name as department', 'sch_employees.specialist')
            ->orderBy('sch_employees.created_at')->limit(10)->get();
        return $data;
    }

    public function getSiteService()
    {
        $stRepo = new SettingsRepository();
        $data =  SchServices::selectRaw(
            'title,
            image,
            price, 
            remarks,
            time_slot_in_time,
            appoinntment_limit,
            appoinntment_limit_type,
            visibility,
            (select (sum(sf.rating)/count(sf.id)) as avgRating 
            from sch_service_booking_feedback as sf join sch_service_bookings sb 
            on sf.sch_service_booking_id=sb.id 
            where sb.sch_service_id=sch_services.id and sf.status=1) as avgRating,
            (select count(sf.id) as countRating 
            from sch_service_booking_feedback as sf join sch_service_bookings sb 
            on sf.sch_service_booking_id=sb.id 
            where sb.sch_service_id=sch_services.id and sf.status=1) as countRating'
        )->get();
        $currency = $stRepo->cmnCurrency();
        foreach ($data as $val) {
            $val['time_slot_in_time'] = DateTimeRepository::TotalMinuteFromTime($val->time_slot_in_time);
            if ((int)$val->appoinntment_limit_type == AppointmentLimitType::Unlimited) {
                $val['appoinntment_limit'] = AppointmentLimitType::fromValue((int)$val->appoinntment_limit_type)->description;
            }
            $val['appoinntment_limit_type'] = AppointmentLimitType::fromValue((int)$val->appoinntment_limit_type)->description;
            if ($val->visibility == ServiceVisibility::PrivateService) {
                $val["visibility"] = "Call for service booking";
            } else {
                $val["visibility"] = "Online booking available";
            }
            $val['price'] = $currency . $val->price;
        }
        return $data;
    }


    public function getSiteTeam()
    {
        $employee = SchEmployee::where('status', 1)->select('id', 'full_name', 'image_url', 'specialist')->get();
        return $employee;
    }

    public function getSitePhotoGallery()
    {
        $data = SitePhotoGallery::where('status', 1)->select('image_url', 'name', 'description')->orderBy('order')->get();
        return $data;
    }
    public function getSiteAboutUs()
    {
        $data = SiteAboutUs::where('status', 1)->select('image_url', 'title', 'details')->orderBy('order')->get();
        return $data;
    }

    public function getSiteFaq()
    {
        $data = SiteFrequentlyAskedQuestion::where('status', 1)->select('question', 'answer')->orderBy('order')->get();
        return $data;
    }

    public function getGoogleMapConfig()
    {
        $data = SiteGoogleMap::select('lat', 'long', 'map_key')->first();
        return $data;
    }

    public function getCountryCode(Request $request)
    {
        try {
            if ($request->getClientIp() != "::1") {
                $position = Location::get($request->getClientIp());
                return $this->apiResponse(['status' => '1', 'data' => $position->countryCode], 200);
            }
            return $this->apiResponse(['status' => '1', 'data' => "US"], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }


}
