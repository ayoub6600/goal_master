<?php

namespace App\Console\Commands;

use App\Enums\ServiceCancelPaymentStatus;
use App\Enums\ServicePaymentStatus;
use App\Enums\ServiceStatus;
use App\Http\Repository\Booking\BookingRepository;
use App\Models\Booking\SchServiceBookingInfo;
use App\Models\Employee\SchEmployeeService;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Symfony\Component\Console\Command\Command as CommandAlias;

class KeepBookingServiceMonthly extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'booking:monthly';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'keep booking monthly updates';

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
		$serviceBookingInfos = SchServiceBookingInfo::query()->with('serviceBookingsAll')->where(['is_monthly' => 1, 'is_monthly_active' => 1])
			->with('serviceBookingsAll', function ($query){
				$query->where('date', now()->format('Y-m-d'));
			})
			->whereHas('serviceBookingsAll', function ($query){
				$query->where('date', now()->format('Y-m-d'));
			})
			->get();
		
		foreach ($serviceBookingInfos as $serviceBookingInfo){
			$newServiceBookings = [];
			foreach($serviceBookingInfo->serviceBookingsAll as $serviceBooking){
				
				$serviceCharge = SchEmployeeService::where('sch_employee_id', $serviceBooking->sch_employee_id)
					->where('sch_service_id', $serviceBooking->sch_service_id)->select('fees')->first();
				$date = Carbon::parse($serviceBooking->date);
				$date->addWeeks(4);
				$date = $this->getNextServiceBookingDate($date, $serviceBooking);
				if (is_null($date)){
					continue;
				}
				
				$newServiceBookings[] = [
					'id' => null,
					'cmn_branch_id' => $serviceBooking->cmn_branch_id,
					'cmn_customer_id' => $serviceBooking->cmn_customer_id,
					'sch_employee_id' => $serviceBooking->sch_employee_id,
					'date' => $date->format('Y-m-d'),
					'start_time' => $serviceBooking->start_time,
					'end_time' => $serviceBooking->end_time,
					'sch_service_id' => $serviceBooking->sch_service_id,
					'status' => ServiceStatus::Approved,
					'service_amount' => $serviceCharge->fees ?? $serviceBooking->service_amount,
					'paid_amount' => 0,
					'payment_status' => ServicePaymentStatus::Unpaid,
					'cmn_payment_type_id' => $serviceBooking->cmn_payment_type_id,
					'canceled_paid_amount' => 0,
					'cancel_paid_status' => ServiceCancelPaymentStatus::Unpaid,
					'remarks' => $serviceBooking->remarks,
				];
			}
			
			$serviceBookingInfo->serviceBookings()->syncWithoutDetaching($newServiceBookings);
			
		}
		return CommandAlias::SUCCESS;
    }
	
	private function getNextServiceBookingDate(Carbon $date, mixed $serviceBooking, $count = 1): ?Carbon
	{
		if ($count > 3){
			return null;
		}
		$bookingRepo = app()->make(BookingRepository::class);
		if($bookingRepo->serviceIsAvaiable($serviceBooking->sch_service_id, $serviceBooking->sch_employee_id, $date, $serviceBooking->start_time, $serviceBooking->end_time) > 0){
			$date->addWeek();
			$count++;
			$this->getNextServiceBookingDate($date, $serviceBooking, $count);
		}
		return $date;
	}
}
