abstract class ApiUrl {
  static const _isDev = false;
  static const baseUrl = _isDev
      ? 'https://dev.lumoguide.com/'
      : 'https://api.lumoguide.com/';

  static const apiUrl = '${baseUrl}api/';

  static const register = '/auth/register';

  static const login = '/auth/login';

  static const sendEmailCode = '/auth/sendCode';

  static const verifyCode = '/auth/verifyCode';

  static const sendPhoneCode = '/auth/sendSmsCode';

  static const resetPassword = '/auth/resetPassword';

  static const config = '/common/config';

  static const fileUpload = '/common/fileUpload';

  /// 获取地区
  static const getArea = '/common/getArea';

  /// 获取国家
  static const getCountry = '/common/getCountry';

  /// 获取推荐城市
  static const getLocation = '/common/location';

  /// 获取大洲
  static const getContinents = '/common/getContinents';

  /// 获取大洲（无推荐）
  static const getContinentsList = '/common/getContinentsList';

  /// 获取类型
  static const getType = '/common/getType';

  /// 获取类型分类
  static const typeClass = '/common/getTypeClass';

  /// 获取资讯分类
  static const informationClass = '/common/getInformationClass';

  /// 获取导游分类
  static const guideType = '/common/getGuideType';

  /// 获取城市列表
  static const cityList = '/city/lists';

  /// 系统大洲/国家/城市层级树（含城市→国家归属）
  static const systemContinents = '/common/systemContinents';

  static const cityOptions = '/city/options';

  /// 获取城市详情子分类
  static const cityClass = '/city/class';

  /// 获取城市详情
  static const cityInfo = '/city/info';

  /// 获取城市导游
  static const cityGuide = '/city/guide';

  /// 导游详情
  static const guideInfo = '/city/guideInfo';

  /// 预约导游
  static const reserveGuide = '/city/reserveGuide';

  /// 城市景点
  static const cityAttraction = '/city/attraction';

  /// 城市餐厅
  static const cityRestaurant = '/city/restaurant';

  /// 城市购物
  static const cityShopping = '/city/shopping';

  /// 城市住宿
  static const cityAccommodation = '/city/accommodation';

  /// 城市交通
  static const cityTransportation = '/city/transportation';

  /// 城市设施
  static const cityFacility = '/city/facility';

  /// 城市活动
  static const cityActivity = '/city/activity';

  /// 城市门票
  static const cityTicket = '/city/ticket';

  /// 分类内容详情
  static const cityContent = '/city/contentInfo';

  /// 分类内容评价
  static const contentEvaluate = '/city/contentEvaluate';

  /// 添加内容评价
  static const addContentEvaluate = '/city/addContentEvaluate';

  /// 添加内容预约
  static const addContentReserve = '/city/addContentReserve';

  /// 首页数据
  static const homeData = '/common/home';

  /// 用户信息
  static const userIndex = '/user/index';

  /// 根据number获取信息
  static const memberInfo = '/user/numberInfo';

  /// 编辑用户信息
  static const editUserInfo = '/user/editInfo';

  /// 删除用户
  static const deleteUser = '/user/delAccount';

  /// 绑定手机
  static const bindPhone = '/user/bindPhone';

  /// 联系我们
  static const contactUs = '/user/contactUs';

  /// 意见反馈
  static const feedback = '/user/feedback';

  /// 邀请记录
  static const inviteLog = '/user/inviteLog';

  /// 预约导游列表
  static const userReserveGuide = '/user/reserveGuide';

  /// 预约导游详情
  static const userReserveGuideInfo = '/user/reserveGuideInfo';

  /// 编辑预约导游
  static const userReserveGuideEdit = '/user/reserveGuideEdit';

  /// 取消预约导游
  static const userReserveGuideCancel = '/user/reserveGuideCancel';

  /// 删除预约导游
  static const userReserveGuideDelete = '/user/reserveGuideDel';

  /// 预约公司列表
  static const userReserveCompany = '/user/reserveCompany';

