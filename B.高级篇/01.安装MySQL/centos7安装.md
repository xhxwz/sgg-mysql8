## MySQL 8 安装

### 依赖

```bash
yum install libaio net-tools perl -y && \
yum remove mysql-libs -y 
```

### 安装

> 安装顺序：`common -> client-plugins -> libs -> client -> icu-data -> server`

```bash
rpm -ivh mysql-community-common-8.0.31-1.el7.x86_64.rpm && \
rpm -ivh mysql-community-client-plugins-8.0.31-1.el7.x86_64.rpm && \
rpm -ivh mysql-community-libs-8.0.31-1.el7.x86_64.rpm && \
rpm -ivh mysql-community-client-8.0.31-1.el7.x86_64.rpm && \
rpm -ivh mysql-community-icu-data-files-8.0.31-1.el7.x86_64.rpm  && \
rpm -ivh mysql-community-server-8.0.31-1.el7.x86_64.rpm
```

### 验证安装

```bash
mysql --version
# 或
mysqladmin --version
```

### 服务的初始化

```bash
mysqld --initialize --user=mysql
```

### 查看初始密码

```bash
cat /var/log/mysqld.log
```
### 启动服务

```bash
systemctl start mysqld
```
### 登录到 MySQL

```bash
mysql -u root -p
```
### 重置密码

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';
```

## MySQL 5.7 安装

### 安装

> 安装顺序：`common -> libs -> client -> server`

```bash
rpm -ivh mysql-community-common-5.7.39-1.el7.x86_64.rpm && \
rpm -ivh mysql-community-libs-5.7.39-1.el7.x86_64.rpm && \
rpm -ivh mysql-community-client-5.7.39-1.el7.x86_64.rpm && \
rpm -ivh mysql-community-server-5.7.39-1.el7.x86_64.rpm
```

### 设置字符集

> `/etc/my.cnf`

```ini
[mysqld]
character_set_server = utf8
```

## 远程登录

### 列出已存在的用户

```sql
USE mysql;
SELECT host,user FROM user;
```

### 添加用户

```sql
CREATE USER 'root'@'%' IDENTIFIED BY '密码';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
```

### 修改 `/etc/my.cnf`

```ini
bind-address = ::
```

> `::` 或 `*`

