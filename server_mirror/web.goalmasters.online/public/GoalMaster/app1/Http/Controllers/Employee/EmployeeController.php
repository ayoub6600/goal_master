<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Employee\SchEmployee;
use App\Models\Employee\SchEmployeeOffday;
use App\Models\Employee\SchEmployeeSchedule;
use App\Models\Employee\SchEmployeeService;
use App\Models\Employee\SchSalary;
use App\Models\Services\SchServiceCategory;
use App\Models\Services\SchServices;
use App\Models\Settings\CmnBusinessHoliday;
use App\Models\Settings\CmnBusinessHour;
use App\Models\Settings\CmnCompany;
use App\Models\User;
use App\Models\UserManagement\SecUserBranch;
use App\Models\Settings\CmnBranch;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EmployeeController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function employee()
    {
        return view('employee.employee');
    }


    public function createEmployee(Request $data)
    {
        DB::beginTransaction();
        try {
            $validator = Validator::make($data->toArray(), [
                'full_name' => ['required', 'string', 'max:200'],
                'email_address' => ['required', 'string', 'max:200', 'unique:sch_employees'],
                'gender' => 'nullable|string',  // إضافة هذا السطر لجعل الحقل gender اختياري
            ]);

            if (!$validator->fails()) {

                $creatorId =  auth()->id();
                $employeeImage = $data->image_url;
                if ($employeeImage != null) {
                    $employeeImage = UtilityRepository::saveFile($employeeImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                }

                $idCardImage = $data->id_card;
                if ($idCardImage != null) {
                    $idCardImage = UtilityRepository::saveFile($idCardImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                }
                $passportImage = $data->passport;
                if ($passportImage != null) {
                    $passportImage = UtilityRepository::saveFile($passportImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                }
                $employee = SchEmployee::create([
                    "full_name" => $data->full_name,
                    "employee_id" => $data->employee_id,
                    "email_address" => $data->email_address,
                    "country_code" => $data->country_code,
                    "contact_no" => $data->contact_no,
                    "cmn_branch_id" => $data->cmn_branch_id,
                    "hrm_department_id" => UtilityRepository::emptyToNull($data->hrm_department_id),
                    "hrm_designation_id" => UtilityRepository::emptyToNull($data->hrm_designation_id),
                    "user_id" => null,
                    "gender" => $data->gender,
                    "dob" => UtilityRepository::emptyToNull($data->dob),
                    "specialist" => $data->specialist,
                    "present_address" => $data->present_address,
                    "permanent_address" => $data->permanent_address,
                    "note" => $data->note,
                    "salary" => $data->salary,
                    "commission" => $data->commission ?? 0,
                    "pay_commission_based_on" => $data->pay_commission_based_on,
                    "target_service_amount" => $data->target_service_amount ?? 0,
                    "image_url" => $employeeImage,
                    "id_card" => $idCardImage,
                    "passport" => $passportImage,
                    "status" => $data->status,
                    "created_by" => $creatorId
                ]);
                $employeeId = $employee->id;

                foreach ($data->service as $item) {
                    if (Arr::exists($item, 'sch_service_id') && $item['emp_service_id'] > 0) {
                        SchEmployeeService::where('id', $item['emp_service_id'])->update([
                            'fees' => $item['fees'],
                            'status' => 1,
                            "updated_by" => $creatorId
                        ]);
                    } else if (Arr::exists($item, 'sch_service_id') == false && $item['emp_service_id'] > 0) {
                        SchEmployeeService::where('id', $item['emp_service_id'])->update([
                            'fees' => $item['fees'],
                            'status' => 0,
                            "updated_by" => $creatorId
                        ]);
                    } else if (Arr::exists($item, 'sch_service_id') && $item['emp_service_id'] < 1) {
                        SchEmployeeService::create([
                            'sch_employee_id' => $employeeId,
                            'sch_service_id' => $item['sch_service_id'],
                            'fees' => $item['fees'],
                            'status' => 1,
                            "created_by" => $creatorId
                        ]);
                    }
                }

                foreach ($data->business as $item) {
                    SchEmployeeSchedule::create([
                        "sch_employee_id" => $employeeId,
                        "day" => $item['day'],
                        "start_time" => $item['start_time'],
                        "end_time" => $item['end_time'],
                        // "break_start_time" => $item['break_start_time'],
                        // "break_end_time" => $item['break_end_time'],
                        "is_off_day" => Arr::exists($item, 'is_off_day') ? $item['is_off_day'] : 0,
                        "created_by" => $creatorId,
                    ]);
                }
                DB::commit();
                return $this->apiResponse(['status' => '1', 'data' => ['employee_id' => $employeeId]], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function updateEmployee(Request $data)
    {
        DB::beginTransaction();
        try {
            $validator = Validator::make($data->toArray(), [
                'full_name' => ['required', 'string', 'max:200'],
                'email_address' => ['required', 'string', 'max:200', 'unique:sch_employees,email_address,' . $data->id . ',id'],

            ]);

            if (!$validator->fails()) {

                $creatorId =  auth()->id();
                $employeeImage = $data->image_url;
                if ($employeeImage != null) {
                    $employeeImage = UtilityRepository::saveFile($employeeImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                }

                $idCardImage = $data->id_card;
                if ($idCardImage != null) {
                    $idCardImage = UtilityRepository::saveFile($idCardImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                }
                $passportImage = $data->passport;
                if ($passportImage != null) {
                    $passportImage = UtilityRepository::saveFile($passportImage, ['image/png', 'image/png', 'image/jpg', 'image/jpeg']);
                }

                $readyForUpdate = [
                    "full_name" => $data->full_name,
                    "employee_id" => $data->employee_id,
                    "email_address" => $data->email_address,
                    "country_code" => $data->country_code,
                    "contact_no" => $data->contact_no,
                    "cmn_branch_id" => $data->cmn_branch_id,
                    "hrm_department_id" => UtilityRepository::emptyToNull($data->hrm_department_id),
                    "hrm_designation_id" => UtilityRepository::emptyToNull($data->hrm_designation_id),
                    "user_id" => null,
                    "gender" => $data->gender,
                    "dob" => UtilityRepository::emptyToNull($data->dob),
                    "specialist" => $data->specialist,
                    "present_address" => $data->present_address,
                    "permanent_address" => $data->permanent_address,
                    "note" => $data->note,
                    "status" => $data->status,
                    "updated_by" => $creatorId,
                    "salary" => $data->salary,
                    "commission" => $data->commission ?? 0,
                    "pay_commission_based_on" => $data->pay_commission_based_on,
                    "target_service_amount" => $data->target_service_amount ?? 0,
                ];
                if ($employeeImage != null)
                    $readyForUpdate["image_url"] = $employeeImage;

                if ($idCardImage != null)
                    $readyForUpdate["id_card"] = $idCardImage;

                if ($passportImage != null)
                    $readyForUpdate["passport"] = $passportImage;

                SchEmployee::where('id', $data['id'])->update($readyForUpdate);

                foreach ($data->service as $item) {
                    if (Arr::exists($item, 'sch_service_id') && $item['emp_service_id'] > 0) {
                        SchEmployeeService::where('id', $item['emp_service_id'])->update([
                            'fees' => $item['fees'],
                            'status' => 1,
                            "updated_by" => $creatorId
                        ]);
                    } else if (Arr::exists($item, 'sch_service_id') == false && $item['emp_service_id'] > 0) {
                        SchEmployeeService::where('id', $item['emp_service_id'])->update([
                            'fees' => $item['fees'],
                            'status' => 0,
                            "updated_by" => $creatorId
                        ]);
                    } else if (Arr::exists($item, 'sch_service_id') && $item['emp_service_id'] < 1) {
                        SchEmployeeService::create([
                            'sch_employee_id' => $data['id'],
                            'sch_service_id' => $item['sch_service_id'],
                            'fees' => $item['fees'],
                            'status' => 1,
                            "created_by" => $creatorId
                        ]);
                    }
                }

                foreach ($data->business as $item) {
                    $employeeSchedule = SchEmployeeSchedule::where('sch_employee_id', $data['id'])->where("day", $item['day'])->first();
                    if ($employeeSchedule != null) {
                        //update
                        $employeeSchedule->update([
                            "start_time" => $item['start_time'],
                            "end_time" => $item['end_time'],
                            // "break_start_time" => $item['break_start_time'],
                            // "break_end_time" => $item['break_end_time'],
                            "is_off_day" => Arr::exists($item, 'is_off_day') ? $item['is_off_day'] : 0,
                            "updated_by" => $creatorId,
                        ]);
                    } else {
                        //insert
                        SchEmployeeSchedule::create([
                            "sch_employee_id" => $data['id'],
                            "day" => $item['day'],
                            "start_time" => $item['start_time'],
                            "end_time" => $item['end_time'],
                            // "break_start_time" => $item['break_start_time'],
                            // "break_end_time" => $item['break_end_time'],
                            "is_off_day" => Arr::exists($item, 'is_off_day') ? $item['is_off_day'] : 0,
                            "created_by" => $creatorId
                        ]);
                    }
                }
                DB::commit();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $ex) {
            DB::rollBack();
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    public function saveOrUpdateEmployeeOffDay(Request $data)
    {
        try {
            $insertedId = $data->id;
            if ($insertedId == "wh")
                return $this->apiResponse(['status' => '505', 'data' => 'You are not allow to update.'], 400);

            $validator = Validator::make($data->toArray(), [
                'title' => ['required', 'string', 'max:200'],
                'start_date' => ['required', 'date'],
                'end_date' => ['required', 'date'],
            ]);

            if (!$validator->fails()) {
                if ($data->id == null || $data->id == "") {
                    $data['created_by'] = auth()->id();
                    $data['id'] = null;
                    $resp = SchEmployeeOffday::create($data->all());
                    $insertedId = $resp->id;
                } else {
                    $data['updated_by'] = auth()->id();
                    SchEmployeeOffday::where('id', $data->id)->update($data->all());
                }

                $rtr = SchEmployeeOffday::where('id', $insertedId)->select('id', 'title', 'start_date', 'end_date')->first();
                return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            if ($ex->errorInfo[2] == "Column 'sch_employee_id' cannot be null")
                return $this->apiResponse(['status' => '505', 'data' => 'Need to save employee first.'], 400);
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    public function updateOffdayByMove(Request $data)
    {
        try {
            $insertedId = $data->id;
            if ($insertedId == "wh")
                return $this->apiResponse(['status' => '505', 'data' => 'You are not allow to update.'], 400);

            $validator = Validator::make($data->toArray(), [
                'title' => ['required', 'string', 'max:200'],
                'start_date' => ['required', 'date'],
                'end_date' => ['required', 'date'],
            ]);

            if (!$validator->fails()) {
                $offday = SchEmployeeOffday::where('id', $data->id)->first();
                $offday->start_date = $data->start_date;
                $offday->end_date = $data->end_date;
                $offday->updated_by = auth()->id();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function getEmployeeCalendar(Request $data)
    {
        try {

            $start_date = $data->year . '-01-01';
            $end_date = $data->year . '-12-31';

            //employee offday
            $employeeOffDay = SchEmployeeOffday::where('sch_employee_id', $data->sch_employee_id)
                ->where('start_date', '<=', $end_date)->where('end_date', '>=', $start_date)
                ->selectRaw(
                    "id,
                    start_date as start,
                    end_date as end,
                    title"
                )->get();

            $businessHoliday = CmnBusinessHoliday::where('cmn_branch_id', $data->cmn_branch_id)
                ->where('start_date', '<=', $end_date)->where('end_date', '>=', $start_date)
                ->selectRaw(
                    "id,
                    start_date as start,
                    end_date as end,
                    title"
                )->get();

            $businessHours = CmnBusinessHour::where('is_off_day', 1)->where('cmn_branch_id', $data->cmn_branch_id)->select('day')->get();
            $weeklyHoliday = array();
            while (strtotime($start_date) <= strtotime($end_date)) {
                $timestamp = strtotime($start_date);
                $day = date('w', $timestamp);
                foreach ($businessHours as $val) {
                    if ($day == $val['day']) {
                        $weeklyHoliday[] = [
                            'id' => 'wh',
                            "title" => "Weekly Holiday",
                            "start" => $start_date,
                            "end" => $start_date
                        ];
                    }
                }
                $start_date = date("Y-m-d", strtotime("+1 days", strtotime($start_date)));
            }

            return $this->apiResponse([
                'status' => '1',
                'data' =>
                [
                    'employeeOffday' => $employeeOffDay,
                    'weeklyHoliday' => $weeklyHoliday,
                    'businessHoliday' => $businessHoliday
                ]
            ], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function deleteEmployeeOffday(Request $data)
    {
        try {
            if ($data->id != null) {
                SchEmployeeOffday::where('id', $data->id)->delete();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => ''], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function getEmployeeServices(Request $data)
    {
        // dd($data->branch);
        try {
            $empId = $data->sch_employee_id;
            // $category = SchServiceCategory::select('id', 'name')->get();
            $category = SchServiceCategory::select('id', 'name')->where('cmn_branch_id', $data->branch)->get();
            foreach ($category as $cval) {
                $cval['service'] = SchServices::where('sch_service_category_id', $cval->id)->whereNotIn('id', SchEmployeeService::where('sch_employee_id', $empId)->where('sch_service_category_id', $cval->id)->select('sch_service_id'))
                    ->selectRaw(
                        "id,
                        title,
                        0 as status,
                        0 as emp_service_id,
                        price as fees"
                    )->union(SchEmployeeService::join('sch_services', 'sch_employee_services.sch_service_id', '=', 'sch_services.id')
                        ->where('sch_employee_id', $empId)->where('sch_services.sch_service_category_id', $cval->id)
                        ->selectRaw(
                            "sch_services.id as id,
                             sch_services.title,
                             sch_employee_services.status,
                             sch_employee_services.id as emp_service_id,
                             sch_employee_services.fees"
                        ))->get();
            }
            return $this->apiResponse(['status' => '1', 'data' => $category], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function getEmployee()
    {
        
        $isAllBranch = true;
        if (Auth()->id())
        {

            $user = User:: where('id', Auth()->id())->first();
            $userType =$user->user_type;
            if (!($user->is_sys_adm || $userType  == 2)) {
                $isAllBranch = false;

            }

        }
        if ($isAllBranch) {

            try {
                $data = SchEmployee::join('cmn_branches', 'sch_employees.cmn_branch_id', '=', 'cmn_branches.id')->select(
                    'sch_employees.id',
                    'sch_employees.user_id',
                    'sch_employees.image_url',
                    'sch_employees.employee_id',
                    'sch_employees.cmn_branch_id',
                    'sch_employees.full_name',
                    'sch_employees.email_address',
                    'sch_employees.country_code',
                    'sch_employees.contact_no',
                    'sch_employees.present_address',
                    'sch_employees.permanent_address',
                    'sch_employees.gender',
                    'sch_employees.dob',
                    'sch_employees.hrm_department_id',
                    'sch_employees.hrm_designation_id',
                    'sch_employees.specialist',
                    'sch_employees.note',
                    'sch_employees.status',
                    'cmn_branches.name as branch',
                    'sch_employees.salary',
                    'sch_employees.commission',
                    'sch_employees.pay_commission_based_on',
                    'sch_employees.target_service_amount',
                    'sch_employees.id_card',
                    'sch_employees.passport'
                )->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (Exception $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }
        }

        else
        {

            
            try {

                $userBranch = SecUserBranch::where('user_id', Auth()->id())->select('cmn_branch_id')->get();

                $data = SchEmployee::join('cmn_branches', 'sch_employees.cmn_branch_id', '=', 'cmn_branches.id')->select(
                    'sch_employees.id',
                    'sch_employees.user_id',
                    'sch_employees.image_url',
                    'sch_employees.employee_id',
                    'sch_employees.cmn_branch_id',
                    'sch_employees.full_name',
                    'sch_employees.email_address',
                    'sch_employees.country_code',
                    'sch_employees.contact_no',
                    'sch_employees.present_address',
                    'sch_employees.permanent_address',
                    'sch_employees.gender',
                    'sch_employees.dob',
                    'sch_employees.hrm_department_id',
                    'sch_employees.hrm_designation_id',
                    'sch_employees.specialist',
                    'sch_employees.note',
                    'sch_employees.status',
                    'cmn_branches.name as branch',
                    'sch_employees.salary',
                    'sch_employees.commission',
                    'sch_employees.pay_commission_based_on',
                    'sch_employees.target_service_amount',
                    'sch_employees.id_card',
                    'sch_employees.passport'
                )->whereIn('sch_employees.cmn_branch_id', $userBranch->pluck('cmn_branch_id'))
                ->get();
                return $this->apiResponse(['status' => '1', 'data' => $data], 200);
            } catch (Exception $qx) {
                return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
            }

        }
    }

    public function getEmployeeService(Request $data)
    {
        try {
            $employeeId = $data->employeeId;
            $data = SchEmployeeSchedule::select(
                'id',
                'sch_employee_id',
                'day',
                'start_time',
                'end_time',
                'break_start_time',
                'break_end_time',
                'is_off_day'
            )->where("sch_employee_id", $employeeId)->get();
            if ($data->count() < 1) {
                $data = CmnBusinessHour::selectRaw(
                    '"" as id,
               "0" as sch_employee_id,
                day,
                start_time,
                end_time,
                is_off_day,
                "" as break_start_time,
               "" as break_end_time'
                )->where('cmn_branch_id', SchEmployee::where('id', $employeeId)->select('cmn_branch_id')->first()->cmn_branch_id)->get();
            }
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function salaries(Request $request)
    {
        return view('employee.salaries', ['employees' => SchEmployee::get()]);
    }

    public function salariesLoad(Request $request, $return = false)
    {
        try {

            $employeeId = $request->sch_employee_id;
            $employeeQuery = DB::table('sch_employees')
                ->select(
                    'sch_employees.id as sch_employee_id',
                    'sch_employees.commission',
                    'sch_employees.salary',
                    'sch_employees.full_name',
                    'sch_employees.employee_id',
                    'sch_employees.target_service_amount',
                    'sch_employees.pay_commission_based_on',
                    DB::raw('case sch_employees.pay_commission_based_on
                            when 1 then
                                if(sum(sch_service_bookings.service_amount) >= sch_employees.target_service_amount,TRUNCATE((sch_employees.salary/100)*sch_employees.commission,2),0)
                            when 2 then
                                if(sum(sch_service_bookings.service_amount) >= sch_employees.target_service_amount,TRUNCATE((sum(sch_service_bookings.service_amount)/100)*sch_employees.commission,2),0)
                            end as commission_amount
                        '),
                    DB::raw('count(sch_service_bookings.sch_employee_id) total_service'),
                    DB::raw('sum(sch_service_bookings.service_amount) total_service_amount')
                )
                ->where('sch_service_bookings.date', 'LIKE', $request->year . '-' . $request->month . '-%')
                ->leftJoin('sch_service_bookings', 'sch_service_bookings.sch_employee_id', '=', 'sch_employees.id')
                ->groupBy(
                    'sch_employees.id',
                    'sch_employees.commission',
                    'sch_employees.salary',
                    'sch_employees.full_name',
                    'sch_employees.employee_id',
                    'sch_employees.target_service_amount',
                    'sch_employees.pay_commission_based_on'
                );

            if ($employeeId)
                $employeeQuery->where('sch_employees.id', $employeeId);

            $data = $employeeQuery->get();
            if ($return)
                return $data;
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function salariesDownload(Request $request)
    {
        $salaryQuery = SchSalary::query();

        $salaryQuery->where('year', $request->input('year'))->where('month', $request->month);
        if ($request->sch_employee_id)
            $salaryQuery->where('sch_employee_id', $request->input('sch_employee_id'));

        $data = $salaryQuery->with('employee.branch')->get()->groupBy('employee.cmn_branch_id');

        $mpdf = new \Mpdf\Mpdf([
            'mode' => 'utf-8',
            'format' => 'A4-L',
            'default_font' => 'dejavusans',
            'setAutoTopMargin' => 'stretch',
            'setAutoBottomMargin' => 'stretch',
        ]);
        $mpdf->AddPageByArray([
            'margin-left' => 10,
            'margin-right' => 10,
            'margin-top' => 10,
            'margin-bottom' => 10,
        ]);

        $mpdf->SetTitle('Employee Salary Report');
        $mpdf->WriteHTML(view('employee.salaries_pdf', ['salaries' => $data, 'company_info' => CmnCompany::first(), 'input' => $request->all()]));
        $mpdf->Output('Employee Salary Report_' . now()->format('YmdHis') . '.pdf', 'I');
    }

    public function salariesStore(Request $request)
    {
        $request->validate([
            'data.*.sch_employee_id' => 'required|integer',
            'data.*.addition' => 'required|numeric',
            'data.*.deduction' => 'required|numeric',
            'data.*.is_paid' => 'required|integer|in:1,0',
            'sch_employee_id' => 'nullable|integer',
            'year' => 'required|integer',
            'month' => 'required|in:01,02,03,04,05,06,07,08,09,10,11,12',
        ]);
        try {
            DB::beginTransaction();

            $salaries = $this->salariesLoad($request, true);
            foreach ($request->data as $item) {
                $employee = $salaries->where('sch_employee_id', $item['sch_employee_id'])->first();
                if (!$employee)
                    continue;
                $salary = SchSalary::updateOrCreate([
                    'sch_employee_id' => $employee->sch_employee_id,
                    'year' => $request['year'],
                    'month' => $request['month'],
                ], [
                    'sch_employee_id' => $employee->sch_employee_id,
                    'year' => $request['year'],
                    'month' => $request['month'],
                    'basic_salary' => $employee->salary,
                    'total_service' => $employee->total_service,
                    'total_service_amount' => $employee->total_service_amount,
                    'commission' => $employee->commission,
                    'commission_amount' => $employee->commission_amount,
                    'pay_commission_based_on' => $employee->pay_commission_based_on,
                    'addition' => $item['addition'],
                    'deduction' => $item['deduction'],
                    'total_salary' => $item['addition'] + $employee->commission_amount + $employee->salary,
                    'netpay' => ($item['addition'] + $employee->commission_amount + $employee->salary) - $item['deduction'],
                    'is_paid' => $item['is_paid'],
                    'paid_at' => ($item['is_paid']) ? date('Y-m-d') : null,
                    'updated_by' => auth()->id(),
                ]);
            }

            DB::commit();
        } catch (\Exception $e) {
            if (env('APP_DEBUG'))
                dd($e);
            DB::rollBack();
            return $this->apiResponse(['status' => '422', 'data' => $e->getMessage()], 422);
        }

        return $this->apiResponse(['status' => '1', 'data' => "Success"], 200);
    }

    public function salariesDelete(Request $request)
    {
        $request->validate([
            'data' => 'required|array',
            'data.*' => 'required|integer',
        ]);
        try {
            DB::beginTransaction();

            SchSalary::whereIn('id', $request->data)->delete();

            DB::commit();
        } catch (\Exception $e) {
            if (env('APP_DEBUG'))
                dd($e);
            DB::rollBack();
            return $this->apiResponse(['status' => '422', 'data' => $e->getMessage()], 422);
        }

        return $this->apiResponse(['status' => '1', 'data' => "Success"], 200);
    }

    public function salariesProcessed(Request $request)
    {
        $salaryQuery = SchSalary::query();

        $salaryQuery
            ->select(
                'sch_salaries.*',
                'sch_employees.commission',
                'sch_employees.salary',
                'sch_employees.full_name',
                'sch_employees.employee_id',
                'sch_employees.target_service_amount',
                'sch_employees.pay_commission_based_on'
            )
            ->join('sch_employees', 'sch_salaries.sch_employee_id', '=', 'sch_employees.id')
            ->where('year', $request->input('year'))->where('month', $request->month);
        if ($request->sch_employee_id)
            $salaryQuery->where('sch_employee_id', $request->input('sch_employee_id'));

        try {
            return $this->apiResponse(['status' => '1', 'data' => $salaryQuery->get()], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
