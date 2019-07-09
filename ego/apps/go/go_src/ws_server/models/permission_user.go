package models

// User 用户
type PermissionUser struct {
	// Id 主键
	ID           int64 `json:"id" form:"id" xorm:"pk id"`
	PermissionId int64 `json:"permission_id" form:"permission_id" form:"permission_id"`
	UserId       int64 `json:"user_id" form:"user_id" form:"user_id"`
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
func (PermissionUser) TableName() string {
	return "permission_user"
}
