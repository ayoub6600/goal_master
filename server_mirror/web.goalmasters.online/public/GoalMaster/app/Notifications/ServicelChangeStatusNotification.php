<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ServicelChangeStatusNotification extends Notification
{
    use Queueable;
    public $orderData;
    public $user;
    public $name;
    public $message;

    /**
     * Create a new notification instance.
     *
     * @return void
     */
    public function __construct($orderData, $user=null,$message)
    {
        $this->orderData = $orderData;
        $this->user = $user;

        if($this->user->name){
            $this->name = $this->user->name;
        }
        else{
            $this->name = $this->user->full_name;
        }
      $this->message = $message;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
            return ['database'];
        
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
        ->subject("Thank You for your order ".$this->orderData->id)
        ->markdown('emails.service-order', ['order' => $this->orderData]);
    }

    public function toDatabase($notifiable)
    {
        return [
            'message' => "اهلا {$this->name}، {$this->message}",
            // 'id' => $this->orderData['order_details'][0]['id']
            'id' => $this->orderData['id'],
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
