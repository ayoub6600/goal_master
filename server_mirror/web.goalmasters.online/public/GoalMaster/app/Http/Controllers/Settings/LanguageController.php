<?php
namespace App\Http\Controllers\Settings;
use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Settings\CmnLanguage;
use App\Models\Settings\CmnTranslation;
use Exception;
use Facade\FlareClient\Http\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
class LanguageController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function language()
    {
        return view('settings.language');
    }

    public function translateLanguage(Request $request)
    {
        return view('settings.translate-language', ['translateLang' => CmnLanguage::where('id', $request->id)->select('name')->first()->name]);
    }

    public function translateLanguageList(Request $request)
    {
        try {
            $data = CmnTranslation::join('cmn_languages', 'cmn_translations.cmn_language_id', '=', 'cmn_languages.id')
                ->where('cmn_languages.code', 'ar')
                ->select(
                    'cmn_translations.lang_key',
                    'cmn_translations.lang_value',
                    'cmn_translations.id as en_trans_id'
                )->get();
            $translatableLanguage = CmnTranslation::where('cmn_language_id', $request->id)->select('id', 'lang_value', 'lang_key')->get();

            foreach ($data as $val) {
                $val->id = 0;
                $val->lang_id = $request->id;
                $val->lang_value = '';
                foreach ($translatableLanguage as $trnsLang) {
                    if ($val->lang_key == $trnsLang->lang_key) {
                        $val->id = $trnsLang->id;
                        $val->lang_value = $trnsLang->lang_value;
                    }
                }
            }
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function getLanguage()
    {
        try {
            $data = CmnLanguage::get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }

    public function saveLanguage(Request $request)
    {
        try {
            $validator = Validator::make($request->toArray(), [
                'name' => ['required', 'string', 'max:200', 'unique:cmn_languages'],
                'code' => ['required', 'string', 'max:200', 'unique:cmn_languages'],
            ]);

            if (!$validator->fails()) {
                CmnLanguage::create($request->all());
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function updateLanguage(Request $request)
    {
        try {
            $validator = Validator::make($request->toArray(), [
                'name' => ['required', 'string', 'max:200'],
            ]);
            if (!$validator->fails()) {
                $language =  CmnLanguage::where('id', $request->id)->first();
                if ($language != null) {
                    if ($language->code == 'en') {
                        CmnLanguage::where('id', $request->id)->update([
                            'default_language' => $request->default_language ?? 0
                        ]);
                    } else {
                        CmnLanguage::where('id', $request->id)->update([
                            'name' => $request->name,
                            'code' => $request->code,
                            'default_language' => $request->default_language ?? 0
                        ]);
                    }
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
                return $this->apiResponse(['status' => '0', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function updateRtlStatus(Request $request)
    {
        try {

            CmnLanguage::where('id', $request->id)->whereNotIn('code', ['en'])->update([
                'rtl' => $request->status
            ]);
            return $this->apiResponse(['status' => '1', 'data' => ''], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }


    public function deleteLanguage(Request $data)
    {
        try {

            $rtr = CmnLanguage::where('id', $data->id)->whereNotIn('code', ['en'])->delete();
            return $this->apiResponse(['status' => '1', 'data' => $rtr], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }

    public function saveTranslatedLanguage(Request $request)
    {
        try {


            $data = CmnTranslation::join('cmn_languages', 'cmn_translations.cmn_language_id', '=', 'cmn_languages.id')
                ->where('cmn_languages.code', 'en')
                ->select(
                    'cmn_translations.lang_key',
                    'cmn_translations.id'
                )->get();
            $arr = array();

            foreach ($request->translate as $val) {
                if ($val['id'] != 0) {
                    CmnTranslation::where('id', $val['id'])->update([
                        'lang_value' => $val['lang_value']
                    ]);
                } else if (UtilityRepository::emptyOrNullToZero($val['lang_value']) != '0') {
                    $arr[] = [
                        'cmn_language_id' => $val['lang_id'],
                        'lang_value' => $val['lang_value'],
                        'lang_key' => $data->where('id', $val['en_trans_id'])->pluck('lang_key')[0]
                    ];
                }
            }
            CmnTranslation::insert($arr);
            return $this->apiResponse(['status' => '1', 'data' => ''], 200);
        } catch (Exception $ex) {
            return $this->apiResponse(['status' => '501', 'data' => $ex], 400);
        }
    }
}
