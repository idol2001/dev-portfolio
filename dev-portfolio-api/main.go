package main

// 导入gin包
import (
	"dev-portfolio-api/initialize"
	. "dev-portfolio-api/pkg/global"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func init() {
	// 加载 .env 文件（如果存在），优先级高于配置文件
	_ = godotenv.Load()
	_ = godotenv.Load(".env.local")

	initialize.InitConfig()
	initialize.Logger()
	initialize.InitDatabase()
}

// 入口函数
func main() {
	// 初始化一个http服务对象
	r := initialize.InitRouters()
	gin.SetMode(gin.DebugMode)
	// host := "0.0.0.0"
	// port := 8080
	Log.Info("Server is running ...")
	r.Run()
}
