package models

// User 用户
type Permissions struct {
	// Id 主键
	ID          int64  `json:"id" form:"id" xorm:"pk id"`
	Name        string `json:"name" form:"name"`
	Slug        string `json:"slug" form:"slug"`
	Description string `json:"description" form:"description"`
	Model       string `json:"model" form:"model"`
	// CreateAt 创建时间
	CreatedAt Time `json:"created_at" xorm:"created 'created_at'"`
	// CreateAt 创建时间
	UpdatedAt Time `json:"updated_at" xorm:"created 'updated_at'"`
}

// UserRole 用户角色
// type UserRole struct {
// 	User `xorm:"extends"`
// 	Role `xorm:"extends"`
// }

// TableName set table
func (Permissions) TableName() string {
	return "permissions"
}
