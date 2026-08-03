<?php

namespace App\Http\Controllers\UserManagement;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class UserBranchController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function userBranch(){
        return view('user_management.user-branch');
    }

    public function saveOrUpdateUserBranch(Request $request)
    {
    }
    public function deleteUserBranch(Request $request)
    {
    }

    public function getUserBranch()
    {
        return null;
    }
}
