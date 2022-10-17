## 创建索引

**建表时**：

```sql
-- 创建索引
CREATE TABLE table_name [col_name data_type] 
[UNIQUE | FULLTEXT | SPATIAL] [INDEX | KEY] [index_name] (col_name [length]) [ASC | DESC]
```

- `UNIQUE`、`FULLTEXT`和`SPATIAL`为可选参数，分别表示唯一索引、全文索引和空间索引；
- `INDEX`与`KEY`为同义词，两者的作用相同，用来指定创建索引；
- `index_name`指定索引的名称，为可选参数，如果不指定，那么MySQL默认`col_name`为索引名；
- `col_name`为需要创建索引的字段列，该列必须从数据表中定义的多个列中选择；
- `length`为可选参数，表示索引的长度，只有字符串类型的字段才能指定索引长度；
- `ASC`或`DESC`指定升序或者降序的索引值存储。

举例：

```mysql
-- 1. 普通索引
CREATE TABLE book( 
    book_id INT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR, 
    INDEX idx_book_name(book_name)
);

-- 2. 显式创建唯一索引
CREATE TABLE book1( 
    book_id INT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR, 
    UNIQUE INDEX idx_book_name(book_name)
);

-- 3. 主键索引
-- 就是通过定义主键约束来实现
CREATE TABLE book2( 
    book_id INT PRIMARY KEY AUTO_INCREMENT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR
);

-- 4. 复合索引
CREATE TABLE book3( 
    book_id INT PRIMARY KEY AUTO_INCREMENT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR,
  	INDEX idx_id_bookname(book_id,book_name)
);

-- 5. 全文索引
CREATE TABLE book4( 
    book_id INT PRIMARY KEY AUTO_INCREMENT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR,
  	content TEXT NOT NULL,
  	FULLTEXT INDEX ft_idx_content(content)
);
-- 6. 部分内容建立索引 
CREATE TABLE book5( 
    book_id INT PRIMARY KEY AUTO_INCREMENT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR,
  	content TEXT NOT NULL,
  	FULLTEXT INDEX ft_idx_content(content(50)) -- 取前50个字符建立索引
);

-- 全文索引的查询方式
SELECT * FROM book5 WHERE
	MATCH(content) AGAINST('查询的内容');

-- 查看索引，方式1
SHOW CREATE TABLE book;
-- 查看索引，方式2
SHOW INDEX FROM book;
```

> 有关全文索引
>
> - 全文索引比 `LIKE` 快N倍，但是可能存在精度问题
> - 如果需要全文索引的是大量数据，建议先添加数据再创建索引
> - 查询方式 `WHERE MATCH(全文索引字段) AGAINST (查询内容)`

**建表后**：

```sql
-- 方式1
ALTER TABLE 表名 ADD ...

-- 方式2
CREATE INDEX ... ON 表名(字段)
```

举例：

```sql
-- 方式1
CREATE TABLE book6( 
    book_id INT PRIMARY KEY AUTO_INCREMENT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR,
  	content TEXT NOT NULL
);
-- 1. 普通索引
ALTER TABLE book6 ADD INDEX idx_bookname (book_name);

-- 2. 唯一索引
ALTER TABLE book6 ADD UNIQUE INDEX idx_uni_bookname (book_name);

-- 3. 联合索引
ALTER TABLE book6 ADD INDEX idx_id_bookname(book_id,book_name);

-- 4. 全文索引
ALTER TABLE book6 ADD FULLTEXT INDEX ft_idx_content(content);


-- 方式2
CREATE TABLE book7( 
    book_id INT PRIMARY KEY AUTO_INCREMENT , 
    book_name VARCHAR(100), 
    authors VARCHAR(100), 
    info VARCHAR(100) , 
    comment VARCHAR(100), 
    year_publication YEAR,
  	content TEXT NOT NULL
);
-- 1. 普通索引
CREATE INDEX idx_bookname ON book7(book_name);

-- 2. 唯一索引
CREATE UNIQUE INDEX idx_uni_bookname ON book7(book_name);
-- 3. 复合索引
CREATE INDEX idx_id_bookname ON book7(book_id,book_name);
-- 4. 全文索引
CREATE FULLTEXT INDEX ft_idx_content ON book7(content);
```

