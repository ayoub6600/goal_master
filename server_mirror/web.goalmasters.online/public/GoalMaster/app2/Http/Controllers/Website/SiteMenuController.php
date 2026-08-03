<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SiteMenuController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }
    
}
