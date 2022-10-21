## `mysqldump` 实现逻辑备份

```bash
# 备份一个数据库
mysqldump -u 用户名 -h 主机 -p密码 数据名[表名,...] > 备份文件名.sql

## 举例
mysqldump -u root -p atguigudb > atguigudb.sql

# 备份全部数据库
mysqldump -u 用户名 -p密码 [ --all-databases| -A ] > all_database.sql
## 举例
mysqldump -u root -p  -A  > all_database.sql

# 备份部分数据库
mysqldump -u 用户名 -p密码 [ --databases| -B ] [数据库1 数据库2 ...] > 备份文件名.sql
## 举例
mysqldump -u root -p -B db1 db2 > db1_db2.sql

```

## mysql命令恢复数据

```bash
mysql -u root -p [数据库名] < 备份文件.sql

## 举例，单库恢复
mysql -u root -p atguigudb < atguigudb.sql
```

## 物理备份：直接复制整个数据库

## 物理恢复：直接复制到数据库目录

## 表的导出与导入

