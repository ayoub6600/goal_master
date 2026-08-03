<?php

namespace App\Models\UserManagement;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SecUserBranch extends Model
{
    protected $fillable = [
        'user_id',
        'cmn_branch_id',
        'created_by',
        'updated_by'
    ];
}
