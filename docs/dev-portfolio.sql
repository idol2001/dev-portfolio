/*
 Navicat Premium Dump SQL

 Source Server         : 本地测试
 Source Server Type    : MySQL
 Source Server Version : 80406 (8.4.6)
 Source Host           : 192.168.0.31:3306
 Source Schema         : dev-portfolio

 Target Server Type    : MySQL
 Target Server Version : 80406 (8.4.6)
 File Encoding         : 65001

 Date: 10/04/2026 21:14:32
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for blog_posts
-- ----------------------------
DROP TABLE IF EXISTS `blog_posts`;
CREATE TABLE `blog_posts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `title` varchar(256) COLLATE utf8mb4_general_ci NOT NULL COMMENT '文章标题',
  `slug` varchar(256) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'URL标识',
  `summary` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '文章摘要',
  `content` longtext COLLATE utf8mb4_general_ci COMMENT '文章内容(Markdown)',
  `cover_image` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '封面图URL',
  `author_id` bigint unsigned NOT NULL COMMENT '作者ID',
  `status` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'draft' COMMENT '状态(draft/published)',
  `tags` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '标签(逗号分隔)',
  `published_at` bigint DEFAULT NULL COMMENT '发布时间(Unix时间戳)',
  `view_count` bigint DEFAULT '0' COMMENT '浏览次数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_blog_posts_slug` (`slug`),
  KEY `idx_blog_posts_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ----------------------------
-- Table structure for profile_infos
-- ----------------------------
DROP TABLE IF EXISTS `profile_infos`;
CREATE TABLE `profile_infos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `name` varchar(256) DEFAULT NULL,
  `roles` varchar(256) DEFAULT NULL,
  `about` varchar(4096) DEFAULT NULL,
  `image_source` varchar(1024) DEFAULT NULL,
  `logo` varchar(1024) DEFAULT NULL,
  `logo_height` bigint DEFAULT NULL,
  `logo_width` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_profile_infos_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for profile_nav_bars
-- ----------------------------
DROP TABLE IF EXISTS `profile_nav_bars`;
CREATE TABLE `profile_nav_bars` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `title` varchar(256) DEFAULT NULL,
  `href` varchar(256) DEFAULT NULL,
  `order_no` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_profile_nav_bars_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for profile_skill_groups
-- ----------------------------
DROP TABLE IF EXISTS `profile_skill_groups`;
CREATE TABLE `profile_skill_groups` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `skill_group_title` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_profile_skill_groups_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for profile_skills
-- ----------------------------
DROP TABLE IF EXISTS `profile_skills`;
CREATE TABLE `profile_skills` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `skill_group_id` bigint unsigned DEFAULT NULL,
  `skill_icon` varchar(256) DEFAULT NULL,
  `skill_title` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_profile_skills_deleted_at` (`deleted_at`),
  KEY `fk_profile_skill_groups_skill_group_items` (`skill_group_id`),
  CONSTRAINT `fk_profile_skill_groups_skill_group_items` FOREIGN KEY (`skill_group_id`) REFERENCES `profile_skill_groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for profile_socials
-- ----------------------------
DROP TABLE IF EXISTS `profile_socials`;
CREATE TABLE `profile_socials` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `network` varchar(256) DEFAULT NULL,
  `href` varchar(1024) DEFAULT NULL,
  `order_no` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_profile_socials_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `username` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(256) COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码(bcrypt)',
  `nickname` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '头像URL',
  `email` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '邮箱',
  `role` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'admin' COMMENT '角色',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_users_username` (`username`),
  KEY `idx_users_deleted_at` (`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET FOREIGN_KEY_CHECKS = 1;
