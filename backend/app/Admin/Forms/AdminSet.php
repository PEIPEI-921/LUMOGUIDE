<?php

namespace App\Admin\Forms;

use App\Models\City;
use App\Models\User;
use App\Models\UserIntegralLog;
use App\Models\VipCompany;
use Dcat\Admin\Contracts\LazyRenderable;
use Dcat\Admin\Traits\LazyWidget;
use Dcat\Admin\Widgets\Form;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminSet extends Form implements LazyRenderable
{
    use LazyWidget;

    /**
     * Handle the form request.
     *
     * @param array $input
     *
     * @return mixed
     */
    public function handle(array $input)
    {
        $user_id = $input['user_id'];

        $admin_user = DB::table('admin_users')->where('user_id', $user_id)->first();
        if (!$admin_user) {
            if (DB::table('admin_users')->where('username', $input['manage_account'])->exists()) {
                return $this->response()->error('账号已存在');
            }
        }

        DB::beginTransaction();
        try {
            if (!$admin_user) {
                $user_nickname = User::find($user_id)->nickname;

                $admin_user_id = DB::table('admin_users')->insertGetId([
                    'username' => $input['manage_account'],
                    'password' => Hash::make($input['manage_password']),
                    'name' => $user_nickname ?? $input['manage_account'],
                    'city_id' => $input['manage_city_id'],
                    'user_id' => $user_id,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                DB::table('admin_role_users')->insertGetId([
                    'role_id' => 2,
                    'user_id' => $admin_user_id,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            } else {
                if ($input['manage_password']) {
                    $arr['password'] = Hash::make($input['manage_password']);
                }
                $arr['city_id'] = $input['manage_city_id'];
                DB::table('admin_users')->where('id', $admin_user->id)->update($arr);
            }
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->response()->error($e->getMessage());
        }

        return $this->response()->success('设置成功')->refresh();
    }

    /**
     * Build a form here.
     */
    public function form()
    {
        $this->hidden('user_id');

        $user_id = $this->payload['key'];
        $admin_user = DB::table('admin_users')->where('user_id', $user_id)->first();

        if ($admin_user) {
            $this->select('manage_city_id', '管理城市')->value($admin_user->city_id)->options(City::admin_options())->required();
            $this->display('manage_account', '賬號')->value($admin_user->username);
            $this->text('manage_password', '密碼');
        } else {
            $this->select('manage_city_id', '管理城市')->options(City::admin_options())->required();
            $this->text('manage_account', '賬號')->required();
            $this->text('manage_password', '密碼')->required();
        }
    }

    /**
     * The data of the form.
     *
     * @return array
     */
    public function default()
    {
        return [
            'user_id' => $this->payload['key'],
        ];
    }
}
