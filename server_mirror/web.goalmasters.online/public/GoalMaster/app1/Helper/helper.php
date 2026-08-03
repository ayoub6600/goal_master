<?php

use App\Events\NotificationEvent;
use App\Models\Settings\CmnLanguage;
use Illuminate\Support\Facades\Lang;
use Illuminate\Support\Facades\Cache;
use App\Models\Settings\CmnTranslation;
use Illuminate\Support\Facades\Session;
use App\Http\Repository\UtilityRepository;
use App\Http\Repository\Language\LanguageRepository;
use illuminate\Support\Facades\Log;

function dsAsset($path, $source = null)
{
    return asset($path . '?v=1.0.2', $source);
}

function translate($key, $langId = null)
{
    if ($key != null) {
        $langTranslate = Cache::get('langTranslate');

        if ($langId == null) {
            if (isset(Session::get('lang')['id'])) {
                $langId = Session::get('lang')['id'];
            } else {
                $engLangId = CmnLanguage::where('default_language', 1)->orWhere('code', 'en')->select('id')->first()->id;
                $langId = $engLangId;
            }
        }

        if ($langTranslate != array()) {

            if (!isset($langTranslate[$key . '_' . $langId])) {
                //if translate key & value not found in cache
                $trans = CmnTranslation::where('cmn_language_id', $langId)->where('lang_key','==', $key)->select('lang_value')->first();
                $engLangId = CmnLanguage::where('default_language', 1)->orWhere('code', 'en')->select('id')->first()->id;
                if ($trans == null && $langId == $engLangId) {

                    //insert default lang value if not found default lang
                    CmnTranslation::create([
                        'cmn_language_id' => $langId,
                        'lang_key' => $key,
                        'lang_value' => $key
                    ]);
                    $langRepo = new LanguageRepository();
                    $langRepo->setLangaugeSession($langId);
                    return $key;
                } else if ($trans != null) {
                    // found key value
                    return $trans['lang_value'];
                } else {
                    //translation is not found
                    return $key;
                }
            } else {
                //return translated value
                return $langTranslate[$key . '_' . $langId];
            }
        } else {

            $trans = CmnTranslation::where('cmn_language_id', $langId)->where('lang_key','==', $key)->select('lang_value')->first();
            $engLangId = CmnLanguage::where('default_language', 1)->orWhere('code', 'en')->select('id')->first()->id;
            if ($trans == null && $langId == $engLangId) {
                //insert default lang value if not found default lang
                CmnTranslation::create([
                    'cmn_language_id' => $langId,
                    'lang_key' => $key,
                    'lang_value' => $key
                ]);
                $langRepo = new LanguageRepository();
                $langRepo->setLangaugeSession($langId);
                return $key;
            } else if ($trans != null) {
                // is not default lang and found key value
                return $trans['lang_value'];
            } else {
                //translation is not found
                return $key;
            }
        }
    }
}

function hex2Rgba($color, $opacity = 1)
{
    return UtilityRepository::hex2Rgba($color, $opacity);
}

if (!function_exists('imageName')) {
    function imageName($name, $withExt = 1, $prefix = NULL, $suffix = NULL)
    {
        $extension = pathinfo($name, PATHINFO_EXTENSION);
        $name = preg_replace("/[\s]|\#|\$|\&|\@/", "_", pathinfo($name, PATHINFO_FILENAME));
        $name = $prefix . '_' . $name . '_' . $suffix;
        if ($prefix == NULL) {
            $name = substr($name, -170);
        } else {
            $name = substr($name, 0, 170);
        }

        $name .= ('_' . time());

        if ($withExt) {
            $name .= ('.' . $extension);
        }

        return $name;
    }
}

if (!function_exists('imageExtension')) {
    function imageExtension($name)
    {
        return pathinfo($name, PATHINFO_EXTENSION);
    }
}


if (!function_exists('SocketNotify')) {
    function SocketNotify($user_id, $sender, $message)
    {
        try {
            //? todo send notification to customer 
            event(new NotificationEvent($user_id, $sender, $message));
        } catch (\Exception $e) {
            Log::error('Error sending notification: ' . $e->getMessage());
        }
    }
}

