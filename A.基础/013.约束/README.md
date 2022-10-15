## 约束(`constraint`)

数据完整性（Data Integrity）是指数据的精确性（Accuracy）和可靠性（Reliability）。它是防止数据库中存在不符合语义规定的数据和防止因错误信息的输入输出造成无效操作或错误信息而提出的。

为了保证数据的完整性，SQL规范以约束的方式对**表数据进行额外的条件限制**。从以下四个方面考虑：

- `实体完整性（Entity Integrity）`：例如，同一个表中，不能存在两条完全相同无法区分的记录
- `域完整性（Domain Integrity）`：例如：年龄范围0-120，性别范围“男/女”
- `引用完整性（Referential Integrity）`：例如：员工所在部门，在部门表中要能找到这个部门
- `用户自定义完整性（User-defined Integrity）`：例如：用户名唯一、密码不能为空等，本部门经理的工资不得高于本部门职工的平均工资的5倍。

**约束是表级的强制规定。**

可以在**创建表时规定约束（通过 CREATE TABLE 语句）**，或者在**表创建之后通过 ALTER TABLE 语句规定约束**。

## 约束的分类

- **根据约束数据列的限制**，约束可分为：
  - **单列约束**：每个约束只约束一列
  - **多列约束**：每个约束可约束多列数据
- **根据约束的作用范围**，约束可分为：
  - **列级约束**：只能作用在一个列上，跟在列的定义后面
  - **表级约束**：可以作用在多个列上，不与列一起，而是单独定义

- **根据约束起的作用**，约束可分为：
  - **`NOT NULL`** **非空约束，规定某个字段不能为空**
  - **`UNIQUE`**  **唯一约束**，**规定某个字段在整个表中是唯一的**
  - **`PRIMARY KEY`  主键(非空且唯一)约束**
  - **`FOREIGN KEY`**  **外键约束**
  - **`CHECK`**  **检查约束**
  - **`DEFAULT`**  **默认值约束**

| 位置                       | 支持的约束                   | 是否可以起约束名   |
| -------------------------- | ---------------------------- | ------------------ |
| 列级约束。在列的后面声明   | 语法都支持，但外键没效果     | 不可以             |
| 表级约束。所有列的下面声明 | 默认值和非空不支持，其它支持 | 可以（主键没效果） |

> 注意： MySQL不支持check约束，但可以使用check约束，而没有任何效果

- 查看某个表已有的约束

```mysql
-- information_schema数据库名（系统库）
-- table_constraints表名称（专门存储各个表的约束）
SELECT * FROM information_schema.table_constraints 
WHERE table_name = '表名称';
```

## `NOT NULL` 非空约束

建表时添加：

```sql
CREATE TABLE 表名(
	字段名 数据类型 NOT NULL
);
```

建表后添加：

```sql
ALTER TABLE 表名
MODIFY 字段名 数据类型 NOT NULL;
```

删除：

```sql
ALTER TABLE 表名
MODIFY 字段名 数据类型 NULL;

-- 或

ALTER TABLE 表名
MODIFY 字段名 数据类型;
```

举例：

```sql
-- 建表时添加
CREATE TABLE IF NOT EXISTS test_not_null(
	id INT NOT NULL,
  name VARCHAR(20) NOT NULL,
  sex CHAR(1)
);

-- 建表后添加
ALTER TABLE test_not_null
MODIFY sex CHAR(1) NOT NULL;

-- 删除
ALTER TABLE test_not_null
MODIFY sex CHAR(1) NULL;
```



## `UNIQUE` 唯一约束

建表时添加1：

```sql
CREATE TABLE 表名(
	字段名 数据类型 UNIQUE [KEY]
);

-- 举例
CREATE TABLE IF NOT EXISTS test_unqiue_1(
	id INT,
  email VARCHAR(255) UNIQUE,
  username VARCHAR(100) UNIQUE KEY
)CHARSET=UTF8MB4;
```

建表时添加2：

```sql
CREATE TABLE 表名(
	字段名 数据类型,
  [CONSTRAINT 约束名] UNIQUE [KEY] (字段名)
);

-- 举例
CREATE TABLE IF NOT EXISTS test_unqiue_2(
	id INT,
  email VARCHAR(255),
  username VARCHAR(100),
  CONSTRAINT unk_test_unqiue_2_email UNIQUE KEY (email),
  UNIQUE (id,username),
  CONSTRAINT unk_test_unqiue_2_id_email_username UNIQUE (id,email,username)
)CHARSET=UTF8MB4;
```

建表后添加1：

```sql
ALTER TABLE 表名
ADD [CONSTRAINT 约束名] UNIQUE [KEY] (字段列表);

-- 举例
ALTER TABLE test_unqiue_1
ADD UNIQUE (id);
```

