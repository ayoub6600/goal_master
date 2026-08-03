<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class BookingStatus implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $serviceMessage;
    public $systemUsers;
    public $user;

    public function __construct($serviceMessage, $systemUsers, $user)
    {
        $this->serviceMessage = $serviceMessage;
        $this->systemUsers = $systemUsers;
        $this->user = $user;
    }


    public function broadcastOn()
    {
        $channels = [];
        foreach ($this->systemUsers as $user) {
            $channels[] = new Channel('admin-notifications.' . $user->id);
        }

        return $channels;
    }

    public function broadcastWith()
    {
        return [
            'message' => $this->serviceMessage['message'],
            'id'=>$this->serviceMessage['id'],
            'created_at' => now()->diffForHumans(),
        ];
    }

    public function broadcastAs()
    {
        return 'bookingChanged';
    }
}
