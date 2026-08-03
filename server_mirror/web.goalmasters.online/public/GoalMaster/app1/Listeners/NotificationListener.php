<?php

namespace App\Listeners;

use App\Events\NotificationEvent;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationListener
{

    public $user_id;
    public $sender;
    public $message;

    /**
     * Create the event listener.
     *
     * @return void
     */
     public function __construct()
     {

     }

    /**
     * Handle the event.
     *
     * @param  \App\Events\NotificationEvent  $event
     * @return void
     */
    public function handle(NotificationEvent $event)
    {
        $this->user_id = $event->user_id;
        $this->sender = $event->sender;
        $this->message = $event->message;
        $this->sendToNode();
    }

    private function sendToNode()
    {
        try {
            Http::post(env('NODE_URL') . '/send-message', [
                'text' => $this->message,
                'user_id' => $this->user_id,
                'sender' => $this->sender,
            ]);
        } catch (\Exception $e) {
            Log::error('Error sending notification to Node.js: ' . $e->getMessage());
        }
    }
}
