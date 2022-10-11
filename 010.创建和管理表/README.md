##  标识符命名规则

- 数据库名、表名不得超过30个字符，变量名限制为29个
- 必须只能包含 `A–Z, a–z, 0–9, _`共63个字符
- 数据库名、表名、字段名等对象名中间不要包含空格
- 同一个MySQL软件中，数据库不能同名；同一个库中，表不能重名；同一个表中，字段不能重名
- 必须保证你的字段没有和保留字、数据库系统或常用方法冲突。如果坚持使用，请在SQL语句中使用着重号引起来
- 保持字段名和类型的一致性：在命名字段并为其指定数据类型的时候一定要保证一致性，假如数据类型在一个表里是整数，那在另一个表里可就别变成字符型了

## MySQL中的数据类型

| 类型             | 类型举例                                                     |
| ---------------- | ------------------------------------------------------------ |
| 整数类型         | `TINYINT`、`SMALLINT`、`MEDIUMINT`、**`INT(或INTEGER)`**`、BIGINT`     |
| 浮点类型         | `FLOAT、DOUBLE`                                                |
| 定点数类型       | **`DECIMAL`**                                                  |
| 位类型           | `BIT`                                                          |
| 日期时间类型     | `YEAR、TIME`、**`DATE`**、`DATETIME、TIMESTAMP`                    |
| 文本字符串类型   | `CHAR`、**`VARCHAR`**、`TINYTEXT、TEXT、MEDIUMTEXT、LONGTEXT`      |
| 枚举类型         | `ENUM`                                                         |
| 集合类型         | `SET`                                                          |
| 二进制字符串类型 | `BINARY、VARBINARY、TINYBLOB、BLOB、MEDIUMBLOB、LONGBLOB`      |
| JSON类型         | JSON对象、JSON数组                                           |
| 空间数据类型     | 单值：`GEOMETRY、POINT、LINESTRING、POLYGON`；<br/>集合：`MULTIPOINT、MULTILINESTRING、MULTIPOLYGON、GEOMETRYCOLLECTION` |

其中，常用的几类类型介绍如下：

| 数据类型      | 描述                                                         |
| ------------- | ------------------------------------------------------------ |
| `INT`           | 从`-2^31`到`2^31-1`的整型数据。存储大小为 4个字节                |
| `CHAR(size)`    | 定长字符数据。若未指定，默认为1个字符，最大长度255           |
| `VARCHAR(size)` | 可变长字符数据，根据字符串实际长度保存，**必须指定长度**     |
| `FLOAT(M,D) `   | 单精度，占用4个字节，M=整数位+小数位，D=小数位。`D<=M<=255,0<=D<=30`，默认`M+D<=6` |
| `DOUBLE(M,D)`   | 双精度，占用8个字节s，`D<=M<=255,0<=D<=30`，默认`M+D<=15`         |
| `DECIMAL(M,D)`  | 高精度小数，占用`M+2`个字节，`D<=M<=65，0<=D<=30`，最大取值范围与DOUBLE相同。 |
| `DATE`          | 日期型数据，格式'`YYYY-MM-DD`'                                 |
| `BLOB`          | 二进制形式的长文本数据，最大可达4G                           |
| `TEXT`          | 长文本数据，最大可达4G                                       |

## 创建数据库
```sql
CREATE DATABASE IF NOT EXISTS 数据库名 CHARACTER SET 字符集 COLLATE 整理集
```

比如

```sql
CREATE DATABASE IF NOT EXISTS 数据库名 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 或
CREATE DATABASE IF NOT EXISTS 数据库名 CHARACTER SET utf8 COLLATE utf8_general_ci;
```

## 管理数据库

- 查看所有数据库： `SHOW DATABASES;`
- 切换数据库： `USE 数据库;`
- 查看数据库中的数据库表：`SHOW TABLES;`
- 查看指定数据库下的表：`SHOW TABLES FROM 数据库;`
- 查看当前正在使用的数据库：`SELECT DATABASE();`
- 查看数据库创建信息：`SHOW CREATE DATABASE 数据库;`
- 修改数据库：

```sql
ALTER DATABASE 数据库名 CHARACTER SET 字符集 COLLATE 整理集;
```

- 删除数据库：

```sql
DROP DATABASE IF EXISTS 数据库名;
```

## 创建数据表

```sql
CREATE TABLE IF NOT EXISTS 表名
(
  -- 字段...
  -- 约束...
)ENGINE InnoDB CHARACTER SET 字符集 COLLATE 整理集;
```

### 基于现有表创建，同时导入数据

```sql
CREATE TABLE IF NOT EXISTS 表名
AS
SELECT 字段列表 FROM 现有表名;
```

练习：创建一个表 `employees_copy`，实现对 `employee` 的复制，包括结构和数据

```sql
CREATE TABLE IF NOT EXISTS employees_copy
AS
SELECT * FROM employees;
```

练习：创建一个表 `employees_blank`，实现对 `employee` 的复制，只复制结构

```sql
CREATE TABLE IF NOT EXISTS employees_blank
AS
SELECT * FROM employees WHERE 1=2;
```

## 管理数据表

- 修改表

  ```sql
  -- 添加字段
  ALTER TABLE 表名
  ADD [COLUMN] 字段;
  -- 或
  ADD [COLUMN] 字段 FIRST;
  -- 或
  ADD [COLUMN] 字段 AFTER 已存在字段;
  
  -- 修改字段
  ALTER TABLE 表名
  MODIFY [COLUMN] 字段;
  
  -- 重命名字段
  ALTER TABLE 表名
  CHANGE [COLUMN] 旧字段名 新字段名 新字段数据类型;
  
  -- 删除字段
  ALTER TABLE 表名
  DROP [COLUMN] 字段;
  ```