建表后添加2：

```sql
ALTER TABLE 表名
MODIFY 字段名 字段类型 UNIQUE [KEY];
```

删除唯一约束

- 添加唯一约束的列上会自动创建唯一索引
- 删除唯一约束只能通过删除唯一索引的方式实现
- 删除时需要指定唯一索引名，唯一索引名就和唯一约束名一样
- 如果创建唯一约束时未指定名称，如果是单列，就默认和列名相同；如果是组合列，那么默认和()中排在第一个的列名相同。也可以自定义唯一性约束名

```sql
ALTER TABLE 表名
DROP INDEX 唯一索引名

-- 举例
ALTER TABLE test_unqiue_2
DROP INDEX unk_test_unqiue_2_email;
```

可以通过 `SHOW INDEX FROM 表名` 来查看表的索引。

## `PRIMARY KEY` 主键（非空且唯一）约束

建表时添加：

```sql
-- 方式1
CREATE TABLE 表名(
	字段名 数据类型 PRIMARY KEY
);

-- 举例
CREATE TABLE test_pk1(
	id INT PRIMARY KEY,
  name VARCHAR(20)
);

-- 方式2
CREATE TABLE 表名(
	字段名 数据类型,
  [CONSTRAINT 约束名] PRIMARY KEY (字段)
);

-- 举例
CREATE TABLE test_pk2(
	id INT,
  name VARCHAR(20),
  CONSTRAINT PK_TEST_PK2_ID PRIMARY KEY(id) 
);
```

建表后添加：

```sql
-- 方式1
ALTER TABLE 表名
ADD [CONSTRAINT 约束名] PRIMARY KEY(字段);

-- 举例
CREATE TABLE test_pk3(
	id INT,
  name VARCHAR(20)
);
ALTER TABLE test_pk3 ADD PRIMARY KEY(id);

-- 方式2
ALTER TABLE 表名 MODIFY 字段名 数据类型 PRIMARY KEY;

-- 举例
CREATE TABLE test_pk4(
	id INT,
  name VARCHAR(20)
);
ALTER TABLE test_pk4 MODIFY id INT PRIMARY KEY;
```

删除：

```sql
ALTER TABLE 表名 DROP PRIMARY KEY;

-- 举例
ALTER TABLE test_pk4 DROP PRIMARY KEY;
```

- 删除主键约束不需要指定名称
  - 因为一个表只有一个主键
  - 即使创建的时候指定了主键名，但 MySQL 还是把它命名为 `PRIMARY`

- 删除主键约束后，非空约束还存在

## `AUTO_INCREMENT` 自增

（1）一个表最多只能有一个自增长列

（2）当需要产生唯一标识符或顺序值时，可设置自增长

（3）自增长列约束的列必须是键列（主键列，唯一键列）

（4）自增约束的列的数据类型必须是整数类型

（5）如果自增列指定了 0 和 null，会在当前最大值的基础上自增；如果自增列手动指定了具体值，直接赋值为具体值。

建表时指定：

```sql
CREATE TABLE 表名(
	字段名 数据类型 PRIMARY KEY AUTO_INCREMENT
);
```

建表后：

```sql
ALTER TABLE 表名 MODIFY 字段名 数据类型 AUTO_INCREMENT;

-- 举例
create table employee(
	eid int primary key ,
    ename varchar(20)
);
alter table employee modify eid int auto_increment;
```

删除：

```sql
ALTER TABLE 表名 MODIFY 字段名 数据类型; -- 去掉 AUTO_INCREMENT 相当于删除
```

## `FOREIGN KEY` 外键约束

建表时添加：

```sql
CREATE TABLE 表名(
	[CONSTRAINT 约束名] FOREIGN KEY (字段名) REFERENCES 主表名(被参考字段名) [ON UPDATE 约束等级] [ON DELETE 约束等级]
);
```

建表后添加：

```sql
ALTER TABLE 表名
ADD [CONSTRAINT 约束名] FOREIGN KEY (字段名) REFERENCES 主表名(被参考字段名) [ON UPDATE 约束等级] [ON DELETE 约束等级];
```

删除：

```sql
-- 第一步先查看约束名和删除外键约束
SELECT * FROM information_schema.table_constraints WHERE table_name = '表名称'; -- 查看某个表的约束名

ALTER TABLE 从表名 DROP FOREIGN KEY 外键约束名;

-- 第二步查看索引名和删除索引。（注意，只能手动删除）
SHOW INDEX FROM 表名称; -- 查看某个表的索引名

ALTER TABLE 从表名 DROP INDEX 索引名;
```

### 约束等级

