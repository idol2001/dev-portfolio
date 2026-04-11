-- ----------------------------
-- Table structure for projects
-- ----------------------------
DROP TABLE IF EXISTS `profile_projects`;
CREATE TABLE `profile_projects` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `title` varchar(256) NOT NULL COMMENT '项目标题',
  `description` longtext COMMENT '项目描述',
  `tech_stack` text COMMENT '技术栈(JSON数组)',
  `repo_url` varchar(512) DEFAULT NULL COMMENT '仓库URL',
  `demo_url` varchar(512) DEFAULT NULL COMMENT '在线Demo URL',
  `cover_image` varchar(512) DEFAULT NULL COMMENT '封面图URL',
  `order_no` bigint DEFAULT '0' COMMENT '排序号',
  `status` varchar(32) DEFAULT 'published' COMMENT '状态(draft/published)',
  PRIMARY KEY (`id`),
  KEY `idx_projects_deleted_at` (`deleted_at`),
  KEY `idx_projects_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