## 删除索引

```sql
-- 方式1
ALTER TABLE DROP INDEX 索引名;

-- 方式2
DROP INDEX 索引名 ON 表名;
```

举例：

```sql
ALTER TABLE book6 DROP INDEX ft_idx_content;

DROP INDEX idx_id_bookname ON book7;
```

## MySQL 8 索引新特性

- 降序索引

- 隐藏索引


## 索引的设计原则所需数据准备

```sql
-- 1. 数据库、表
CREATE DATABASE atguigudb1;
USE atguigudb1;
 -- 创建学生表和课程表
CREATE TABLE `student_info` (
 `id` INT(11) NOT NULL AUTO_INCREMENT,
 `student_id` INT NOT NULL ,
 `name` VARCHAR(20) DEFAULT NULL,
 `course_id` INT NOT NULL ,
 `class_id` INT(11) DEFAULT NULL,
 `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
CREATE TABLE `course` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`course_id` INT NOT NULL ,
`course_name` VARCHAR(40) DEFAULT NULL,
PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

set global log_bin_trust_function_creators=1;
-- 2. 存储函数
-- 随机产生字符串函数
DELIMITER //
CREATE FUNCTION rand_string(n INT)
RETURNS VARCHAR(255)  -- 该函数会返回一个字符串
BEGIN
    DECLARE chars_str VARCHAR(100) DEFAULT
'abcdefghijklmnopqrstuvwxyzABCDEFJHIJKLMNOPQRSTUVWXYZ';
DECLARE return_str VARCHAR(255) DEFAULT '';
DECLARE i INT DEFAULT 0;
    WHILE i < n DO
       SET return_str =CONCAT(return_str,SUBSTRING(chars_str,FLOOR(1+RAND()*52),1));
       SET i = i + 1;
    END WHILE;
    RETURN return_str;
END //
DELIMITER ;
-- 随机数函数
DELIMITER //
CREATE FUNCTION rand_num (from_num INT ,to_num INT) RETURNS INT(11) 
BEGIN
DECLARE i INT DEFAULT 0;
SET i = FLOOR(from_num +RAND()*(to_num - from_num+1)) ;
RETURN i;
END //
DELIMITER ;

-- 3. 存储过程
-- 插入课程表存储过程
DELIMITER //
CREATE PROCEDURE insert_course( max_num INT )
BEGIN
DECLARE i INT DEFAULT 0;
SET autocommit = 0; -- 设置手动提交事务
REPEAT -- 循环
SET i=i+1;  -- 赋值
INSERT INTO course (course_id, course_name ) VALUES
(rand_num(10000,10100),rand_string(6));
 UNTIL i = max_num
 END REPEAT;
COMMIT; -- 提交事务 
END //
DELIMITER ;
-- 插入学生信息表存储过程
DELIMITER //
CREATE PROCEDURE insert_stu( max_num INT ) 
BEGIN
DECLARE i INT DEFAULT 0;
SET autocommit = 0; -- 设置手动提交事务
REPEAT -- 循环
SET i=i+1; -- 赋值
INSERT INTO student_info (course_id, class_id ,student_id ,NAME ) VALUES
(rand_num(10000,10100),rand_num(10000,10200),rand_num(1,200000),rand_string(6)); UNTIL i = max_num
END REPEAT;
COMMIT; -- 提交事务
END //
DELIMITER ;

-- 调用存储过程
CALL insert_course(100);
CALL insert_stu(1000000);

SELECT COUNT(*) FROM course;
SELECT COUNT(*) FROM student_info;
```
## 适合创建索引的情况

### 1. 字段的数值有唯一性限制

索引本身可以起到约束的作用，比如唯一索引、主键索引，因此，在我们的数据表中，如果某一个字段是唯一性的，就可以直接创建唯一索引或者主键索引。这样可以更快速地通过该索引来确定某条记录。

> 业务上具有唯一特性的字段，即使是组合字段，也**必须**建成唯一索引。(来源:Alibaba) 
> 说明：不要以为唯一索引影响了 insert 速度，这个速度损耗可以忽略，但提高查找速度是明显的。

### 2. 频繁作为 `WHERE` 查询条件的字段

某个字段在`SELECT`语句的 `WHERE `条件中经常被使用到，那么就需要给这个字段创建索引了。尤其是在数据量大的情况下，创建普通索引就可以大幅提升数据查询的效率。

```sql
-- 1. 未创建索引
SELECT course_id, class_id, name, create_time, student_id
FROM student_info
WHERE student_id = 123110;
/*
4 rows in set (0.25 sec) <---
*/

