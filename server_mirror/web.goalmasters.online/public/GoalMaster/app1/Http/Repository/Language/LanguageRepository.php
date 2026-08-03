<?php

namespace App\Http\Repository\Language;

use App\Models\Settings\CmnLanguage;
use App\Models\Settings\CmnTranslation;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Session;

class LanguageRepository
{

    public function setLangaugeSession($langId)
    {
        Session::put("lang", CmnLanguage::where('id', $langId)->select('id', 'rtl', 'code')->first());
        $trans = CmnTranslation::select('lang_key', 'lang_value', 'cmn_language_id')->get();
        $langArr = [];
        foreach ($trans as $val) {
            $langArr[$val->lang_key . '_' . $val->cmn_language_id] = $val->lang_value;
        }
        Cache::put("langTranslate", $langArr, now()->addDays(15));
    }

    public function getLanguage()
    {
        $data = CmnLanguage::select('id', 'name')->orderByRaw('default_language desc')->get();
        if (session()->get('lang') == null) {
            $this->setLangaugeSession($data[0]->id);
        }
        return $data;
    }
}
