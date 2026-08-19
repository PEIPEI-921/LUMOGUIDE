enum ErrorType {
  /// 请求超时
  timeout,

  /// 网络错误
  network,

  /// 客户端请求错误（400）
  badRequest,

  /// 未授权访问（401）
  unauthorized,

  /// 禁止访问（403）
  forbidden,

  /// 未找到资源（404）
  notFound,

  /// 服务器内部错误（500）
  internalServer,
}
