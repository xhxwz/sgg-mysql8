## 查找 `mysql` 目录

```bash
find / -name mysql
```

## MySQL 数据库文件的存放路径

```sql
SHOW VARIABLES LIKE 'datadir';
```

## MySQL 默认数据库

- `mysql`

mysql 系统自带的核心数据库，存储了 mysql 的用户账户和权限信息，一些存储过程、事件的定义信息，一些运行过程中产生的日志信息，一些帮助信息以及时区信息等。

- `information_schema`

保存着 mysql 服务器维护的所有其它数据库的信息。比如有哪些表、哪些视图、触发器、列、索引。这些信息并不是真实的用户数据，而是描述性的元数据。其中一些`innodb_sys`开头的表，表示内部系统表。

- `performance_schema`

主要保存mysql服务器运行过程中的一些状态信息，可以用来监控mysql服务的各类性能指标。包括统计最近执行了哪些语句，在执行过程中每个阶段都花费了多长时间、内存的使用情况等信息。

- `sys`

通过视图形式把`information_schema`和`performance_schema`结合起来，帮助监控mysql的技术性能。

## 数据库在文件系统中的表示

### INNODB 5.7

- `db.opt` 数据库相关配置，比如字符集、比较规则
- `*.frm` 表结构
- `*.ibd` 独立表空间，存储表数据和索引
- `ibdata1` 系统表空间

### INNODB 8

只有 `*.ibd` 文件，表结构和数据、索引都合并到 ibd 文件中

### MYISAM 5.7

- `*.frm` 表结构
- `*.MYD`表数据
- `*.MYI` 表索引

###  MYISAM 8

- `*.sdi` 表结构
- `*.MYD`表数据
- `*.MYI` 表索引

 