-- 2. 给 student_id 创建索引
CREATE INDEX idx_student_info_id ON student_info(student_id);

-- 3. 创建索引后查询
SELECT course_id, class_id, name, create_time, student_id
FROM student_info
WHERE student_id = 123110;
/*
4 rows in set (0.01 sec) <---
*/

```

### 3. 经常 `GROUP BY` 和 `ORDER BY` 的字段

索引就是让数据按照某种顺序进行存储或检索，因此当我们使用 `GROUP BY` 对数据进行分组查询，或者 使用 `ORDER BY` 对数据进行排序的时候，就需要 对分组或者排序的字段进行索引 。如果待排序的列有多 个，那么可以在这些列上建立 组合索引 。

```sql
-- 无索引
DROP INDEX idx_student_info_id ON student_info;

SELECT student_id, COUNT(*) AS num
FROM student_info
GROUP BY student_id LIMIT 100;
/*
100 rows in set (2.17 sec)
*/

--  有索引
CREATE INDEX idx_student_info_id ON student_info(student_id);

SELECT student_id, COUNT(*) AS num
FROM student_info
GROUP BY student_id LIMIT 100;
/*
100 rows in set (0.01 sec)
*/
```

复合索引的选择：

```sql
SET @@sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- 无索引
DROP INDEX idx_student_info_id ON student_info;

SELECT student_id, COUNT(*) AS num
FROM student_info
GROUP BY student_id
ORDER BY create_time DESC
LIMIT 100;
/*
100 rows in set (2.52 sec)
*/

-- 分别设置索引
CREATE INDEX idx_student_info_id ON student_info(student_id);
CREATE INDEX idx_student_create_time ON student_info(create_time);

SELECT student_id, COUNT(*) AS num
FROM student_info
GROUP BY student_id
ORDER BY create_time DESC
LIMIT 100;
/*
100 rows in set (3.70 sec)
*/

-- 复合索引
DROP INDEX idx_student_info_id ON student_info;
DROP INDEX idx_student_create_time ON student_info;
CREATE INDEX idx_student_info_id_create_time ON student_info(student_id,create_time);

SELECT student_id, COUNT(*) AS num
FROM student_info
GROUP BY student_id
ORDER BY create_time DESC
LIMIT 100;
/*
100 rows in set (0.23 sec)
*/

-- 复合索引, 降序索引
DROP INDEX idx_student_info_id_create_time ON student_info;
CREATE INDEX idx_student_info_id_create_time ON student_info(student_id,create_time DESC);

SELECT student_id, COUNT(*) AS num
FROM student_info
GROUP BY student_id
ORDER BY create_time DESC
LIMIT 100;
/*
100 rows in set (0.27 sec)
*/
```

### 4. `UPDATE` 、 `DELETE` 的 `WHERE` 条件列

对数据按照某个条件进行查询后再进行 `UPDATE` 或 `DELETE` 的操作，如果对 `WHERE` 字段创建了索引，就 能大幅提升效率。原理是因为我们需要先根据 `WHERE` 条件列检索出来这条记录，然后再对它进行更新或 删除。 **如果进行更新的时候，更新的字段是非索引字段，提升的效率会更明显，这是因为非索引字段更 新不需要对索引进行维护。**

```sql
-- 无索引
UPDATE student_info SET student_id = 12345
WHERE name='foo.bar';
/*
Query OK, 0 rows affected (0.68 sec)
*/

-- 有索引
CREATE INDEX idx_student_name ON student_info(name);

