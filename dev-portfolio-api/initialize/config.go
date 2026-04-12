package initialize

import (
	"dev-portfolio-api/pkg/global"
	"fmt"
	"os"
	"strings"

	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"
)

const (
	configType  = "yml"
	configPath  = "./configs"
	devConfig   = "config.se"
	stageConfig = "config.st"
	prodConfig  = "config.prd"
)

// 初始化配置文件
func InitConfig() {

	// 获取实例(可创建多实例读取多个配置文件, 这里不做演示)
	v := viper.New()
	// 读取当前go运行环境变量
	env := os.Getenv("RunMode")
	configName := devConfig
	if env == "st" {
		configName = stageConfig
	} else if env == "prd" {
		configName = prodConfig
	}
	v.SetConfigName(configName)
	v.SetConfigType(configType)
	v.AddConfigPath(configPath)
	v.SetEnvKeyReplacer(strings.NewReplacer("-", "_", ".", "_"))
	// 绑定环境变量
	v.AutomaticEnv()

	// 显式绑定阿里云 OSS 环境变量（确保 viper 能识别嵌套 key 的扁平环境变量）
	v.BindEnv("aliyun_oss.enable", "ALIYUNOSS_ENABLE")
	v.BindEnv("aliyun_oss.endpoint", "ALIYUNOSS_ENDPOINT")
	v.BindEnv("aliyun_oss.access_key_id", "ALIYUNOSS_ACCESS_KEY_ID")
	v.BindEnv("aliyun_oss.access_key_secret", "ALIYUNOSS_ACCESS_KEY_SECRET")
	v.BindEnv("aliyun_oss.bucket_name", "ALIYUNOSS_BUCKET_NAME")
	v.BindEnv("aliyun_oss.bucket_domain", "ALIYUNOSS_BUCKET_DOMAIN")
	v.BindEnv("aliyun_oss.dir_prefix", "ALIYUNOSS_DIR_PREFIX")
	err := v.ReadInConfig()
	if err != nil {
		panic(fmt.Sprintf("初始化配置文件失败: %v", err))
	}
	// 转换为结构体
	if err := v.Unmarshal(&global.Conf); err != nil {
		panic(fmt.Sprintf("初始化配置文件失败: %v", err))
	}
	// 监听文件修改，热加载配置。因此不需要重启服务器，就能让配置生效。
	v.WatchConfig()
	// 监听文件修改回调函数
	v.OnConfigChange(func(e fsnotify.Event) {
		fmt.Printf("配置文件:%s 发生变更:%s\n", e.Name, e.Op)
		// 转换为结构体
		if err := v.Unmarshal(&global.Conf); err != nil {
			panic(fmt.Sprintf("初始化配置文件失败: %v", err))
		}
	})
}