- `CASCADE`：级联，即在父表上 `UPDATE/DELETE` 记录时，同步在子表匹配记录中进行  `UPDATE/DELETE` 操作。
- `SET NULL`：在父表上 `UPDATE/DELETE` 时，将子表上匹配记录的列设为 `NULL`。注意，子表的外键列不能有 `NOT NULL` 约束。
-  `NO ACTION`：如果子表中有匹配的记录，则不允许父表对应候选键进行 `UPDATE/DELETE` 操作
- `RESTRICT`：同 `NO ACTION`，都是立即检查外键约束
- `SET DEFAULT`：父表有变更时，子表将外键列设置成一个默认值，但 INNODB 不能识别。

如果没有指定约束等级，就相当于 `RESTRICT`。

> 对于外键约束，最好采用：`ON UPDATE CASCADE ON DELETE RESTRICT` 的方式

### 开发场景

**问题1：如果两个表之间有关系（一对一、一对多），比如：员工表和部门表（一对多），它们之间是否一定要建外键约束？**

答：不是的

**问题2：建和不建外键约束有什么区别？**

答：建外键约束，你的操作（创建表、删除表、添加、修改、删除）会受到限制，从语法层面受到限制。例如：在员工表中不可能添加一个员工信息，它的部门的值在部门表中找不到。

不建外键约束，你的操作（创建表、删除表、添加、修改、删除）不受限制，要保证数据的`引用完整性`，只能依`靠程序员的自觉`，或者是`在编程语言中进行限定`。例如：在员工表中，可以添加一个员工的信息，它的部门指定为一个完全不存在的部门。

**问题3：那么建和不建外键约束和查询有没有关系？**

答：没有

> 在 MySQL 里，外键约束是有成本的，需要消耗系统资源。对于大并发的 SQL 操作，有可能会不适合。比如大型网站的中央数据库，可能会`因为外键约束的系统开销而变得非常慢`。所以， MySQL 允许你不使用系统自带的外键约束，在`应用层面`完成检查数据一致性的逻辑。也就是说，即使你不用外键约束，也要想办法通过应用层面的附加逻辑，来实现外键约束的功能，确保数据的一致性。

### 阿里开发规范

【`强制`】不得使用外键与级联，一切外键概念必须在应用层解决。 

说明：（概念解释）学生表中的 student_id 是主键，那么成绩表中的 student_id 则为外键。如果更新学生表中的 student_id，同时触发成绩表中的 student_id 更新，即为级联更新。外键与级联更新适用于`单机低并发`，不适合`分布式`、`高并发集群`；级联更新是强阻塞，存在数据库`更新风暴`的风险；外键影响数据库的`插入速度`。

## `CHECK` 检查约束

MySQL 5.7 不支持，MySQL 8支持。

## `DEFAULT` 默认值约束

建表时：

```sql
CREATE TABLE 表名(
	字段名 数据类型 DEFAULT 默认值
);
```

建表后：

```sql
ALTER TABLE 表名 MODIFY 字段名 数据类型 DEFAULT 默认值 [NOT NULL];

-- 注意，如果有非空约束，一定要显式加上 `NOT NULL`，不然会被删除掉
```

删除：

```sql
alter table 表名称 modify 字段名 数据类型 ; -- 删除默认值约束，也不保留非空约束

alter table 表名称 modify 字段名 数据类型  not null; -- 删除默认值约束，保留非空约束
```

## 面试

**面试1、为什么建表时，加 `not null default ''` 或 `default 0`**

答：不想让表中出现`null`值。

**面试2、为什么不想要 `null` 的值**

答:
（1）不好比较。`null`是一种特殊值，比较时只能用专门的`is null` 和 `is not null`来比较。碰到运算符，通常返回`null`。

（2）效率不高。影响提高索引效果。因此，我们往往在建表时 `not null default ''` 或 `default 0`

**面试3、带`AUTO_INCREMENT`约束的字段值是从`1`开始的吗？**
在MySQL中，默认`AUTO_INCREMENT`的初始值是1，每新增一条记录，字段值自动加1。设置自增属性（`AUTO_INCREMENT`）的时候，还可以指定第一条插入记录的自增字段的值，这样新插入的记录的自增字段值从初始值开始递增，如在表中插入第一条记录，同时指定id值为5，则以后插入的记录的id值就会从6开始往上增加。添加主键约束时，往往需要设置字段自动增加属性。

**面试4、并不是每个表都可以任意选择存储引擎？**
外键约束（`FOREIGN KEY`）不能跨引擎使用。

MySQL支持多种存储引擎，每一个表都可以指定一个不同的存储引擎，需要注意的是：外键约束是用来保证数据的参照完整性的，如果表之间需要关联外键，却指定了不同的存储引擎，那么这些表之间是不能创建外键约束的。所以说，存储引擎的选择也不完全是随意的。

