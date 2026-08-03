<?php

namespace Database\Seeders;

use App\Models\UserManagement\SecResource;
use App\Models\UserManagement\SecResourcePermission;
use App\Models\UserManagement\SecRolePermission;
use App\Models\UserManagement\SecRolePermissionInfo;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SecResourceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
    	$resourceList = [
    		1 => [ //1 => admin
    			[
					'resource' => [
						'name' => 'zone',
						'display_name' => 'Zones',
						'sec_resource_id' => 7, //Top Menu Settings
						'sec_module_id' => 1,
						'status' => 1,
						'serial' => 1,
						'level' => 2,
						'method' => 'zone',
						'icon' => null,
					],
					'routes' => [
						'zone.add',
						'zone.update',
						'zone.delete'
					]
				]
			],
//			3 => [  //3 => club manager
//
//			]
		];
    	
    	foreach ($resourceList as $role_id => $resources){
			foreach ($resources as $resourceData) {
				
				$resource = $resourceData['resource'];
				$routes = $resourceData['routes'];
				$secResource = SecResource::query()->updateOrCreate([
					'name' => $resource['name'],
					'sec_resource_id' => $resource['sec_resource_id'],
					'method' => $resource['method']
				], $resource);
			
				$resourcePermission = [
					'display_name' => $secResource->display_name,
					'sec_resource_id' => $secResource->id,
					'sec_role_id' => $role_id, // 1 => admin, 3 => club manager
					'status' => 1,
				];
			
				SecResourcePermission::query()->updateOrCreate([
					'display_name' => $resourcePermission['display_name'],
					'sec_resource_id' => $resourcePermission['sec_resource_id'],
					'sec_role_id' => $resourcePermission['sec_role_id']
				], $resourcePermission);
				
				foreach ($routes as $route){
					$permissionRoute = [
						'sec_resource_id' => $secResource->id,
						'permission_name' => $route,
						'route_name' => $route,
						'status' => 1,
						'created_by' => 1
					];
					$secRolePermissionInfo = SecRolePermissionInfo::query()->updateOrCreate([
						'route_name' => $permissionRoute['route_name']
					], $permissionRoute);
					
					SecRolePermission::query()->updateOrCreate([
						'sec_role_permission_info_id' => $secRolePermissionInfo->id,
						'sec_role_id' => $role_id,
						'created_by' => 1
					], [
						'status' => 1,
					]);
				}
			}
		}
    
    }
}
