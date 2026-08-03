<?php

namespace App\Notifications;

use App\Http\Repository\UtilityRepository;
use Exception;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ServiceBookingFeedbackNotification extends Notification
{
    use Queueable;
    public $bookingData;
    /**
     * Create a new notification instance.
     *
     * @return void
     */
    public function __construct($bookingData)
    {
        $this->bookingData = $bookingData;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return ['mail'];
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
            ->subject($this->bookingData['message_subject'])
            ->line($this->bookingData['user_name'])
            ->line($this->bookingData['message_body'])
            ->line($this->bookingData['booking_info'])
            ->action('Submit Feedback', $this->bookingData['action_url'])
            ->line($this->bookingData['message_footer']);
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
