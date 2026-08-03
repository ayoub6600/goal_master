<?php

namespace App\Models\UserManagement;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SecRolePermissionInfo extends Model
{
    protected $fillable = [
        'sec_resource_id',
        'permission_name',
        'route_name',
        'status',
        'created_by',
    ];

    public function resource()
    {
        return $this->belongsTo(SecResource::class);
    }
}
