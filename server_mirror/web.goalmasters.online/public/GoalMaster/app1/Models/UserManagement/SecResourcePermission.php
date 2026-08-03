<?php

namespace App\Models\UserManagement;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SecResourcePermission extends Model
{
    protected $fillable = [
         'display_name',
         'sec_resource_id',
         'sec_role_id',
         'status',
         'created_by',
         'updated_by',
     ];

    public function resource()
    {
        return $this->belongsTo(SecResource::class);
    }

    public function roles()
    {
        return $this->belongsToMany(SecRole::class);
    }


}
