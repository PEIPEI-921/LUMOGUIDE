-- ============================================================
-- LuMo Guide (路盟) Database Schema
-- Source: production mysqldump (MySQL 5.7)
-- Generated: 2026-07-21
-- Tables: 56
-- ============================================================
-- Usage:
--   mysql -u root -p < schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS `lumo_guide`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `lumo_guide`;

-- ============================================================
-- Table: admin_extension_histories
-- ============================================================
CREATE TABLE `admin_extension_histories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '1',
  `version` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `detail` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `admin_extension_histories_name_index` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: admin_extensions
-- ============================================================
CREATE TABLE `admin_extensions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `version` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `is_enabled` tinyint(4) NOT NULL DEFAULT '0',
  `options` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `admin_extensions_name_unique` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: admin_menu
-- ============================================================
CREATE TABLE `admin_menu` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) NOT NULL DEFAULT '0',
  `order` int(11) NOT NULL DEFAULT '0',
  `title` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uri` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `extension` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `show` tinyint(4) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: admin_permission_menu
-- ============================================================
CREATE TABLE `admin_permission_menu` (
  `permission_id` bigint(20) NOT NULL,
  `menu_id` bigint(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `admin_permission_menu_permission_id_menu_id_unique` (`permission_id`,`menu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: admin_permissions
-- ============================================================
CREATE TABLE `admin_permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `http_method` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `http_path` text COLLATE utf8mb4_unicode_ci,
  `order` int(11) NOT NULL DEFAULT '0',
  `parent_id` bigint(20) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `admin_permissions_slug_unique` (`slug`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: admin_role_menu
-- ============================================================
CREATE TABLE `admin_role_menu` (
  `role_id` bigint(20) NOT NULL,
  `menu_id` bigint(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `admin_role_menu_role_id_menu_id_unique` (`role_id`,`menu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: admin_role_permissions
