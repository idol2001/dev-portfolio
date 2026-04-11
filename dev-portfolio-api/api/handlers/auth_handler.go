package handlers

import (
	"dev-portfolio-api/internal/services"
	"dev-portfolio-api/middleware"
	"dev-portfolio-api/models"
	"golang.org/x/crypto/bcrypt"

	"github.com/gin-gonic/gin"
)

// LoginRequest 登录请求
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// Login 用户登录
func Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		models.FailWithMessage("参数错误："+err.Error(), c)
		return
	}

	// 验证用户名密码
	user, err := services.Authenticate(req.Username, req.Password)
	if err != nil {
		models.FailWithMessage("用户名或密码错误", c)
		return
	}

	// 生成 Token
	token, err := middleware.GenerateToken(user.ID, user.Username)
	if err != nil {
		models.FailWithMessage("生成令牌失败", c)
		return
	}

	models.OkWithData(gin.H{
		"token": token,
		"user": gin.H{
			"id":       user.ID,
			"username": user.Username,
			"email":    user.Email,
			"role":     user.Role,
		},
	}, c)
}

// Register 用户注册
func Register(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		models.FailWithMessage("参数错误："+err.Error(), c)
		return
	}

	// 创建用户
	user, err := services.CreateUser(req.Username, req.Password)
	if err != nil {
		models.FailWithMessage("创建用户失败："+err.Error(), c)
		return
	}

	// 生成 Token
	token, err := middleware.GenerateToken(user.ID, user.Username)
	if err != nil {
		models.FailWithMessage("生成令牌失败", c)
		return
	}

	models.OkWithData(gin.H{
		"token": token,
		"user": gin.H{
			"id":       user.ID,
			"username": user.Username,
			"email":    user.Email,
			"role":     user.Role,
		},
	}, c)
}

// GetCurrentUser 获取当前用户信息
func GetCurrentUser(c *gin.Context) {
	userId, exists := c.Get("userId")
	if !exists {
		models.FailWithMessage("未找到用户信息", c)
		return
	}

	user, err := services.GetUserByID(userId.(uint))
	if err != nil {
		models.FailWithMessage("获取用户信息失败", c)
		return
	}

	models.OkWithData(gin.H{
		"id":       user.ID,
		"username": user.Username,
		"email":    user.Email,
		"avatar":   user.Avatar,
		"role":     user.Role,
	}, c)
}

// 密码加密
func hashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

// 密码验证
func checkPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}
