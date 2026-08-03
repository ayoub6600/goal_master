<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EmailConfigurationController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function emailConfiguration()
    {
        return view('website.email-configuration');
    }

    public function saveEmailConfiguration(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'mail_host' => ['required', 'string'],
                'mail_port' => ['required', 'int'],
                'mail_username' => ['required', 'string'],
                'mail_password' => ['required', 'string']
            ]);
            if (!$validator->fails()) {
                $forceAdd = $request->force_add;
                if ($forceAdd != null  && $forceAdd == 1) {
                    $forceAdd = true;
                }else{
                    $forceAdd = false;
                }
                UtilityRepository::overWriteEnvFile("MAIL_MAILER", $request->mail_mailer, $forceAdd);
                UtilityRepository::overWriteEnvFile("MAIL_HOST", $request->mail_host, $forceAdd);
                UtilityRepository::overWriteEnvFile("MAIL_PORT", $request->mail_port, $forceAdd);
                UtilityRepository::overWriteEnvFile("MAIL_USERNAME", $request->mail_username, $forceAdd);
                UtilityRepository::overWriteEnvFile("MAIL_PASSWORD", $request->mail_password, $forceAdd);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    /**
     * overWrite the Env File values.
     * @param  String type
     * @param  String value
     * @return \Illuminate\Http\Response
     */
    public function overWriteEnvFile($type, $val, $ovr = false)
    {
        if (env('DEMO_MODE') != 'On') {
            $path = base_path('.env');
            if (file_exists($path)) {
                $val = '"' . trim($val) . '"';
                if (is_numeric(strpos(file_get_contents($path), $type)) && strpos(file_get_contents($path), $type) >= 0) {
                    file_put_contents($path, str_replace(
                        $type . '="' . env($type) . '"',
                        $type . '=' . $val,
                        file_get_contents($path)
                    ));
                } else {
                    file_put_contents($path, file_get_contents($path) . "\r\n" . $type . '=' . $val);
                }
            }
        }
    }
}
