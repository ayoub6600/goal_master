<?php

namespace App\Models\UserManagement;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SecRole extends Model
{
    protected $fillable = [
       'name',
       'is_default_user_role',
       'status',
       'created_by',
       'updated_by',
   ];

   public function premissions(){
       return $this->hasMany(SecRolePermission::class,'sec_role_id');
   }

}
