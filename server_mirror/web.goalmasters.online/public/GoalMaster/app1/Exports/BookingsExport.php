<?php

namespace App\Exports;

use Illuminate\Contracts\View\View;
use Maatwebsite\Excel\Concerns\FromView;

class BookingsExport implements FromView
{
    protected $services;
    protected $online ;

    public function __construct($services , $online)
    {
        $this->services = $services;
        $this->online = $online;
    }

    public function view(): View
    {
        return view('dashboard.bookings', [
            'services' => $this->services,
            'online' => $this->online
        ]);
    }
}
