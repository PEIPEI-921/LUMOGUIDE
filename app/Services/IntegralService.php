<?php

namespace App\Services;

use App\Enums\Integral;
use App\Enums\System;
use App\Exceptions\ApiException;
use App\Models\IntegralGoods;
use App\Models\IntegralGoodsClass;
use App\Models\User;
use App\Models\UserAddress;
use App\Models\UserIntegralLog;
use App\Models\UserIntegralOrder;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Throwable;

class IntegralService
{

    /**
     * 用户积分明细
     * @param int $limit
     * @return array
     */
    public function userDetails(int $limit)
    {
        $user_id = auth('api')->id();

        $data = UserIntegralLog::query()->where('user_id', $user_id)->orderBy('created_at', 'desc')->paginate($limit, ['id', 'type', 'title', 'amount', 'created_at'])->toArray();
        return ['total' => $data['total'], 'list' => $data['data']];
    }


    /**
     * 积分商品分类
     * @return array
     */
    public function goodsClassLists()
    {
        $class = IntegralGoodsClass::query()->orderBy('order', 'asc')->select(['id', 'name'])->get()->toArray();
        array_unshift($class, ['id' => 0, 'name' => '推荐']);

        $data = [];
        foreach ($class as $k => $v) {
            if ($v['id'] == 0) {
                $count = IntegralGoods::query()->where('recommend', 1)->count();
            } else {
                $count = IntegralGoods::query()->where('class_id', $v['id'])->count();
            }
            if ($count > 0) {
                $data[] = $v;
            }
        }
        return $data;
    }


    /**
     * 积分商品列表
     * @param int $limit
     * @param int $class_id
     * @return array
     */
    public function goodsLists(int $limit, int $class_id)
    {
        if ($class_id == 0) {
            $where['recommend'] = 1;
        } else {
            $where['class_id'] = $class_id;
        }

        $data = IntegralGoods::query()->where($where)
            ->where('stock', '>', 0)
            ->where('status', 1)
            ->orderBy('order', 'desc')->paginate($limit, ['id', 'picture', 'name', 'price'])->toArray();
        return ['total' => $data['total'], 'list' => $data['data']];
    }


    /**
     * 积分商品详情
     * @param int $goods_id
     * @return array
     * @throws ApiException
     */
    public function goodsInfo(int $goods_id)
    {
        $goods = IntegralGoods::find($goods_id);
        if (!$goods) {
            throw new ApiException(__('res.data_not'));
        }

        return [
            'id' => $goods->id,
            'picture' => $goods->picture,
            'pictures' => json_decode($goods->pictures, true),
            'name' => $goods->name,
            'goods_type' => $goods->goods_type,
            'price' => $goods->price,
            'free_shipping' => Integral::FreeShipping[$goods->free_shipping],
            'sales' => $goods->sales,
            'content' => $goods->content
        ];
    }


    /**
     * 积分兑换
     * @param array $data
     * @return array
     * @throws ApiException
     */
    public function exchange(array $data)
    {
        $user_id = auth('api')->id();
        $user = User::find($user_id);
        handleUserVip($user);

        $goods_id = $data['goods_id'];
        $address_id = $data['address_id'] ?? 0;

        $goods = IntegralGoods::query()->where('id', $goods_id)
            ->where('stock', '>', 0)
            ->where('status', 1)
            ->first();
        if (!$goods) {
            throw new ApiException(__('res.data_not'));
        }
        if ($user->integral < $goods->price) {
            throw new ApiException(__('res.integral_not_enough'));
        }
        if ($goods->goods_type == 1) {
            $address = UserAddress::find($address_id);
            if (!$address) {
                throw new ApiException(__('res.address_not'));
            }
        }

        DB::beginTransaction();
        try {
            // 减少库存 库存等于0 自动下架
            $goods_stock = $goods->stock - 1;
            if ($goods_stock < 0) {
                $goods_stock = 0;
            }
            $goods->stock = $goods_stock;
            if ($goods_stock == 0) {
                $goods->status = 0;
            }
            $goods->save();

            // 记录积分订单
            $orderModel = new UserIntegralOrder();
            $orderModel->order_sn = createOrderSn('I');
            $orderModel->user_id = $user_id;
            $orderModel->user_address_id = $address_id;
            $orderModel->integral_goods_id = $goods_id;
            $orderModel->integral_goods_info = json_encode([
                'id' => $goods->id,
                'name' => $goods->name,
                'price' => $goods->price,
                'picture' => $goods->picture,
                'goods_type' => $goods->goods_type,
            ]);
            $orderModel->price = $goods->price;
            $orderModel->free_shipping = $goods->free_shipping;
            $orderModel->pay_time = now();
            $orderModel->status = Integral::StatusOne;
            $orderModel->save();

            // 积分日志
            $logModel = new UserIntegralLog();
            $logModel->user_id = $user_id;
            $logModel->type = Integral::LogTypeOne;
            $logModel->title = '兑换商品扣除积分';
            $logModel->before = $user->integral;
            $logModel->amount = $goods->price;
            $logModel->after = $user->integral - $goods->price;
            $logModel->save();

            // 扣除用户积分
            $user->integral = $logModel->after;
            $user->save();

            DB::commit();
            return ['id' => $orderModel->id, 'order_sn' => $orderModel->order_sn, 'pay_time' => $orderModel->created_at->format('Y-m-d H:i:s'), 'create_time' => $orderModel->created_at->format('Y-m-d H:i:s')];
        } catch (Throwable $e) {
            DB::rollBack();
            throw new ApiException(__('res.system_error'), System::SYSTEM_ERROR);
        }
    }


    /**
     * 兑换积分订单
     * @param $limit
     * @return array
     */
    public function exchangeOrders($limit)
    {
        $user_id = auth('api')->id();
        $data = UserIntegralOrder::query()->where('user_id', $user_id)->orderBy('id', 'desc')->paginate($limit, ['id', 'created_at', 'integral_goods_info', 'price'])->toArray();
        $res = [];
        foreach ($data['data'] as $k => $v) {
            $goods_info = json_decode($v['integral_goods_info'], true);
            $res[] = [
                'id' => $v['id'],
                'created_at' => $v['created_at'],
                'goods_picture' => $goods_info['picture'],
                'goods_name' => $goods_info['name'],
                'price' => $v['price'],
            ];
        }
        return ['total' => $data['total'], 'list' => $res];
    }


    /**
     * 兑换订单详情
     * @param int $id
     * @return array
     * @throws ApiException
     */
    public function exchangeOrderInfo(int $id)
    {
        $user_id = auth('api')->id();
        $order = UserIntegralOrder::query()->where('user_id', $user_id)->where('id', $id)->first();
        if (!$order) {
            throw new ApiException(__('res.data_not'));
        }

        $address = UserAddress::query()->where('id', $order->user_address_id)->first(['name', 'phone', 'address', 'post_code', 'default']);

        return [
            'address' => $address->toArray(),
            'status_str' => Integral::OrderStatus[$order->status],
            'goods_info' => json_decode($order->integral_goods_info, true),
            'price' => $order->price,
            'free_shipping' => $order->free_shipping == 1 ? '0' : '',
            'order_sn' => $order->order_sn,
            'created_at' => Carbon::parse($order->created_at)->format('Y-m-d H:i:s'),
            'pay_time' => $order->pay_time,
            'express_delivery_company' => $order->express_delivery_company,
            'express_delivery_number' => $order->express_delivery_number
        ];
    }

}