UPDATE student_info SET student_id = 12345
WHERE name='foo.bar';
/*
Query OK, 0 rows affected (0.00 sec)
*/
```

### 5. `DISTINCT` 字段需要创建索引

在使用 `DISTINCT` 对某字段进行去重时，对这个字段创建索引，将会提升查询效率。

### 6. 多表 `JOIN` 连接操作时，创建索引注意事项

- 首先，连接表的数量尽量不要超过3张。因为每增加一张表就相当于增加了一次嵌套的循环，数量级增长会非常快，严重影响查询效率
- 其次，对 `WHERE` 条件创建索引。因为 `WHERE` 才是对数据条件的过滤。如果在数据量非常大的情况下，没有 `WHERE` 条件过滤是非常可怕的
- 最后，对用于连接的字段创建索引，并且该字段在多张表中的类型必须一致。

### 7. 使用列的类型小的创建索引

如果想要给某个整数列建立索引的话，在表示的整数范围允许的情况下，尽量让索引列使用较小的类型，比如能使用 `INT`  就不要使用 `BIGINT`。

- 数据类型越小，在查询时进行的比较操作越快
- 数据类型越小，索引占用的存储空间就越少，在一个数据页内就可以放下更多的记录，从而减少I/O带来的性能损耗，也就意味着可以把更多的数据页缓存在内存中，从而加快读写效率。

这个建议对于主键来说更加适用，因为不仅是聚簇索引中会存储主键值，其它所有索引的节点都会进行存储。

### 8. 使用字符串前缀创建索引

假设字符串很长，那么存储它就需要占用很大的存储空间。在需要为其建立索引时，那就意味着在对应`B+树`中有两个问题：

- `B+树` 索引中的记录需要把该列的完整字符串存储起来，更费时。而且字符串越长，在索引中占用的存储空间越大。
- 如果 `B+树`索引中，索引列存储的字符串很长，那在做字符串比较时会占用更多时间。

我们可以通过截取字段的前面一部分内容建立索引，这个就叫前缀索引。这样在查询记录时，虽然不能精确的定位到记录的位置，但是能定位到相应前缀所在的位置，然后根据前缀相同的记录的主键值回表查询完整的字符串值。既节约空间，又减少了字符串的比较时间，还大体能解决排序的问题。

例如，`TEXT` 和 `BLOG` 类型的字段，进行全文检索会很浪费时间，如果只检索字段前面若干字符，这样就可以提高检索速度。


问题是，截取多少呢?截取得多了，达不到节省索引存储空间的目的;截取得少了，重复内容太多，字 段的散列度(选择性)会降低。 **怎么计算不同的长度的选择性呢?**

先看一下字段在全部数据中的选择度：

```sql
SELECT COUNT(DISTINCT 字段) / COUNT(*) FROM 表;
```

通过不同长度去计算，与全表的选择性对比，结果越接近1越好。公式如下：

```sql
COUNT(DISTINCT LEFT(字段, 索引长度)) / COUNT(*)
```

举例：

```sql
CREATE TABLE shop(address VARCHAR(120) NOT NULL);

select count(distinct left(address,10)) / count(*) as sub10, -- 截取前10个字符的选择度 
count(distinct left(address,15)) / count(*) as sub11, -- 截取前15个字符的选择度 
count(distinct left(address,20)) / count(*) as sub12, -- 截取前20个字符的选择度 
count(distinct left(address,25)) / count(*) as sub13 -- 截取前25个字符的选择度
from shop;

