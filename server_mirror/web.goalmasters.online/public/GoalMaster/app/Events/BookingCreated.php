<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Queue\SerializesModels;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;

class BookingCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $booking;
    public $systemUsers;
    public $user;
    public $name;

    public function __construct($booking, $systemUsers, $user)
    {
        $this->booking = $booking;
        $this->systemUsers = $systemUsers;
        $this->user = $user;

        if($this->user->name){
            $this->name = $this->user->name;
        }
        else{
            $this->name = $this->user->full_name;
        }
    }


    public function broadcastOn()
    {
        $channels = [];
        foreach ($this->systemUsers as $systemUser) {
            $channels[] = new Channel('admin-notifications.' . $systemUser->id);
        }

        return $channels;
    }
    public function broadcastWith()
    {
        return [
            'message' => "تم إضافة حجز جديد بواسطة {$this->name}",
            // 'id'=>$this->booking['order_details'][0]['id'],
            'id'=>$this->booking['id'],
            'created_at' => now()->diffForHumans(),
        ];
    }
    public function broadcastAs()
    {
        return 'bookingCreated';
    }
}