  /// 预约公司详情
  static const userReserveCompanyInfo = '/user/reserveCompanyInfo';

  /// 编辑预约公司
  static const userReserveCompanyEdit = '/user/reserveCompanyEdit';

  /// 取消预约公司
  static const userReserveCompanyCancel = '/user/reserveCompanyCancel';

  /// 删除预约公司
  static const userReserveCompanyDelete = '/user/reserveCompanyDel';

  /// 我的历程
  static const userJourneyList = '/user/journeyList';

  /// 地址列表
  static const addressLists = '/user/address';

  /// 添加地址
  static const addressAdd = '/user/addressAdd';

  /// 编辑地址
  static const addressEdit = '/user/addressEdit';

  /// 删除地址
  static const addressDelete = '/user/addressDelete';

  /// 申请导游
  static const applyGuide = '/user/applyGuide';

  /// 申请导游信息
  static const guideApplyInfo = '/user/applyGuideInfo';

  /// 申请公司
  static const applyCompany = '/user/applyCompany';

  /// 申请公司信息
  static const companyApplyInfo = '/user/applyCompanyInfo';

  /// 资讯列表
  static const informationLists = '/information/lists';

  /// 资讯详情
  static const informationInfo = '/information/info';

  /// 资讯评价
  static const informationEvaluate = '/information/evaluate';

  /// 添加资讯评价
  static const addInformationEvaluate = '/information/addEvaluate';

  /// 导游切换城市
  static const guideChangeCity = '/guide/changeCity';

  /// 导游发布城市
  static const guidePublishCity = '/guide/publishCity';

  /// 导游城市列表
  static const guideCityList = '/guide/cityList';

  /// 导游城市信息
  static const guideCityInfo = '/guide/city';

  /// 导游编辑城市
  static const guideEditCity = '/guide/editCity';

  /// 导游删除城市
  static const guideDelCity = '/guide/delCity';

  /// 导游景点列表
  static const guideAttraction = '/guide/attraction';

  /// 导游添加景点
  static const guideAttractionAdd = '/guide/attractionAdd';

  /// 导游景点详情
  static const guideAttractionInfo = '/guide/attractionInfo';

  /// 导游编辑景点
  static const guideAttractionEdit = '/guide/attractionEdit';

  /// 导游删除景点
  static const guideAttractionDel = '/guide/attractionDel';

  /// 导游交通列表
  static const guideTransportation = '/guide/transportation';

  /// 导游添加交通
  static const guideTransportationAdd = '/guide/transportationAdd';

  /// 导游交通详情
  static const guideTransportationInfo = '/guide/transportationInfo';

  /// 导游编辑交通
  static const guideTransportationEdit = '/guide/transportationEdit';

  /// 导游删除交通
  static const guideTransportationDel = '/guide/transportationDel';

  /// 导游设施列表
  static const guideFacility = '/guide/facility';

  /// 导游添加设施
  static const guideFacilityAdd = '/guide/facilityAdd';

  /// 导游设施详情
  static const guideFacilityInfo = '/guide/facilityInfo';

  /// 导游编辑设施
  static const guideFacilityEdit = '/guide/facilityEdit';

  /// 导游删除设施
  static const guideFacilityDel = '/guide/facilityDel';

  /// 导游活动列表
  static const guideActivity = '/guide/activity';

  /// 导游添加活动
  static const guideActivityAdd = '/guide/activityAdd';

  /// 导游活动详情
  static const guideActivityInfo = '/guide/activityInfo';

  /// 导游编辑活动
  static const guideActivityEdit = '/guide/activityEdit';

  /// 导游删除活动
  static const guideActivityDel = '/guide/activityDel';

  /// 导游资讯列表
  static const guideInformation = '/guide/information';

  /// 导游添加资讯
  static const guideInformationAdd = '/guide/informationAdd';

  /// 导游资讯详情
  static const guideInformationInfo = '/guide/informationInfo';

