<?php

namespace App\Http\Controllers\Website;

use App\Http\Controllers\Controller;
use App\Http\Repository\UtilityRepository;
use App\Models\Website\SiteFrequentlyAskedQuestion;
use ErrorException;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class FrequentlyAskedQuestionController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function frequentlyAskedQuestion()
    {
        return view('website.frequently-asked-question');
    }

    public function saveFrequentlyAskedQuestion(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'question' => ['required', 'string', 'max:200'],
                'answer' => ['required', 'string', 'max:1000']
            ]);

            $data = $request->toArray();
            if (!$validator->fails()) {
                $data['id']=null;
                $data['created_by'] = Auth::id();
                $data['order'] =UtilityRepository::emptyOrNullToZero($data['order']);
                SiteFrequentlyAskedQuestion::create($data);
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function updateFrequentlyAskedQuestion(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'question' => ['required', 'string', 'max:200'],
                'answer' => ['required', 'string', 'max:1000']
            ]);

            $data = $request->toArray();
           
            if (!$validator->fails()) {
                $savedData = SiteFrequentlyAskedQuestion::where('id', $request->id)->first();
                if ($savedData != null) {
                    $data['updated_by'] = Auth::id();
                    $data['status'] = $data['status'] ?? 0;
                    $data['order'] = UtilityRepository::emptyOrNullToZero($data['order']);
                    $savedData->update($data);
                    return $this->apiResponse(['status' => '1', 'data' => ''], 200);
                }
            }
            return $this->apiResponse(['status' => '500', 'data' => $validator->errors()], 400);
        } catch (ErrorException $ex) {
            return  $this->apiResponse(['status' => '-501', 'data' => $ex->getMessage()], 400);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function deleteFrequentlyAskedQuestion(Request $request)
    {
        try {
            $savedData = SiteFrequentlyAskedQuestion::where('id', $request->id)->first();
            if ($savedData != null) {
                $savedData->delete();
                return $this->apiResponse(['status' => '1', 'data' => ''], 200);
            }
            return $this->apiResponse(['status' => '0', 'data' => ''], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '501', 'data' => $qx], 400);
        }
    }

    public function getFrequentlyAskedQuestion()
    {
        try {
            $data = SiteFrequentlyAskedQuestion::select(
                'id',
                'question',
                'answer',
                'order',
                'status'
            )->get();
            return $this->apiResponse(['status' => '1', 'data' => $data], 200);
        } catch (Exception $qx) {
            return $this->apiResponse(['status' => '403', 'data' => $qx], 400);
        }
    }
}
