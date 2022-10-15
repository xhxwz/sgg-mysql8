## 准备工作

```sql
CREATE TABLE IF NOT EXISTS emp1 (
	id INT,
  name VARCHAR(15),
  hire_date DATE,
  salary DOUBLE(10,2)
)ENGINE=INNODB CHARSET=UTF8;
```

## 逐条添加

```sql
INSERT INTO emp1 
	(id, name, hire_date, salary)
VALUES
	(1, '张三', '2002-10-03', 1200),
	(2, '李四', '2002-10-04', 1500),
	(3, '王五', '2004-03-21', 1800)
;


CREATE TABLE tmp_urls (
	url VARCHAR(255) UNIQUE
)CHARSET=utf8mb4;
```

## 将查询结果插入到表中

```sql
INSERT INTO emp1
	(id, name, hire_date, salary)
SELECT 
	employee_id, last_name, hire_date, salary
FROM 
	employees;
```

## MySQL8新特性：计算列

某一列的值是通过别的列计算得来。

MySQL8 的 `CREATE TABLE` 和  `ALTER TABLE` 都支持增加计算列。

```sql
CREATE TABLE IF NOT EXISTS tb1(
	id INT,
  a INT,
  b INT,
  c INT GENERATED ALWAYS AS (a+b) VIRTUAL -- 计算列
);

INSERT INTO tb1(id,a,b) 
VALUES (1,11,22),(2,22,33),(3,44,55);

select * from tb1;
/*
+------+------+------+------+
| id   | a    | b    | c    |
+------+------+------+------+
|    1 |   11 |   22 |   33 |
|    2 |   22 |   33 |   55 |
|    3 |   44 |   55 |   99 |
+------+------+------+------+
*/

UPDATE tb1 SET a=99 where id=1;

SELECT * FROM tb1;
/*
+------+------+------+------+
| id   | a    | b    | c    |
+------+------+------+------+
|    1 |   99 |   22 |  121 |
|    2 |   22 |   33 |   55 |
|    3 |   44 |   55 |   99 |
+------+------+------+------+
*/
```

## 综合案例

```sql
# 1、创建数据库 test01_library
CREATE DATABASE IF NOT EXISTS test01_library CHARSET=utf8mb3;

USE test01_library;

# 2、创建表 books
CREATE TABLE IF NOT EXISTS books(
  id int COMMENT '书编号',
  name VARCHAR(50) COMMENT '书名',
  authors VARCHAR(100) COMMENT '作者',
  price FLOAT COMMENT '价格',
  pubdate YEAR comment '出版日期',
  note VARCHAR(100) COMMENT '说明',
  num INT COMMENT '库存'
)ENGINE=INNODB CHARSET=utf8mb3;
# 3、向books表中插入记录
# 1）不指定字段名称，插入第一条记录
INSERT INTO books 
VALUES
	(1, 'Tal of AAA', 'Dickes', 23, 1995, 'novel', 11);
# 2）指定所有字段名称，插入第二记录
INSERT INTO books 
	(id,name,authors,price,pubdate,note,num)
VALUES
	(2, 'EmmaT', 'Jane lura', 35, 1993, 'joke', 12);
# 3）同时插入多条记录（剩下的所有记录）
INSERT INTO books 
	(id,name,authors,price,pubdate,note,num)
VALUES
	(3, 'Stroy Of Jane', 'Jane Tim', 40, 2001, 'novel', 0),
	(4, 'Lovey Day', 'George Byron', 20, 2005, 'novel', 30),
	(5, 'Old land', 'Honore Blade', 30, 2010, 'law', 0),
	(6, 'The Battle', 'Upton Sara', 30, 1999, 'medicine', 40),
	(7, 'Rose Hood', 'Richard haggard', 28, 2008, 'cartoon', 28);

# 4、将小说类型(novel)的书的价格都增加5。
UPDATE books SET price=price+5 WHERE note='novel';


# 5、将名称为EmmaT的书的价格改为40，并将说明改为drama。
UPDATE books SET price=40, note='drama' WHERE name='EmmaT';


# 6、删除库存为0的记录。
DELETE FROM books WHERE num=0;

# 7、统计书名中包含a字母的书
SELECT name FROM books WHERE name LIKE '%a%';

# 8、统计书名中包含a字母的书的数量和库存总量
SELECT COUNT(*), SUM(num) FROM books WHERE name LIKE '%a%';

# 9、找出“novel”类型的书，按照价格降序排列
SELECT * FROM books WHERE note='novel' ORDER BY price DESC;

# 10、查询图书信息，按照库存量降序排列，如果库存量相同的按照note升序排列
SELECT * FROM books ORDER BY num DESC,note ASC;

# 11、按照note分类统计书的数量
SELECT note,COUNT(*) FROM books GROUP BY note;

# 12、按照note分类统计书的库存量，显示库存量超过30本的
SELECT note,SUM(num) AS sum_num FROM books GROUP BY note HAVING sum_num>30;

# 13、查询所有图书，每页显示5本，显示第二页
SELECT * FROM books LIMIT 5,5;


# 14、按照note分类统计书的库存量，显示库存量最多的
-- SELECT note,SUM(num) AS sum_num FROM books
-- GROUP BY note
-- HAVING sum_num >= ALL (
-- 	SELECT SUM(num) FROM books
--   GROUP BY note
-- )

SELECT note,SUM(num) AS sum_num FROM books
GROUP BY note 
ORDER BY sum_num desc
LIMIT 1;

# 15、查询书名达到10个字符的书，不包括里面的空格
SELECT * FROM books WHERE CHAR_LENGTH(REPLACE(name,' ','')) >= 10;

# 16、查询书名和类型，其中note值为novel显示小说，law显示法律，medicine显示医药，cartoon显示卡通，joke显示笑话
SELECT name,
	CASE note
		WHEN 'novel' THEN '小说'
		WHEN 'law' THEN '法律'
		WHEN 'medicine' THEN '医药'
		WHEN 'cartoon' THEN '卡通'
		WHEN 'joke' THEN '笑话'
		ELSE note
	END AS category
FROM books;

# 17、查询书名、库存，其中num值超过30本的，显示滞销，大于0并低于10的，显示畅销，为0的显示需要无货
SELECT name, num,
	CASE
		WHEN num >= 30 THEN '滞销'
		WHEN num > 0 AND num < 10 THEN '畅销'
		WHEN num = 0 THEN '无货'
		ELSE '正常'
	END AS '库存'
FROM books;

# 18、统计每一种note的库存量，并合计总量
SELECT IFNULL(note,'合计') AS note, SUM(num)
	FROM books 
GROUP BY note WITH ROLLUP;

# 19、统计每一种note的数量，并合计总量
SELECT IFNULL(note,'合计') AS note, COUNT(*)
FROM books 
GROUP BY note WITH ROLLUP;

# 20、统计库存量前三名的图书
SELECT * FROM books
ORDER BY num DESC
LIMIT 3;

# 21、找出最早出版的一本书
SELECT * FROM books ORDER BY pubdate ASC LIMIT 1

# 22、找出novel中价格最高的一本书
SELECT * FROM books
WHERE note='novel'
ORDER BY price DESC
LIMIT 1;

# 23、找出书名中字数最多的一本书，不含空格
SELECT * FROM books 
ORDER BY CHAR_LENGTH(REPLACE(name, ' ', '')) DESC
LIMIT 1;
```

