<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class UserNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public $booking;
    public $message;

    public function __construct($booking, $message)
    {
        $this->booking = $booking;
        $this->message = $message;
    }

    // تحديد القنوات المستخدمة (Broadcast + Database)
    public function via($notifiable)
    {
        return [ 'database'];
    }

    public function toArray($notifiable)
    {
        \Log::info('UserNotification triggered', [
            'user_id' => $notifiable->id,
            'booking_id' => $this->booking->id,
            'message' => $this->message,
        ]);
    
        return [
            'booking_id' => $this->booking->id,
            'message' => $this->message,
            'created_at' => now()->toDateTimeString(),
        ];
    }
    

}
