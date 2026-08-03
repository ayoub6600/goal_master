<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CardCharged implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $card;
    public $user;
    public $systemUsers;
    /**
     * Create a new event instance.
     *
     * @return void
     */
    public function __construct($systemUsers, $card, $user)
    {
        //
        $this->systemUsers = $systemUsers;
        $this->card = $card;
        $this->user = $user;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return \Illuminate\Broadcasting\Channel|array
     */
    // public function broadcastOn()
    // {
    //     $channels = [];
    //     foreach ($this->systemUsers as $user) {
    //         $channels[] = new Channel('admin-notifications.' . $user->id);
    //     }

    //     return $channels;
    // }
public function broadcastOn()
{
    $channels = [];

    if (!$this->systemUsers || !is_iterable($this->systemUsers)) {
        \Log::error('systemUsers is not iterable in CardCharged event');
        return [];
    }

    foreach ($this->systemUsers as $user) {
        if (!isset($user->id)) {
            \Log::error('Invalid user object in CardCharged event');
            continue;
        }

        $channels[] = new Channel('admin-notifications.' . $user->id);
    }

    return $channels;
}

    public function broadcastWith()
    {
        return [
            'message' => "لقد تم شحن كارت بقيمة {$this->card->group->price} بواسطة {$this->user->name}",
            'created_at' => now()->diffForHumans(),
        ];
    }

    public function broadcastAs()
    {
        return 'CardCharged';
    }
}
