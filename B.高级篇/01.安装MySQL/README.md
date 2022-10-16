## 安装

> debian 安装

## 修改字符集

### 配置文件修改

```ini
[mysqld]
character_set_server=utf8mb4
```

### 修改已有数据库的字符集

```sql
ALTER DATABASE 数据库名 CHARACTER SET utf8mb4;
```

### 修改已有表的字符集

```sql
ALTER TABLE 表名 CONVERT TO CHARACTER SET utf8mb4;
```

## 各级别的字符集

| 变量                       | 说明                                                         |
| -------------------------- | ------------------------------------------------------------ |
| `character_set_server`     | 服务器级别的字符集                                           |
| `character_set_database`   | 当前数据库的字符集                                           |
| `character_set_client`     | 服务器解码请求时使用的字符集                                 |
| `character_set_connection` | 服务器处理请求时会把请求字符集从 `character_set_client` 转为 `character_set_connection` |
| `character_set_results`    | 服务器向客户端返回数据时使用的字符集                         |

- 如果创建或修改列时没有显式指定字符集和比较规则，则该列默认用表的字符集和比较规则
- 如果创建表时没有显式指定字符集和比较规则，则该表默认用数据库的字符集和比较规则
- 如果创建数据库时没有显式指定字符集和比较规则，则该数据库默认用服务器的字符集和比较规则

## UTF8 和 UTF8MB4

- `utf8`或`utf8mb3`：阉割过的 `utf8` 字符集，只使用 1~3 个字节表示字符
- `utf8mb4`：正宗的 `utf8` 字符集，使用 1~4 个字节表示字符

## 比较规则

| 后缀   | 英文释义             | 说明             |
| ------ | -------------------- | ---------------- |
| `_ai`  | `accent insensitive` | 不区分重音       |
| `_as`  | `accent sensitive`   | 区分重音         |
| `_ci`  | `case insensitive`   | 不区分大小写     |
| `_cs`  | `case sensitive`     | 区分大小写       |
| `_bin` | `binary`             | 以二进制方式比较 |

常用操作：

```sql
-- 查看比较规则
SHOW COLLATION LIKE 'utf8_%';

-- 查看服务器的字符集和比较规则
SHOW VARIABLES LIKE '%_server';

-- 查看数据库的字符集和比较规则
SHOW VARIABLES LIKE '%_database';

-- 查看具体数据库的字符集
SHOW CREATE DATABASE 数据库名;

-- 修改具体数据库的字符集
ALTER DATABASE 数据库名 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

-- 查看表的字符集
SHOW CREATE TABLE 表名;

-- 查看表的比较规则
SHOW TABLE STATUS FROM 数据库名 LIKE '表名';

-- 修改表的字符集和比较规则
ALTER TABLE 表名 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
```

## 大小写规范

查看：

```sql
SHOW VARIABLES LIKE '%lower_case_table_names%'
```

- `0`：大小写敏感。默认值，Linux 系统默认。
- `1`：大小写不敏感。Windows 默认。创建的表，数据库都是以小写形式存放在磁盘上，对于sql语句都是转 换为小写对表和数据库进行查找
- `2`：创建的表和数据库依据语句上格式存放，凡是查找都是转换为小写进行。

设置大小写不敏感(mysql8禁止修改)

```ini
[mysqld]
lower_case_table_names=1
```

## `sql_mode`

- 宽松模式：在插入数据时，即使是错误数据，也可能会被接受而不会报错。比如，字符串超过长度。
- 严格模式：MySQL 5.7 将 `sql_mode` 默认值改成了严格模式。
- 严格模式可能存在的问题：若设置模式中包含了 `NO_ZERO_DATE` ，那么MySQL数据库不允许插入零日期，插入零日期会抛出错误而 不是警告。例如，表中含字段`TIMESTAMP`列(如果未声明为`NULL`或显示`DEFAULT`子句)将自动分配 `DEFAULT '0000-00-00 00:00:00'`(零时间戳)，这显然是不满足`sql_mode`中的`NO_ZERO_DATE`而报错。

查看当前的 `sql_mode`

```sql
SELECT @@[session.|global.]sql_mode;
-- 或者
SHOW VARIABLES LIKE 'sql_mode';
```

临时设置

```sql
SET GLOBAL sql_mode = 'modes...'; -- 全局
SET GLOBAL sql_mode = 'modes...'; -- 当前会话
```

永久设置：

```ini
[mysqld]
sql_mode=ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
```

