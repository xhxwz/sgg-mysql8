## 登录 MySQL 服务器

```bash
mysql -h HOSTNAME -P PORT -u USERNAME -p DATABASE -e 'SQL语句'
```

- `-h` 主机名或 IP
- `-P` 端口，默认 `3306`
- `-u` 用户名
- `-p` 密码
- `DATABASE` 指明登录到哪一个数据库中
- `-e` 登录 MySQL 服务器执行 sql 语句，然后退出登录

## 创建用户

```sql
CREATE USER 用户名[@主机名] [IDENTIFIED BY '密码'] [,用户名[@主机名] [IDENTIFIED BY '密码']];
```

- 如果没有指定主机名，默认是 `%`

```sql
CREATE USER 'zhangsan'@'%' IDENTIFIED BY 'zhangshan';
```

## 修改用户

```sql
UPDATE mysql.user SET user='zhang3' WHERE user='zhangsan';
FLUSH PRIVILEGES;
```

## 删除用户

```sql
-- 方式1【推荐】
DROP USER 用户名[@主机名];

-- 【不推荐】方式2：系统会有残留信息
DELETE FROM mysql.user WHERE user='用户名' AND host='主机名';
FLUSH PRIVILEGES;
```

## 修改当前用户自己的密码

```sql
-- 方式1【推荐】
ALTER USER USER() IDENTIFIED BY '新密码';

-- 方式2
SET PASSWORD='新密码';
```

## 修改其它用户密码

```sql
-- 方式1
ALTER USER 用户名[@主机名] [IDENTIFIED BY '新密码'] [,用户名[@主机名] [IDENTIFIED BY '新密码']];

-- 方式2
SET PASSWORD FOR '用户名'@'主机名' = '新密码';
```

## MySQL 权限列表

```sql
SHOW PRIVILEGES;
```

- `CREATE`和`DROP`权限 ，可以创建新的数据库和表，或删除(移掉)已有的数据库和表。如果将 MySQL 数据库中的`DROP`权限授予某用户，用户就可以删除 MySQL 访问权限保存的数据库。
- `SELECT`、`INSERT`、`UPDATE`和`DELETE`权限 允许在一个数据库现有的表上实施操作。
- `SELECT`权限 只有在它们真正从一个表中检索行时才被用到。
- `INDEX`权限 允许创建或删除索引，`INDEX`适用于已 有的表。如果具有某个表的`CREATE`权限，就可以在`CREATE TABLE`语句中包括索引定义。
- `ALTER`权 限 可以使用`ALTER TABLE`来更改表的结构和重新命名表。
- `CREATE ROUTINE`权限用来创建保存的 程序(函数和程序)，`ALTER ROUTINE`权限用来更改和删除保存的程序，`EXECUTE`权限用来执行保存的 程序。
- `GRANT`权限 允许授权给其他用户，可用于数据库、表和保存的程序。
- `FILE`权限 使用户可以使用`LOAD DATA INFILE`和`SELECT ... INTO OUTFILE`语句读或写服务器上的文件，任何被授予`FILE`权 限的用户都能读或写 MySQL 服务器上的任何文件(说明用户可以读任何数据库目录下的文件，因为服务 器可以访问这些文件)。

| 权限分布 | 可能的设置的权限                                                                |
| -------- | ------------------------------------------------------------------------------- |
| 表权限   | `Select, Insert, Update, Delete, Create, Drop, Grant, References, Index, Alter` |
| 列权限   | `Select, Insert, Update, References`                                            |
| 过程权限 | `Execute, Alter Routine, Grant`                                                 |

## 授予权限

原则：

- 只授予能满足需要的最小权限，防止用户干坏事。比如用户只是需要查询，就给 `SELECT` 权限就好了，不要赋予 `Update, Insert, DELETE` 权限
- 创建用户的时候，限制用户的登录主机，一般是限制成指定 IP 或者内网 IP 段
- 为每个用户 设置满足密码复杂度的密码
- 定期清理不需要的用户，回收权限或者删除用户。

授予权限方式一，直接给用户授权：

