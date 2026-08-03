<?php

namespace Database\Seeders;


use App\Models\Settings\CmnTranslation;
use Illuminate\Database\Seeder;

class TranslateSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
		$translations = [
			[
				'cmn_language_id' => 3, //3 => ar
				'lang_key' => 'Zone',
				'lang_value' => 'المنطقه'
			],
			[
				'cmn_language_id' => 3, //3 => ar
				'lang_key' => 'Zones',
				'lang_value' => 'المناطق'
			]
		];
	
		foreach ($translations as $translation) {
			CmnTranslation::query()->updateOrCreate([
				'cmn_language_id' => $translation['cmn_language_id'],
				'lang_key'  => $translation['lang_key'],
			], $translation);
		}
    
    }
}