- 重命名表

  ```sql
  -- 方式一
  RENAME TABLE 表名 TO 新表名;
  
  -- 方式二
  ALTER TABLE 表名
  RENAME [TO] 新表名;
  ```

- 删除表

  ```sql
  DROP TABLE IF EXISTS 表名;
  ```

- 清空表

  ```sql
  TRUNCATE TABLE 表名;
  ```

## `DDL` 和 `DML` 的说明

- `DDL` 的操作一旦执行，就不可以回滚，指令 `SET AUTOCOMMIT = FALSE` 不起作用
- `DML` 默认情况下，一旦操作也是不可滚的。但是，如果设置了 `SET AUTOCOMMIT = FALSE`，则可以实现回滚

```sql
-- 复制一张演示表
CREATE TABLE demo
AS
SELECT * FROM employees;

-- 确定演示表的数据量
SELECT COUNT(*) FROM demo;

-- 关闭自动提交
SET AUTOCOMMIT = FALSE;

-- DML
DELETE FROM demo;
SELECT COUNT(*) FROM demo;
ROLLBACK;
SELECT COUNT(*) FROM demo;

-- DDL
TRUNCATE TABLE demo;
SELECT COUNT(*) FROM demo;
ROLLBACK;
SELECT COUNT(*) FROM demo;
```

> 阿里开发规范：
>
> 【参考】`TRUNCATE TABLE` 比 `DELETE` 速度快，且使用的系统和事务日志资源少，但 `TRUNCATE` 无事务且不触发 `TRIGGER`，有可能造成事故，故不建议在开发代码中使用此语句。 
>
> 说明：`TRUNCATE TABLE` 在功能上与不带 `WHERE` 子句的 `DELETE` 语句相同。

## 内容拓展

### 拓展1：阿里巴巴之MySQL字段命名

- 【`强制`】表名、字段名必须使用小写字母或数字，禁止出现数字开头，禁止两个下划线中间只出现数字。数据库字段名的修改代价很大，因为无法进行预发布，所以字段名称需要慎重考虑。

  - 正例：`aliyun_admin`，`rdc_config`，`level3_name` 
  - 反例：`AliyunAdmin`，`rdcConfig`，`level_3_name`

- 【`强制`】禁用保留字，如 `desc`、`range`、`match`、`delayed` 等，请参考 MySQL 官方保留字。

- 【`强制`】表必备三字段：`id`, `gmt_create`, `gmt_modified`。 

  - 说明：其中 `id` 必为主键，类型为`BIGINT UNSIGNED`、单表时自增、步长为 1。`gmt_create`, `gmt_modified` 的类型均为 `DATETIME` 类型，前者现在时表示主动式创建，后者过去分词表示被动式更新

- 【`推荐`】表的命名最好是遵循 “业务名称_表的作用”。 

  - 正例：`alipay_task` 、 `force_project`、 `trade_config`

- 【`推荐`】库名与应用名称尽量一致。

- 【参考】合适的字符存储长度，不但节约数据库表空间、节约索引存储，更重要的是提升检索速度。 

  - 正例：无符号值可以避免误存负数，且扩大了表示范围。

  ![image-20211024012735469](image-20211024012735469.png)

### 拓展2：如何理解清空表、删除表等操作需谨慎？！

`表删除`操作将把表的定义和表中的数据一起删除，并且MySQL在执行删除操作时，不会有任何的确认信息提示，因此执行删除操时应当慎重。在删除表前，最好对表中的数据进行`备份`，这样当操作失误时可以对数据进行恢复，以免造成无法挽回的后果。

同样的，在使用 `ALTER TABLE` 进行表的基本修改操作时，在执行操作过程之前，也应该确保对数据进行完整的`备份`，因为数据库的改变是`无法撤销`的，如果添加了一个不需要的字段，可以将其删除；相同的，如果删除了一个需要的列，该列下面的所有数据都将会丢失。

### 拓展3：MySQL8新特性—DDL的原子化

在MySQL 8.0版本中，InnoDB表的DDL支持事务完整性，即`DDL操作要么成功要么回滚`。DDL操作回滚日志写入到data dictionary数据字典表mysql.innodb_ddl_log（该表是隐藏的表，通过show tables无法看到）中，用于回滚操作。通过设置参数，可将DDL操作日志打印输出到MySQL错误日志中。

分别在MySQL 5.7版本和MySQL 8.0版本中创建数据库和数据表，结果如下：

```mysql
CREATE DATABASE mytest;

USE mytest;

CREATE TABLE book1(
book_id INT ,
book_name VARCHAR(255)
);

SHOW TABLES;
```

（1）在MySQL 5.7版本中，测试步骤如下：
删除数据表book1和数据表book2，结果如下：

```mysql
mysql> DROP TABLE book1,book2;
ERROR 1051 (42S02): Unknown table 'mytest.book2'
```

再次查询数据库中的数据表名称，结果如下：

```mysql
mysql> SHOW TABLES;
Empty set (0.00 sec)
```

从结果可以看出，虽然删除操作时报错了，但是仍然删除了数据表book1。

（2）在MySQL 8.0版本中，测试步骤如下：
删除数据表book1和数据表book2，结果如下：

```mysql
mysql> DROP TABLE book1,book2;
ERROR 1051 (42S02): Unknown table 'mytest.book2'
```

再次查询数据库中的数据表名称，结果如下：

```mysql
mysql> show tables;
+------------------+
| Tables_in_mytest |
+------------------+
| book1            |
+------------------+
1 row in set (0.00 sec)
```

从结果可以看出，数据表book1并没有被删除。
