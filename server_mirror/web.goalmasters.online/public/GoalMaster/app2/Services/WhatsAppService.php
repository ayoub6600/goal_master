<?php

namespace App\Services;

use Carbon\Carbon;
use Mpdf\Tag\Details;
use GuzzleHttp\Client;
use App\Enums\PaymentType;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class WhatsAppService
{
  protected $authKey;
  protected $url;
  protected $sender_number;
  protected $client;


  public function __construct()
  {
    $this->client = new Client();
    $this->authKey = env('MSG91_AUTH_KEY');
    $this->sender_number = env('MSG91_SENDER_NUMBER');
    $this->url = 'https://api.msg91.com/api/v5/whatsapp/whatsapp-outbound-message/bulk/';
  }

  public function sendMessage($phoneNumber, $customer_name, $messageComponents)
  {
    $phoneNumber = env('country_code') . $phoneNumber;
    // $messageComponents = $messageComponents->order_details[0];

    // Convert 24-hour time format to 12-hour format with AM/PM
    $start_time_12hr = date('g:i A', strtotime($messageComponents->start_time));
    $end_time_12hr = date('g:i A', strtotime($messageComponents->end_time));

    switch ($messageComponents->status) {
      case 0:
        $status = '🛑حجزك غير خالص الرجاء الدفع في اقرب فرصه🛑';
        break;
      case 1:
        $status = '🔵 حجزك بانتظار قبول الطلب 🔵';
        break;
      case 2:
        $status = '✅ تم تأكيد حجزك ✅';
        break;
      case 3:
        $status = '❌ تم إلغاء الحجز ❌';
        break;
      case 4:
        $status = '✔️ حجزك خالص ✔️';
        break;
      default:
        $status = '❓ Unknown Status ❓';
        break;
    }
    try {
        $components = [
            'body_1' => [
                'type' => 'text',
                'value' => $customer_name
            ],
            'body_2' => [
                'type' => 'text',
                'value' => $status
            ],
            'body_3' => [
                'type' => 'text',
                'value' => $messageComponents->branch
            ],
            'body_4' => [
                'type' => 'text',
                'value' => $messageComponents->id
            ],
            'body_5' => [
                'type' => 'text',
                'value' => $messageComponents->service
            ],
            'body_6' => [
                'type' => 'text',
                'value' =>Carbon::parse($messageComponents->date)->format('Y-m-d')
            ],
            'body_7' => [
                'type' => 'text',
                'value' => $start_time_12hr . ' إلي ' . $end_time_12hr
            ],
            'body_8' => [
                'type' => 'text',
                'value' => 'تم دفع مبلغ : ' . $messageComponents->paid_amount .
                    ' من إجمالى : ' . $messageComponents->service_amount .
                    '  طريقه الدفع : ' . ($messageComponents->web == 1 
                        ? PaymentType::getKeyArabic($messageComponents->payment_type) 
                        : PaymentType::getKey($messageComponents->payment_type))],        
        ];
    
        // ✅ إضافة body_9 فقط إذا كان هناك إحداثيات
        if (!empty($messageComponents->branch_lat) && !empty($messageComponents->branch_long)) {
            $components['body_9'] = [
                'type' => 'text',
                'value' => 'يمكنك الوصول إلى الملعب من خلال: https://www.google.com/maps/search/?api=1&query=' 
                            . $messageComponents->branch_lat . ',' . $messageComponents->branch_long
            ];
        }
    
        $response = $this->client->post('https://api.msg91.com/api/v5/whatsapp/whatsapp-outbound-message/bulk/', [
            'headers' => [
                'authkey' => $this->authKey,
                'Content-Type' => 'application/json',
            ],
            'json' => [
                'integrated_number' => $this->sender_number,
                'content_type' => 'template',
                'payload' => [
                    'messaging_product' => 'whatsapp',
                    'type' => 'template',
                    'template' => [
                        'name' => 'booking_confirmation',
                        'language' => [
                            'code' => 'ar',
                            'policy' => 'deterministic',
                        ],
                        'to_and_components' => [
                            [
                                'to' => [$phoneNumber],
                                'components' => $components // ✅ تمرير المصفوفة بعد تصحيحها
                            ],
                        ],
                    ],
                ],
            ],
        ]);
    
        return json_decode($response->getBody()->getContents(), true);
    } catch (\Exception $e) {
        Log::error('WhatsApp message failed to send.', ['error' => $e->getMessage()]);
        return ['success' => false, 'message' => 'Failed to send message'];
    }
  }


  public function sendOtp($phoneNumber, $otp)
  {
    $phoneNumber = env('country_code') . $phoneNumber;
    try {
      $response = $this->client->post('https://api.msg91.com/api/v5/whatsapp/whatsapp-outbound-message/bulk/', [
        'headers' => [
          'authkey' => $this->authKey,
          'Content-Type' => 'application/json',
        ],
        'json' => [
          'integrated_number' => $this->sender_number,
          "content_type" => "template",
          "payload" => [
            "messaging_product" => "whatsapp",
            "type" => "template",
            "template" => [
              "name" => "otp",
              "language" => [
                "code" => "ar",
                "policy" => "deterministic",
              ],
              "namespace" => "957b2d5f_d314_4075_aa50_24f19948e861",
              "to_and_components" => [
                [
                  "to" => [$phoneNumber],
                  "components" => [
                    "body_1" => [
                      "type" => "text",
                      "value" => $otp,
                    ],
                    "button_1" => [
                      "subtype" => "url",
                      "type" => "text",
                      "value" => $otp,
                    ],
                  ],
                ],
              ],
            ],
          ],
        ],
      ]);

      return json_decode($response->getBody()->getContents(), true);
    } catch (\Exception $e) {
      Log::error('WhatsApp message failed to send.', ['error' => $e->getMessage()]);
      return ['success' => false, 'message' => 'Failed to send message'];
    }
  }
}
