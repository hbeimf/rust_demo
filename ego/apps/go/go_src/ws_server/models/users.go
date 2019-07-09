package models

import "time"

// Time marshaljson
type Time time.Time

// TimeFormat for format time
const TimeFormat = "2006-01-02 15:04:05"

// UnmarshalJSON parse byte to time
func (t *Time) UnmarshalJSON(data []byte) error {
	now, err := time.ParseInLocation(`"`+TimeFormat+`"`, string(data), time.Local)
	*t = Time(now)
	return err
}

// MarshalJSON parse json to byte
func (t Time) MarshalJSON() ([]byte, error) {
	b := make([]byte, 0, len(TimeFormat)+2)
	b = append(b, '"')
	b = time.Time(t).AppendFormat(b, TimeFormat)
	b = append(b, '"')
	return b, nil
}

func (t Time) String() string {
	return time.Time(t).Format(TimeFormat)
}

// User 用户
type Users struct {
	// Id 主键
	ID int64 `json:"id" form:"id" xorm:"pk id"`
	// Avatar 头像
	Name string `json:"name" form:"name"`
	// Avatar 头像
	Email string `json:"email" form:"email"`
	// Password 密码
	Password string `json:"password" form:"password"`
	// RePassword
	RememberToken string `form:"remember_token" xorm:"-"`
	// CreateAt 创建时间
	CreatedAt Time `json:"created_at" xorm:"created 'created_at'"`
	// CreateAt 创建时间
	UpdatedAt Time `json:"updated_at" xorm:"created 'updated_at'"`
}

// UserRole 用户角色
type UserRole struct {
	Users    `xorm:"extends"`
	Roles    `xorm:"extends"`
	RoleUser `xorm:"extends"`
}

// TableName set table
func (Users) TableName() string {
	return "users"
}
