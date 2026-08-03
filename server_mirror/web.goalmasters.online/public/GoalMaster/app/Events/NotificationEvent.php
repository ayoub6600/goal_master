<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;


class NotificationEvent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $user_id;
    public $sender;
    public $message;

    public function __construct($user_id, $sender, $message)
    {
        $this->user_id = $user_id;
        $this->sender = $sender;
        $this->message = $message;
    }

    public function broadcastWith()
    {
        return [
            'user_id' => $this->user_id,
            'sender' => $this->sender,
            'message' => $this->message,
            'created_at' => now()->diffForHumans(),
        ];
    }

    public function broadcastOn()
    {
        return new PrivateChannel('notifications.' . $this->user_id);
    }


}
