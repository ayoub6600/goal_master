<?php

namespace App\Http\Repository;

use ErrorException;
use Illuminate\Support\Facades\File;
use RachidLaasri\LaravelInstaller\Middleware\canInstall;

class UtilityRepository
{
    public static function saveFile($file, $allowMimeTypeArray, $uploadPath = null)
    {
        if (!in_array($file->getClientMimeType(), $allowMimeTypeArray))
            throw new ErrorException("The file type is not allow. File type is: " . $file->getClientMimeType(), 400);
        $path = "uploadfiles";
        if ($uploadPath != null)
            $path = $uploadPath;
        $publicPath = public_path($path);
        if (!File::exists($publicPath)) {
            File::makeDirectory($publicPath, 0777, true, true);
        }
        $filePath = $file->store($path);
        return $filePath;
    }

    public static function hex2Rgba($color, $opacity = 1)
    {

        $default = 'rgb(0,0,0)';

        //Return default if no color provided
        if (empty($color))
            return $default;

        //Sanitize $color if "#" is provided 
        if ($color[0] == '#') {
            $color = substr($color, 1);
        }

        //Check if color has 6 or 3 characters and get values
        if (strlen($color) == 6) {
            $hex = array($color[0] . $color[1], $color[2] . $color[3], $color[4] . $color[5]);
        } elseif (strlen($color) == 3) {
            $hex = array($color[0] . $color[0], $color[1] . $color[1], $color[2] . $color[2]);
        } else {
            return $default;
        }

        //Convert hexadec to rgb
        $rgb =  array_map('hexdec', $hex);

        //Check if opacity is set(rgba or rgb)
        if ($opacity) {
            if (abs($opacity) > 1)
                $opacity = 1.0;
            $output = 'rgba(' . implode(",", $rgb) . ',' . $opacity . ')';
        } else {
            $output = 'rgb(' . implode(",", $rgb) . ')';
        }

        //Return rgb(a) color string
        return $output;
    }

    /**
     * overWrite the Env File values.
     * @param  String type
     * @param  String value
     * @param  Bool forceAdd
     * @return \Illuminate\Http\Response
     */
    public static function overWriteEnvFile($type, $val, $forceAdd = false)
    {
        $path = base_path('.env');
        if (file_exists($path)) {
            $val = '"' . trim($val) . '"';
            if (strpos(file_get_contents($path), $type) != false && strpos(file_get_contents($path), $type) >= 0) {
                if ($forceAdd) {
                    file_put_contents($path, file_get_contents($path) . $type . '=' . $val . PHP_EOL);
                }
                file_put_contents($path, str_replace(
                    $type . '="' . env($type) . '"',
                    $type . '=' . $val,
                    file_get_contents($path)
                ));
            } else {
                file_put_contents($path, file_get_contents($path) . $type . '=' . $val . PHP_EOL);
            }
        }
    }

    /**
     * return service status text
     * example: Pending,Done/Completed,Processing by status
     */
    public static function serviceStatus($status)
    {
        // $serviceStatus = ['Pending', 'Processing', 'Approved', 'Cancel', 'Completed'];
        $serviceStatus =  ['غير خالص', 'بانتظار قبول الطلب', 'موافق عليه', 'إلغاء', 'خالص'];
        return $serviceStatus[$status];
    }

    public static function isSiteInstalled()
    {
        $canInstall = new canInstall();
        if ((env('APP_NAME') != null && env('APP_NAME') != '' && env('APP_NAME') != 'demo') || $canInstall->alreadyInstalled())
            return true;
        return false;
    }
    public static function isEmailConfigured()
    {
        // if (env('MAIL_MAILER') && env('MAIL_HOST') && env('MAIL_PASSWORD') && env('MAIL_USERNAME') && env('MAIL_PORT'))
        //     return true;
        return false;
    }

    public static function emptyToNull($val)
    {
        if ($val == null || $val == "")
            return null;
        else
            return $val;
    }
    public static function emptyOrNullToZero($val)
    {
        if ($val == null ||  $val == "")
            return 0;
        else
            return $val;
    }
}