  /// 导游编辑资讯
  static const guideInformationEdit = '/guide/informationEdit';

  /// 导游删除资讯
  static const guideInformationDel = '/guide/informationDel';

  /// 导游预约列表
  static const guideReserve = '/guide/reserve';

  /// 导游预约详情
  static const guideReserveInfo = '/guide/reserveInfo';

  /// 导游确认预约
  static const guideConfirmReserve = '/guide/confirmReserve';

  /// 导游拒绝预约
  static const guideRejectReserve = '/guide/rejectReserve';

  /// 导游删除预约
  static const guideDeleteReserve = '/guide/delReserve';

  /// 公司商店列表
  static const companyShop = '/company/shop';

  /// 公司添加商店
  static const companyShopAdd = '/company/shopAdd';

  /// 公司商店详情
  static const companyShopInfo = '/company/shopInfo';

  /// 公司编辑商店
  static const companyShopEdit = '/company/shopEdit';

  /// 公司删除商店
  static const companyShopDel = '/company/shopDel';

  /// 公司预约列表
  static const companyReserve = '/company/reserve';

  /// 公司预约详情
  static const companyReserveInfo = '/company/reserveInfo';

  /// 公司确认预约
  static const companyConfirmReserve = '/company/confirmReserve';

  /// 用户积分详情
  static const integralUserDetails = '/integral/userDetails';

  /// 积分商品分类列表
  static const integralGoodsClass = '/integral/goodsClass';

  /// 积分商品列表
  static const integralGoods = '/integral/goods';

  /// 积分商品详情
  static const integralGoodsInfo = '/integral/goodsInfo';

  /// 积分兑换
  static const integralExchange = '/integral/exchange';

  /// 积分兑换订单列表
  static const integralExchangeOrders = '/integral/exchangeOrders';

  /// 积分兑换订单详情
  static const integralExchangeOrderInfo = '/integral/exchangeOrderInfo';

  /// 商家确认预约
  static const merchantConfirmReserve = '/company/confirmReserve';

  /// 商家拒绝预约
  static const merchantRejectReserve = '/company/rejectReserve';

  /// 商家删除预约
  static const merchantDeleteReserve = '/company/delReserve';

  /// 会员能力
  static const vipAbility = '/vip/ability';

  /// 会员导游
  static const vipGuide = '/vip/guide';

  /// 会员公司
  static const vipCompany = '/vip/company';

  /// 会员订阅导游
  static const vipSubscribeGuide = '/vip/subscriptionGuide';

  /// 会员订阅公司
  static const vipSubscribeCompany = '/vip/subscriptionCompany';

  /// 会员支付状态
  static const vipPayStatus = '/vip/payStatus';

  /// 关注导游
  static const followGuide = '/city/guideFollow';

  /// 取消关注导游
  static const unfollowGuide = '/city/guideUnFollow';

  /// 关注/取消关注公司
  static const followCompany = '/city/companyFollow';

  static const followShop = '/city/shopFollow';

  static const unfollowShop = '/message/unFollowShop';

  /// 消息列表
  static const messageList = '/message/lists';

  /// 我的评价
  static const messageMyEvaluate = '/message/myEvaluate';

  /// 评价我的
  static const messageEvaluateMe = '/message/evaluateMy';

  /// 关注分类
  static const followClass = '/message/followClass';

  /// 我的关注
  static const messageMyFollow = '/message/myFollow';

  /// 关注我的
  static const messageFollowMe = '/message/followMy';

  /// 关注我的店铺
  static const messageFollowMyShop = '/message/followMyShop';

  /// 系统消息
  static const messageSystem = '/message/system';

  /// 關注/取關
  static const messageFollow = '/message/follow';

  /// 公司详情
  static const companyInfo = '/company/info';

  /// 首页搜索
  static const homeSearch = '/common/homeSearch';

  /// 搜索
  static const search = '/common/search';

  /// 每日记录
  static const userRecord = '/user/loginRecord';
}
