<?php

namespace App\Models\UserManagement;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SecResource extends Model
{
    protected $fillable = [
         'name',
         'display_name',
         'sec_resource_id',
         'sec_module_id',
         'status',
         'serial',
         'level',
         'method',
         'icon',
         'created_by',
         'updated_by',
    ];

    public function rolePermissionInfos(){
        return $this->hasMany(SecRolePermissionInfo::class,'sec_resource_id');
    }

}
