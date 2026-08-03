<?php

namespace App\Models\UserManagement;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SecRolePermission extends Model
{
    protected $fillable = [
         'sec_role_permission_info_id',
         'sec_role_id',
         'status',
         'created_by',
         'updated_by',
     ];

    public function rolePermissionInfo()
    {
        return $this->belongsTo(SecRolePermissionInfo::class);
    }
    public function role()
    {
        return $this->belongsTo(SecRole::class);
    }
}