```sql
GRANT 权限1,权限2... ON 数据库名.表名 TO 用户名@主机 [IDENTIFIED BY '密码'];
```

> 如果没有该用户，则会直接新建一个用户。

举例：

```sql
-- 给 li4@localhost 授予 foo 库下所有表的插入、删除、修改、查询的权限
GRANT SELECT,INSERT,DELETE,UPDATE ON foo.* TO li4@localhost;

-- 给 joe@% 用户授予所有库、所有表的全部权限，（不包括 GRANT 权限），密码设置为123
GRANT ALL PRIVILEGES ON *.* TO joe@'%' IDENTIFIED BY '123';

```

查看权限：

```sql
-- 查看当前用户权限
SHOW GRANTS;

-- 查看用户的全局权限
SHOW GRANTS FOR '用户'@'主机';
```

## 收回权限

> 在将用户删除之前，应该收回其所有权限

```sql
REVOKE 权限1,权限2... 数据库名.表名 FROM 用户名@主机;
```

举例：

```sql
-- 收回全库全表的所有权限
REVOKE ALL PRIVILEGES ON *.* FROM joe@'%';

-- 收回 foo 库下所有表的插入、删除、修改、查询权限
REVOKE SELECT,INSERT,DELETE,UPDATE ON foo.* FROM joe@localhost;
```

## 创建角色

```sql
CREATE ROLE 角色名称[@主机][,角色名称[@主机]];
```

举例：

```sql
--  创建“经理”角色，只能在本地登录
CREATE ROLE 'manager'@'localhost';
```

## 给角色授权

```sql
GRANT 权限列表 ON 表名 TO 角色@主机;
```

举例：

```sql
-- 给角色manager授予 test1 库的 emp  表的查询权限
GRANT SELECT ON test1.emp TO 'manager'@'localhost';
```

## 查看角色的权限

```sql
SHOW GRANTS FOR 角色@主机;

-- 举例
SHOW GRANTS FOR 'manager'@'localhost';
```

## 回收权限

```sql
REVOKE 权限列表 ON 数据库.表 FROM 角色@主机;

-- 举例
REVOKE SELECT ON test1.emp FROM 'manager'@'localhost';
```

## 删除角色

```sql
DROP ROLE 角色名@主机;
```

## 给用户赋予角色

```sql
GRANT 角色 TO 用户@主机;
```

## 查看当前用户的角色

```sql
SELECT CURRENT_ROLE();
```

## 激活角色

```sql
-- 方式1
SET DEFAULT ROLE ALL TO 用户@主机;

-- 方式2
SET GLOBAL activate_all_roles_on_login=ON;
```

## 撤销用户角色

```sql
REVOKE 角色 FROM 用户@主机;
```

## 设置强制角色(mandatory role)

方式 1：

```ini
[mysqld]
mandatory_roles='role1,role2@localhost,rule3@%.foo.com'
```

方式 2：

```sql
-- 系统重启后依然有效
SET PERSIST mandatory_ROLES = 'role1,role2@localhost,rule3@%.foo.com';

-- 系统重启后失效
SET GLOBAL mandatory_ROLES = 'role1,role2@localhost,rule3@%.foo.com';
```

## 配置文件

- `[server]` 组的选项将作用于所有服务器程序
- `[clinet]` 组的选项将作用于所有客户端程序

| 启动命令       | 类别       | 能读取的配置组                            |
| -------------- | ---------- | ----------------------------------------- |
| `mysqld`       | 启动服务器 | `[mysqld]`, `[server]`                    |
| `mysqld_safe`  | 启动服务器 | `[mysqld]`, `[server]` , `[mysql_safe]`   |
| `mysql.server` | 启动服务器 | `[mysqld]`, `[server]` , `[mysql.server]` |
| `mysql`        | 启动客户端 | `[mysql]`, `[client]`                     |
| `mysqladmin`   | 启动客户端 | `[mysqladmin]`, `[client]`                |
| `mysqldump`    | 启动客户端 | `[mysqldump]`, `[client]`                 |

## 系统变量

- `max_connections`：允许同时连接的客户端数量
- `default_storage_engine`：表的默认存储引擎
- `query_cache_size`：查询缓存大小