-- ============================================================
CREATE TABLE `admin_role_permissions` (
  `role_id` bigint(20) NOT NULL,
  `permission_id` bigint(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `admin_role_permissions_role_id_permission_id_unique` (`role_id`,`permission_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: admin_role_users
-- ============================================================
CREATE TABLE `admin_role_users` (
  `role_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `admin_role_users_role_id_user_id_unique` (`role_id`,`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: admin_roles
-- ============================================================
CREATE TABLE `admin_roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `admin_roles_slug_unique` (`slug`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table: admin_settings
-- ============================================================
CREATE TABLE `admin_settings` (
  `slug` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`slug`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: admin_users
-- ============================================================
CREATE TABLE `admin_users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int(10) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `city_id` int(10) NOT NULL DEFAULT '0' COMMENT '城市ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `admin_users_username_unique` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: city
-- ============================================================
CREATE TABLE `city` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市名称',
  `name_en` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市名称英文',
  `continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属大洲ID',
  `area_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属地区ID',
  `country_id` int(11) NOT NULL DEFAULT '0' COMMENT '国家ID',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经纬度',
  `longitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经度',
  `latitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纬度',
  `is_capital` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否首都',
  `currency` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '货币',
  `language` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '官方语言',
  `population` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '人口数量',
  `race` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '种族',
  `overview` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '概览',
  `history` text COLLATE utf8mb4_unicode_ci COMMENT '历史',
  `first_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '首张封面',
  `pictures` json DEFAULT NULL COMMENT '封面',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核驳回原因',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `home_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '首页推荐',
  `default_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '默认推荐',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT '排序',
  `is_finish` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否完成',
  `is_read` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否已读',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: city_content
-- ============================================================
CREATE TABLE `city_content` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '城市ID',
  `continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属大洲ID',
  `area_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属地区ID',
  `type_id` tinyint(4) NOT NULL DEFAULT '0' COMMENT '类型',
  `type_class_id` int(11) NOT NULL DEFAULT '0' COMMENT '分类ID',
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `publisher_id` int(11) NOT NULL DEFAULT '0' COMMENT '发布人ID',
  `publisher_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '发布人类型',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称/标题',
  `start_time` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开放时间/营业时间',
  `end_time` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '结束时间',
  `tickets_free` tinyint(1) NOT NULL DEFAULT '0' COMMENT '门票免费',
  `capacity` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '餐厅容纳人数',
  `order_food` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否接受团餐预订',
  `price` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '价格',
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '电话',
  `other_phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '网址',
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '地址',
  `longitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经度',
  `latitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纬度',
  `how_arrive` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '如何到达',
  `introduce` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '相关介绍',
  `first_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片',
  `pictures` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片组',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核反馈',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `banner_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '轮播推荐',
  `home_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '首页推荐',
  `recommend_time` int(11) NOT NULL DEFAULT '0' COMMENT '推荐过期时间',
  `banner_recommend_time` int(11) NOT NULL DEFAULT '0' COMMENT '轮播推荐过期时间',
  `home_recommend_time` int(11) NOT NULL DEFAULT '0' COMMENT '首页推荐过期时间',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT '排序',
  `is_finish` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否完成',
  `is_read` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否已读',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: city_content_edit
-- ============================================================
CREATE TABLE `city_content_edit` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `city_content_id` int(11) NOT NULL DEFAULT '0' COMMENT '城市内容ID',
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '城市ID',
  `type_id` tinyint(4) NOT NULL DEFAULT '0' COMMENT '类型',
  `type_class_id` int(11) NOT NULL DEFAULT '0' COMMENT '分类ID',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称/标题',
  `start_time` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开放时间/营业时间',
  `end_time` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '结束时间',
  `tickets_free` tinyint(1) NOT NULL DEFAULT '0' COMMENT '门票免费',
  `capacity` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '餐厅容纳人数',
  `order_food` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否接受团餐预订',
  `price` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '价格',
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '电话',
  `other_phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '网址',
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '地址',
  `longitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经度',
  `latitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纬度',
  `how_arrive` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '如何到达',
  `introduce` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '相关介绍',
  `first_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片',
  `pictures` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片组',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核反馈',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: city_edit
-- ============================================================
CREATE TABLE `city_edit` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `city_id` bigint(20) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市名称',
  `name_en` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市名称英文',
  `continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属大洲ID',
  `area_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属地区ID',
  `country_id` int(11) NOT NULL DEFAULT '0' COMMENT '国家ID',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经纬度',
  `longitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经度',
  `latitude` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '纬度',
  `is_capital` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否首都',
  `currency` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '货币',
  `language` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '官方语言',
  `population` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '人口数量',
  `race` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '种族',
  `overview` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '概览',
  `history` text COLLATE utf8mb4_unicode_ci COMMENT '历史',
  `first_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '首张封面',
  `pictures` json DEFAULT NULL COMMENT '封面',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核驳回原因',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `home_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '首页推荐',
  `default_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '默认推荐',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT '排序',
  `is_finish` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否完成',
  `is_read` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否已读',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: city_type
-- ============================================================
CREATE TABLE `city_type` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ICON',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `key` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'key',
  `order` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: city_type_class
-- ============================================================
CREATE TABLE `city_type_class` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type_id` tinyint(4) NOT NULL DEFAULT '0' COMMENT '类型',
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `order` int(11) NOT NULL DEFAULT '0' COMMENT '排序',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: company
-- ============================================================
CREATE TABLE `company` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公司名称',
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '英文',
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '所在城市',
  `city_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所在城市',
  `address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公司地址',
  `tax_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公司税号',
  `business_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '经营类型',
  `introduction` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '简介',
  `email` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email',
  `phone` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `website` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '公司网址',
  `other_contact` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `wechat` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信',
  `whats_app` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'WhatsApp',
  `line` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'LINE',
  `documents_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '证件图片',
  `picture` json DEFAULT NULL COMMENT '商家图片',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核驳回原因',
  `audit_time` timestamp NULL DEFAULT NULL COMMENT '审核完成时间',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `is_finish` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否完成',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: company_edit
-- ============================================================
CREATE TABLE `company_edit` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL DEFAULT '0' COMMENT '企业ID',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公司名称',
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '英文',
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '所在城市',
  `city_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所在城市',
  `address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公司地址',
  `tax_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公司税号',
  `business_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '经营类型',
  `introduction` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '简介',
  `email` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email',
  `phone` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `website` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '公司网址',
  `other_contact` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `wechat` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信',
  `whats_app` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'WhatsApp',
  `line` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'LINE',
  `documents_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '证件图片',
  `picture` json DEFAULT NULL COMMENT '商家图片',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核驳回原因',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: content_evaluate
-- ============================================================
CREATE TABLE `content_evaluate` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '发布用户ID',
  `user_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '发布用户类型',
  `content_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '内容详情 1城市/2资讯',
  `content_id` int(11) NOT NULL DEFAULT '0' COMMENT '内容ID',
  `content_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content_user_id` int(11) NOT NULL DEFAULT '0' COMMENT '内容发布用户ID',
  `content` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `pictures` json DEFAULT NULL COMMENT '图片',
  `star` tinyint(1) NOT NULL DEFAULT '0' COMMENT '星',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: failed_jobs
-- ============================================================
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: guide_edit
-- ============================================================
CREATE TABLE `guide_edit` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '照片/LOGO',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '英文',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '联系电话',
  `email` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱地址',
  `bill_address` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账单地址',
  `other_contact` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `wechat` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信',
  `whats_app` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'WhatsApp',
  `line` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'LINE',
  `language` json DEFAULT NULL COMMENT '语言',
  `year` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '从业年份',
  `industry_type` json DEFAULT NULL COMMENT '从事旅游行业类型',
  `identity_type` int(11) NOT NULL DEFAULT '0' COMMENT '展示身份类型',
  `other_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他类型',
  `introduction` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '简介',
  `business_contact` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '从业联系人',
  `have_vehicle` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否有车',
  `vehicle_info` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '车辆信息',
  `vehicle_rent` tinyint(1) NOT NULL DEFAULT '0' COMMENT '车辆是否出租',
  `certificate_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '资格证书图片',
  `passport_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '护照证件图片',
  `driver_license_front` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '驾照正面',
  `driver_license_back` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '驾照背面',
  `car_pictures` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '车辆照片',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核驳回原因',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: guide_type
-- ============================================================
CREATE TABLE `guide_type` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `order` int(11) NOT NULL DEFAULT '0' COMMENT '排序',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: guides
-- ============================================================
CREATE TABLE `guides` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '城市ID',
  `continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属大洲ID',
  `area_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属地区ID',
  `city_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '城市名称',
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '照片/LOGO',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '真实姓名',
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '英文',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '联系电话',
  `email` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱地址',
  `bill_address` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账单地址',
  `other_contact` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `wechat` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信',
  `whats_app` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'WhatsApp',
  `line` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'LINE',
  `language` json DEFAULT NULL COMMENT '语言',
  `year` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '从业年份',
  `industry_type` json DEFAULT NULL COMMENT '从事旅游行业类型',
  `identity_type` int(11) NOT NULL DEFAULT '0' COMMENT '展示身份类型',
  `other_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他类型',
  `introduction` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '简介',
  `business_contact` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '从业联系人',
  `have_vehicle` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否有车',
  `vehicle_info` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '车辆信息',
  `vehicle_rent` tinyint(1) NOT NULL DEFAULT '0' COMMENT '车辆是否出租',
  `certificate_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '资格证书图片',
  `passport_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '护照证件图片',
  `driver_license_front` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '驾照正面',
  `driver_license_back` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '驾照背面',
  `car_pictures` json DEFAULT NULL COMMENT '车辆照片',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核驳回原因',
  `audit_time` timestamp NULL DEFAULT NULL COMMENT '审核完成时间',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `home_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '首页推荐',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT '排序',
  `is_finish` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否完成',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: information
-- ============================================================
CREATE TABLE `information` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `guide_type_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游身份ID',
  `class_id` int(11) NOT NULL DEFAULT '0' COMMENT '分类ID',
  `title` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `desc` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '简介',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `first_picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '首图',
  `pictures` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片',
  `look` tinyint(1) NOT NULL DEFAULT '1' COMMENT '仅谁可看',
  `view` int(11) NOT NULL DEFAULT '0' COMMENT '浏览量',
  `audit_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '审核状态',
  `audit_feedback` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '审核驳回原因',
  `top` tinyint(1) NOT NULL DEFAULT '0' COMMENT '置顶',
  `top_order` int(5) NOT NULL DEFAULT '0' COMMENT '置顶排序',
  `home_recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '首页推荐',
  `is_finish` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: information_class
-- ============================================================
CREATE TABLE `information_class` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `order` int(11) NOT NULL DEFAULT '0' COMMENT '排序',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: information_evaluate
-- ============================================================
CREATE TABLE `information_evaluate` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `user_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户类型',
  `information_id` int(11) NOT NULL DEFAULT '0' COMMENT '资讯ID',
  `information_user_id` int(11) NOT NULL COMMENT '发布资讯用户ID',
  `content` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `pictures` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片',
  `star` tinyint(1) NOT NULL DEFAULT '0' COMMENT '星',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: integral_goods
-- ============================================================
CREATE TABLE `integral_goods` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int(11) NOT NULL DEFAULT '0' COMMENT '分类ID',
  `picture` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片',
  `pictures` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图片组',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `goods_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '类型',
  `price` int(11) NOT NULL DEFAULT '0' COMMENT '积分金额',
  `free_shipping` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否包邮',
  `sales` int(11) NOT NULL DEFAULT '0' COMMENT '销量',
  `content` text COLLATE utf8mb4_unicode_ci COMMENT '商品详情',
  `recommend` tinyint(1) NOT NULL DEFAULT '0' COMMENT '推荐',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT '排序',
  `stock` int(11) NOT NULL DEFAULT '0' COMMENT '库存',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: integral_goods_class
-- ============================================================
CREATE TABLE `integral_goods_class` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `order` int(11) NOT NULL DEFAULT '0' COMMENT '排序',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: migrations
-- ============================================================
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: password_resets
-- ============================================================
CREATE TABLE `password_resets` (
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: personal_access_tokens
-- ============================================================
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`) USING BTREE,
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: reserve_guide
-- ============================================================
CREATE TABLE `reserve_guide` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '预约城市ID',
  `arrival_time` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '到达时间',
  `number` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '人数',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `contact` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系人',
  `email` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '电话',
  `other` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '预约状态',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `is_read` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否已读',
  `user_del` tinyint(1) NOT NULL DEFAULT '0' COMMENT '预约人删除',
  `guide_del` tinyint(1) NOT NULL DEFAULT '0' COMMENT '被预约人删除',
  `trip_id` int(11) NOT NULL DEFAULT '0' COMMENT '行程ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: reserves
-- ============================================================
CREATE TABLE `reserves` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `company_id` int(11) NOT NULL DEFAULT '0' COMMENT '企业ID',
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '预约城市ID',
  `content_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '预约内容类型',
  `content_id` int(11) NOT NULL DEFAULT '0' COMMENT '预约内容ID',
  `tickets_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '门票类型',
  `arrival_time` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '到达时间',
  `leave_time` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '离开时间',
  `number` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '人数',
  `room_number` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '房间数',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `file` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '购物客户名单',
  `contact` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系人',
  `email` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '电话',
  `other` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他联系方式',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '预约状态',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '拒绝原因',
  `is_read` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否已读',
  `user_del` tinyint(1) NOT NULL DEFAULT '0' COMMENT '预约人删除',
  `company_del` tinyint(1) NOT NULL DEFAULT '0' COMMENT '被预约人删除',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_area
-- ============================================================
CREATE TABLE `system_area` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `order` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_config
-- ============================================================
CREATE TABLE `system_config` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '类型',
  `mark` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置标识',
  `value` longtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置内容',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_contact_us
-- ============================================================
CREATE TABLE `system_contact_us` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `title` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `email` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱',
  `content` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_continents
-- ============================================================
CREATE TABLE `system_continents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `order` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_country
-- ============================================================
CREATE TABLE `system_country` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `order` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_feedback
-- ============================================================
CREATE TABLE `system_feedback` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `title` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `content` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `pictures` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '上传图片',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_integral_config
-- ============================================================
CREATE TABLE `system_integral_config` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mark` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` int(10) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_message
-- ============================================================
CREATE TABLE `system_message` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `title` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `desc` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '描述',
  `content` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `is_read` tinyint(1) NOT NULL DEFAULT '0' COMMENT '读取状态',
  `content_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '内容类型',
  `city_id` int(10) NOT NULL DEFAULT '0' COMMENT '城市ID',
  `content_id` int(10) NOT NULL DEFAULT '0' COMMENT '内容ID',
  `city_content_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '城市ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=301 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: system_notify
-- ============================================================
CREATE TABLE `system_notify` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型',
  `title` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '接受用户ID',
  `content_id` int(11) NOT NULL COMMENT '内容ID',
  `is_read` tinyint(1) NOT NULL DEFAULT '0' COMMENT '读取状态',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: trip_days
-- ============================================================
CREATE TABLE `trip_days` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `trip_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '行程表',
  `day_index` tinyint(4) NOT NULL DEFAULT '1' COMMENT '第几天',
  `date` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '具体日期',
  `city_id` int(11) NOT NULL DEFAULT '0' COMMENT '城市ID',
  `city_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '城市名称',
  `continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属大洲ID',
  `area_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属地区ID',
  `items` json DEFAULT NULL COMMENT '日程',
  `activity` json DEFAULT NULL COMMENT '活动提醒',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: trips
-- ============================================================
CREATE TABLE `trips` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `start_time` timestamp NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` timestamp NULL DEFAULT NULL COMMENT '结束时间',
  `member_count` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '参与人数',
  `start_city_id` int(11) NOT NULL DEFAULT '0' COMMENT '出发城市',
  `arrival_transport_type` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '出发到达方式',
  `arrival_time` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '到达时间',
  `arrival_place` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '到达地点',
  `start_desc` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '出发相关描述',
  `end_city_id` int(11) NOT NULL DEFAULT '0' COMMENT '结束城市',
  `leave_transport_type` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '离开方式',
  `leave_time` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '离开时间',
  `leave_place` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '离开地点',
  `end_desc` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '结束相关描述',
  `vehicle_option` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '车辆配置',
  `vehicle_remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '其他备注',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `reserve_guide_id` int(11) NOT NULL DEFAULT '0' COMMENT '预约导游ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: user_address
-- ============================================================
CREATE TABLE `user_address` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姓名',
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '联系电话',
  `country` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '国家',
  `country_id` int(11) DEFAULT '0' COMMENT '国家ID',
  `city` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '城市',
  `city_id` int(11) DEFAULT '0' COMMENT '城市ID',
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '地址',
  `street` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '街道',
  `post_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮编',
  `default` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否默认',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: user_follow_shop
-- ============================================================
CREATE TABLE `user_follow_shop` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '关注用户ID',
  `user_continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '关注用户大洲ID',
  `user_area_id` int(11) NOT NULL DEFAULT '0' COMMENT '关注用户地区ID',
  `user_identity` tinyint(1) NOT NULL DEFAULT '0' COMMENT '用户身份',
  `user_identity_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户身份ID',
  `user_identity_tag` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户身份',
  `user_city_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '城市',
  `followed_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '被关注店铺ID',
  `followed_continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '被关注店铺大洲ID',
  `followed_area_id` int(11) NOT NULL DEFAULT '0' COMMENT '被关注店铺地区ID',
  `followed_user_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '被关注店铺用户ID',
  `followed_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '店铺名称',
  `followed_city_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '城市',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: user_follows
-- ============================================================
CREATE TABLE `user_follows` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '关注用户ID',
  `user_continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '关注用户大洲ID',
  `user_area_id` int(11) NOT NULL DEFAULT '0' COMMENT '关注用户地区ID',
  `user_identity` tinyint(1) NOT NULL COMMENT '用户身份',
  `user_identity_id` int(11) NOT NULL COMMENT '用户身份ID',
  `user_identity_tag` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户身份',
  `user_city_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '城市',
  `followed_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '被关注用户ID',
  `followed_continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '被关注用户大洲ID',
  `followed_area_id` int(11) NOT NULL DEFAULT '0' COMMENT '被关注用户地区ID',
  `followed_identity` tinyint(1) NOT NULL COMMENT '被关注用户身份',
  `followed_identity_id` int(11) NOT NULL COMMENT '被关注用户身份ID',
  `followed_identity_tag` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '被关注用户身份',
  `followed_city_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '城市',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: user_integral_log
-- ============================================================
CREATE TABLE `user_integral_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '类型 1支出/2收入',
  `title` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `before` int(11) NOT NULL DEFAULT '0' COMMENT '变动金额之前',
  `amount` int(11) NOT NULL DEFAULT '0' COMMENT '变动金额',
  `after` int(11) NOT NULL DEFAULT '0' COMMENT '变动金额之后',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=800 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: user_integral_order
-- ============================================================
CREATE TABLE `user_integral_order` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_sn` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `user_address_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户地址ID',
  `integral_goods_id` int(11) NOT NULL DEFAULT '0' COMMENT '积分商品ID',
  `integral_goods_info` json DEFAULT NULL COMMENT '积分商品信息',
  `price` int(11) NOT NULL DEFAULT '0' COMMENT '消费积分',
  `free_shipping` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否包邮',
  `pay_time` timestamp NULL DEFAULT NULL COMMENT '支付时间',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `express_delivery_company` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '快递公司',
  `express_delivery_number` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '快递单号',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: user_invite_log
-- ============================================================
CREATE TABLE `user_invite_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '邀请人用户ID',
  `invitees_uid` int(11) NOT NULL DEFAULT '0' COMMENT '被邀请人用户ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: user_login
-- ============================================================
CREATE TABLE `user_login` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '邀请人用户ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=645 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: users
-- ============================================================
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '编号',
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像',
  `nickname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '昵称',
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `birthday` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '生日',
  `inviter_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邀请码',
  `inviter_id` int(11) NOT NULL DEFAULT '0' COMMENT '我的邀请人ID',
  `integral` int(11) NOT NULL DEFAULT '0' COMMENT '积分',
  `identity` tinyint(1) NOT NULL DEFAULT '1' COMMENT '身份',
  `identity_str` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '身份',
  `continents_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属大洲ID',
  `area_id` int(11) NOT NULL DEFAULT '0' COMMENT '所属地区ID',
  `city` int(11) NOT NULL DEFAULT '0' COMMENT '所在城市',
  `city_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所在城市',
  `vip_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '会员类型',
  `vip_id` int(11) NOT NULL DEFAULT '0' COMMENT '会员ID',
  `vip_name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '会员',
  `vip_expiration_time` int(11) NOT NULL DEFAULT '0' COMMENT '会员到期时间',
  `vip_free` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否免费',
  `vip_company_auth` json DEFAULT NULL COMMENT '企业会员权限',
  `guide_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '导游ID',
  `company_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '企业ID',
  `im_login` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `users_email_unique` (`email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: vip_company
-- ============================================================
CREATE TABLE `vip_company` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `time_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '时间类型',
  `buy_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '购买类型',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '金额',
  `number` tinyint(4) NOT NULL DEFAULT '1' COMMENT '可添加店铺数量',
  `shop_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '添加店铺是否同类型',
  `city_content_recommend` tinyint(4) NOT NULL DEFAULT '0' COMMENT '城市内容推荐天数',
  `home_list_recommend` tinyint(4) NOT NULL DEFAULT '0' COMMENT '首页列表推荐',
  `home_banner_recommend` tinyint(4) NOT NULL DEFAULT '0' COMMENT '首页banner推荐',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: vip_guide
-- ============================================================
CREATE TABLE `vip_guide` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `time_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '时间类型',
  `buy_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '购买类型',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '金额',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- ============================================================
-- Table: vip_order
-- ============================================================
CREATE TABLE `vip_order` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_sn` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `vip_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '会员类型',
  `vip_id` int(11) NOT NULL DEFAULT '0' COMMENT '会员ID',
  `time_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '购买时间类型',
  `buy_type` tinyint(1) NOT NULL DEFAULT '1' COMMENT '支付方式 金额/积分',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '支付金额',
  `pay_time` int(11) NOT NULL DEFAULT '0' COMMENT '支付时间',
  `pay_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '支付状态',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

