<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SlideSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        \App\Models\Slide::create([
            'name' => 'Slide 1',
            'description' => 'Description for Slide 1',
            'status' => 'active',
            'url' => 'https://example.com/slide1',
        ]);

        \App\Models\Slide::create([
            'name' => 'Slide 2',
            'description' => 'Description for Slide 2',
            'status' => 'inactive',
            'url' => 'https://example.com/slide2',
        ]);

        \App\Models\Slide::create([
            'name' => 'Slide 3',
            'description' => 'Description for Slide 3',
            'status' => 'active',
            'url' => 'https://example.com/slide3',
        ]);

        \App\Models\Slide::create([
            'name' => 'Slide 4',
            'description' => 'Description for Slide 4',
            'status' => 'inactive',
            'url' => 'https://example.com/slide4',
        ]);
    }
}