CREATE INDEX idx_shop_addr ON shop(address(12)); 
```

引申另一个问题：索引列前缀对排序的影响：

如果使用了前缀索引，比如例中把 `address`列的前12个字符放到了二级索引中，下边的查询可能就有点尴尬了：

```sql
SELECT * FROM shop
ORDER BY address
LIMIT 12;
```

因为二级索引中不包含完整的 `address` 列信息，所以无法对前12个字符相同，后边字符不同的记录进行排序，也就是使用前缀索引的方式无法支持使用索引排序，只能使用文件排序。

#### 阿里

- 【 `强制` 】在 `varchar` 字段上建立索引时，必须指定索引长度，没必要对全字段建立索引，根据实际文本区分度决定索引长度。
说明: 索引的长度与区分度是一对矛盾体，一般对字符串类型数据，长度为 20 的索引，区分度会 高达 90% 以上，可以使用`count(distinctleft(列名,索引长度))/count(*)` 的区分度来确定。

### 9. 区分度高（散列性高）的列适合作为索引

列的基数指的是某一列中不重复数据的个数，比如某个列包含`2, 5, 8, 2, 5, 8, 2, 5, 8`，虽然有9条记录，但该列的基数去是3.也就是说，**在记录行数一定的情况下，列的基数越大，该列中的值越分散；列的基数越小，该列中的值越集中**。最好为基数大的列建立索引，为基数小的列建立索引效果可能不好。

可以使用下面的公式计算区分度，越接近1越好，一般超过 `33%` 就算是比较高效的索引了：

```sql
SELECT COUNT(DISTINCT 字段) / COUNT(*) FROM 表;
```

拓展：联合索引把区分度高的列放在前面。

### 10. 使用最频繁的列放在联合索引的左侧

这样也可以较少的建立一些索引。同时，由于"最左前缀原则"，可以增加联合索引的使用率。

### 11. 在多个字段都要创建索引的情况下，联合索引优于单列索引

## 限制索引的数目

建议**单张表索引数量不超过6个**：

- 每个索引都需要占用磁盘空间，索引越多，需要的磁盘空间越大
- 索引会影响 `INSERT/UPDATE/DELETE` 等语句的性能，因为表中数据理性的同时，索引也会进行调整和更新，会造成负担
- 优化器在选择如何优化查询时，会根据统一信息，对每一个可以用到的索引进行评估，以生成一个最好的执行计划。如果同时有多个索引都通过了评估，会增加优化器生成执行计划的时间，降低查询性能。

## 不适合创建索引的情况

### 1. 在 `WHERE` 中使用不到的字段

`WHERE`条件，包括 `GROUP BY`, `ORDER BY`，用不到的字段不要设置索引。

### 2. 数据量小的表最好不要使用索引

> 在数据表中的数据行数较少的情况下，比如不到 1000 行，是不需要创建索引的。

### 3. 有大量重复数据的列上不要创建索引

举例1: 要在 100 万行数据中查找其中的 50 万行(比如性别为男的数据)，一旦创建了索引，你需要先访问 50 万次索引，然后再访问 50 万次数据表，这样加起来的开销比不使用索引可能还要大。 

举例2: 假设有一个学生表，学生总数为 100 万人，男性只有 10 个人，也就是占总人口的 10 万分之 1。

> 当数据重复度大，比如 `> 10%` 时，不需要对这个字段创建索引

### 4. 避免对经常更新的表创建过多的索引

- 频繁更新的字段不一定要创建索引。因为更新数据的时候，也需要更新索引，如果索引太多，在更新索引的时候也会造成负担，从而影响效率
- 避免经常更新的表创建过多的索引，并且索引中的列尽可能少。此时，虽然提高了查询速度，同时却降低更新表的速度

### 5. 不建议用无序的值作为索引

例如身份证、UUID(在索引比较时需要转为ASCII，并且插入时可能造成页分裂)、MD5、HASH、无序长字 符串等。

### 6. 删除不再使用或者很少使用的索引

### 7. 不要定义冗余或重复的索引

**冗余索引**：

```sql
CREATE TABLE person_info(
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    birthday DATE NOT NULL,
    phone_number CHAR(11) NOT NULL,
    country varchar(100) NOT NULL,
    PRIMARY KEY (id),
    KEY idx_name_birthday_phone_number (name(10), birthday, phone_number),
    KEY idx_name (name(10))
);
```

通过 `idx_name_birthday_phone_number` 就可以对 `name` 进行快速搜索，没必要再创建单独的`idx_name` 索引

**重复索引**

```sql
CREATE TABLE repeat_index_demo (
    col1 INT PRIMARY KEY,
    col2 INT,
    UNIQUE uk_idx_c1 (col1),
    INDEX idx_c1 (col1)
);
```

我们看到，`col1` 既是主键、又给它定义为一个唯一索引，还给它定义了一个普通索引，可是主键本身就 会生成聚簇索引，所以定义的唯一索引和普通索引是重复的，这种情况要避免。
