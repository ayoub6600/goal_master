<?php

namespace App\Models;

use App\Models\Customer\CmnCustomer;
use App\Models\Customer\CmnUserBalance;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Notifications\Notifiable;
use App\Models\UserManagement\SecUserRole;
use App\Models\UserManagement\SecUserBranch;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

// class User extends Authenticatable implements MustVerifyEmail{
class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name',
        // 'email',
        'password',
        'username',
        'photo',
        'phone_number',
        'status',
        'sec_role_id',
        'is_sys_adm',
        'user_type', //1 for system user,2 web site user
        // 'email_verified_at',
        'sch_employee_id',
        'created_by',
        'reset_token'
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password',
        'remember_token',
        'created_at',
        'updated_at',
        // 'email_verified_at',
        'reset_token',
        'created_by',
        'updated_by',
        'deleted_at',
        'pivot'
    ];

    public function secUserRole()
    {
        return $this->hasMany(SecUserRole::class, 'sec_user_id');
    }

    public function balances()
    {
        return $this->hasMany('App\Models\Customer\CmnUserBalance');
    }

    public function balance()
    {
        // return $this->balances->where('status',1)->sum('amount');
        $balanceCR = $this->balances->where('balance_type', 1)->sum('amount');
        $balanceDR = $this->balances->where('balance_type', 0)->sum('amount');
        $totalBalance = $balanceCR - $balanceDR;
        return $totalBalance;
    }

    public function userBalance()
    {
        return $this->morphMany(CmnUserBalance::class, "balanceable");
    }


    public function balancesApi()
    {
        return $this->morphMany(CmnUserBalance::class, "balanceable");
    }

    public function getBalanceWithLock()
    {
        $balances = $this->balancesApi()->lockForUpdate()->get();

        $balanceCR = $balances->where('balance_type', 1)->sum('amount');
        $balanceDR = $balances->where('balance_type', 0)->sum('amount');

        return $balanceCR - $balanceDR;
    }


    // public function creator()
    // {
    //     return $this->belongsTo(User::class, 'created_by');
    // }

    // public function createdUsers()
    // {
    //     return $this->hasMany(User::class, 'created_by');
    // }




    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
    ];


        // override two method
    /**
     * (1)
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**(2)
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }

    public function customers()
    {
        return $this->belongsToMany(CmnCustomer::class, 'manager_customer', 'manager_id', 'customer_id');
    }

    public function customer()
    {
        return $this->hasOne(CmnCustomer::class);
    }

    public function branches()
    {
        return $this->hasMany(SecUserBranch::class, 'user_id', 'id');
    }
}
