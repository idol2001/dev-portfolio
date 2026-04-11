-- 初始化技能数据
INSERT INTO profile_skill_groups (skill_group_title, created_at, updated_at) VALUES 
('Languages & Databases', NOW(), NOW()),
('Frameworks & Technologies', NOW(), NOW()),
('Tools & Platforms', NOW(), NOW());

-- 获取刚插入的组 ID
SET @lang_id = (SELECT id FROM profile_skill_groups WHERE skill_group_title = 'Languages & Databases' LIMIT 1);
SET @fwk_id = (SELECT id FROM profile_skill_groups WHERE skill_group_title = 'Frameworks & Technologies' LIMIT 1);
SET @tool_id = (SELECT id FROM profile_skill_groups WHERE skill_group_title = 'Tools & Platforms' LIMIT 1);

-- 插入技能项
INSERT INTO profile_skills (skill_group_id, skill_icon, skill_title, created_at, updated_at) VALUES
(@lang_id, '', 'Java'),
(@lang_id, '', 'C#'),
(@lang_id, '', 'JavaScript'),
(@lang_id, '', 'Python'),
(@lang_id, '', 'Objective-C'),
(@lang_id, '', 'MySQL'),
(@fwk_id, '', 'Android'),
(@fwk_id, '', 'Django'),
(@fwk_id, '', 'Flask'),
(@fwk_id, '', 'SpringBoot'),
(@fwk_id, '', 'Dubbo'),
(@tool_id, '', 'Nacos'),
(@tool_id, '', 'Flutter'),
(@tool_id, '', 'Android Studio'),
(@tool_id, '', 'XCode'),
(@tool_id, '', 'Git'),
(@tool_id, '', 'Docker'),
(@tool_id, '', 'Sketch'),
(@tool_id, '', 'Axure');

-- 插入示例项目
INSERT INTO projects (title, description, tech_stack, repo_url, demo_url, cover_image, `order`, published, created_at, updated_at) VALUES
('Secure Chat App', 'An Android App that allows users to send texts in real time. End to End encryption using RSA Algorithm. Uses Firebase database to store texts. Secured with Fingerprint lock.', '["Java", "Android", "Firebase", "RSA"]', 'https://github.com/idol2001/SecureChatApp', '', '', 1, true, NOW(), NOW()),
('Caaring - Cab Share App', 'A Cab Sharing web app made using Django for VIT Students. People can create a new cab or request to join an existing cab. Added User authentication and password reset using SendGrid. Deployed on heroku using gunicorn.', '["Python", "Django", "BootStrap", "Heroku", "Gunicorn"]', 'https://github.com/idol2001/Caaring', '', '', 2, true, NOW(), NOW()),
('MVVM Sample App', 'An Android App that loads data from mock API and show in both LinearLayout and GridLayout RecyclerView. Offline support using Room DB and Network Bound Resource. Uses the MVVM architecture.', '["Kotlin", "Android", "MVVM", "Room", "Coroutines", "Hilt-Dagger"]', 'https://github.com/idol2001/MVVMSample', '', '', 3, true, NOW(), NOW()),
('Quiet Hours App', 'An Android App that automatically silences your phone during class hours, designed for VITians. Option to select class slots and custom time. Option to put on Vibrate instead of Silent.', '["Java", "Android", "Alarm Manager"]', 'https://github.com/idol2001/QuietHours', '', '', 4, true, NOW(), NOW()),
('Feed List App', 'An Android App that loads list of feeds from a paginated API and shows in a RecyclerView. Uses the MVVM architecture. Uses Paging 3 library along with other Architecture Components.', '["Kotlin", "Android", "MVVM", "Flow", "Paging 3", "Coroutines"]', 'https://github.com/idol2001/FeedListApp', '', '', 5, true, NOW(), NOW());

-- 插入示例博客文章
INSERT INTO blog_posts (title, slug, excerpt, content, tags, published, published_at, view_count, created_at, updated_at) VALUES
('Understanding MVVM Architecture in Android', 'understanding-mvvm-architecture-android', 'A comprehensive guide to implementing MVVM architecture in Android applications.', 'This article covers the fundamentals of MVVM architecture...', '["Android", "MVVM", "Architecture"]', true, NOW(), 0, NOW(), NOW()),
('Getting Started with Go and Gin Framework', 'getting-started-go-gin-framework', 'Learn how to build RESTful APIs using Go and the Gin framework.', 'Go is a powerful language for building backend services...', '["Go", "Gin", "Backend"]', true, NOW(), 0, NOW(), NOW()),
('Docker Best Practices for Development', 'docker-best-practices-development', 'Essential Docker tips and best practices for developers.', 'Docker has revolutionized how we deploy applications...', '["Docker", "DevOps", "Containers"]', true, NOW(), 0, NOW(), NOW());

-- 插入个人资料
INSERT INTO profiles (user_id, full_name, slogan, about, avatar_url, location, website, github, linkedin, twitter, created_at, updated_at) VALUES
(1, 'Jacob Lee', "I'm a Full-Stack Developer", 'I''m a curious, versatile individual passionate about merging technology and creativity, bridging technical problem-solving with human-centric storytelling. My days blend coding, experimenting with tools, and simplifying complex ideas.', '', '', '', 'idol2001', '', '', NOW(), NOW());
