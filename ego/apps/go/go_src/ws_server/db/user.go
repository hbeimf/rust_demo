package db

import (
	"errors"

	"../models"
	"fmt"
)

// UserDao operate user
type UserDao struct {
}

func Test() {
	SelectSql := "select * from users"
	results, err := x.QueryString(SelectSql)

	if err != nil {
		fmt.Println("err:", err)
	}

	fmt.Println("results:", results)

	user := UserDao{}
	u, err := user.GetUser("test")

	if err != nil {
		fmt.Println("err:", err)
	}

	fmt.Println("the user:", u.ID)
	fmt.Println("the user:", u.Name)
	fmt.Println("the user:", u.Email)

	u1, err1 := user.GetUserByID(8)

	if err1 != nil {
		fmt.Println("err:", err)
	} else {
		fmt.Println("the user:", u1.ID)
		fmt.Println("the user:", u1.Name)
		fmt.Println("the user:", u1.Email)
	}

	u2, err2 := user.Page()
	if err2 != nil {
		fmt.Println("err:", err2)
	} else {
		fmt.Println("the user page:", u2)

	}

	u3, err3 := user.GetUserRole(1)
	if err3 != nil {
		fmt.Println("err:", err3)
	} else {
		fmt.Println("the user role:", u3)

	}

}

//  CREATE TABLE `users` (
//   `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
//   `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
//   `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
//   `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
//   `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
//   `created_at` timestamp NULL DEFAULT NULL,
//   `updated_at` timestamp NULL DEFAULT NULL,
//   PRIMARY KEY (`id`),
//   UNIQUE KEY `users_email_unique` (`email`)
// ) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci

var usercols = []string{"id", "name", "email", "password", "remember_token", "created_at", "updated_at"}

// // GetUser query user by account
func (UserDao) GetUser(name string) (*models.Users, error) {
	users := new(models.Users)
	has, err := x.Cols(usercols...).Where("name = ?", name).Get(users)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("user not found")
	}
	return users, nil
}

// GetUserByID query user by id
func (UserDao) GetUserByID(id int64) (*models.Users, error) {
	user := new(models.Users)
	has, err := x.Cols(usercols...).Where("id = ?", id).Get(user)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("user not found")
	}
	return user, nil
}

// // GetUserRole query user by primary key
// func (UserDao) GetUserRole(id int64) (*models.UserRole, error) {
// 	user := new(models.UserRole)
// 	has, err := x.Table("sys_user").Join("INNER", "sys_role", "sys_user.roleid = sys_role.id").Where("sys_user.id = ?", id).Get(user)
// 	if err != nil {
// 		return nil, err
// 	}
// 	if !has {
// 		return nil, errors.New("user not found")
// 	}
// 	return user, nil
// }

func (UserDao) GetUserRole(id int64) (*models.UserRole, error) {
	user := new(models.UserRole)
	has, err := x.Table("users").Join("INNER", "role_user", "users.id = role_user.user_id").Join("INNER", "roles", "roles.id = role_user.role_id").Where("users.id = ?", id).Get(user)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("user not found")
	}
	return user, nil
}

// // List query all user
// SqlTemplateClient 's doc
// https://www.kancloud.cn/xormplus/xorm/235732

// func (UserDao) List(page models.Page) ([]models.Users, error) {
// 	users := make([]models.Users, 0)
// 	param := utils.StructToMap(page)
// 	err := x.SqlTemplateClient("user.all.sql", &param).Find(&users)
// 	if err != nil {
// 		return nil, err
// 	}
// 	return users, nil
// }

func (UserDao) Page() ([]models.Users, error) {
	users := make([]models.Users, 0)
	// param := utils.StructToMap(page)
	param := map[string]interface{}{"count": 2, "id": 7, "name": ""}
	err := x.SqlTemplateClient("user.all.sql", &param).Find(&users)
	if err != nil {
		return nil, err
	}
	return users, nil
}

// Save is save one user
func (UserDao) Save(user models.Users) error {
	_, err := x.Insert(&user)
	return err
}

// Delete is delete a user
func (UserDao) Delete(id int64) error {
	user := new(models.Users)
	_, err := x.Id(id).Delete(user)
	return err
}

// Update user
func (UserDao) Update(user *models.Users) error {
	_, err := x.Id(user.ID).Cols(usercols...).Update(user)
	return err
}
