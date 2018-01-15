参考：

todo_rust_rocket_diesel_mysql_pool

https://github.com/vrodic/todo_rust_rocket_diesel_mysql_pool


diesel

https://github.com/diesel-rs/diesel



CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(300) COLLATE utf8_unicode_ci NOT NULL DEFAULT '' COMMENT '',
  `body` text NOT NULL,
  `published` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='test';

