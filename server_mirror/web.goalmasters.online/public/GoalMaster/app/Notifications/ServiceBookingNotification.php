<?php

namespace App\Notifications;

use App\Http\Repository\UtilityRepository;
use Exception;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ServiceBookingNotification extends Notification
{
    use Queueable;
    public $serviceMessage;
    /**
     * Create a new notification instance.
     *
     * @return void
     */
    public function __construct($serviceMessage)
    {
        $this->serviceMessage = $serviceMessage;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        if($notifiable->user_type == 1){
            return ['database'];
        }
        else{
            return ['mail'];
        }
    }

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject($this->serviceMessage['message_subject'])
            ->line($this->serviceMessage['user_name'])
            ->line($this->serviceMessage['message_body'])
            ->line($this->serviceMessage['booking_info'])
            ->action('View Booking Info', $this->serviceMessage['action_url'])
            ->line($this->serviceMessage['message_footer']);
    }

/**
 * Get the database representation of the notification.
 *
 * @param  mixed  $notifiable
 * @return array  An array containing the notification message and order ID.
 */
    public function toDatabase($notifiable)
    {
        return [
            'message' => $this->serviceMessage['message'],
            'id'=>$this->serviceMessage['id']
        ];
    }
    
    /**
     * Get the array representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function toArray($notifiable)
    {
        return [
            //
        ];
    }
}
