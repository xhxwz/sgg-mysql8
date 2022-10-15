```sql
CREATE TABLE sales (
	id INT PRIMARY KEY AUTO_INCREMENT,
	city VARCHAR(15),
	county VARCHAR(15),
	sales_value DECIMAL
);

INSERT INTO sales (city, county, sales_value)
VALUES
	('北京','海淀',10.00),
	('北京','朝阳',20.00),
	('上海','黄埔',30.00),
	('上海','长宁',10.00);

SELECT * from sales;

CREATE TABLE sales (
	id INT PRIMARY KEY AUTO_INCREMENT,
	city VARCHAR(15),
	county VARCHAR(15),
	sales_value DECIMAL
);

INSERT INTO sales (city, county, sales_value)
VALUES
	('北京','海淀',10.00),
	('北京','朝阳',20.00),
	('上海','黄埔',30.00),
	('上海','长宁',10.00);

SELECT * from sales;

-- 1. 窗口函数

-- 1.1 计算这个网站在每个城市的销售总额、
-- 在全国的销售总额、
-- 每个区的销售额占所在城市销售额中的比率，
-- 以及占总销售额中的比率。

-- 1.1.1 传统方式

-- 计算总销售金额，并存入临时表 a
CREATE TEMPORARY TABLE a -- 创建临时表
SELECT SUM(sales_value) AS sales_value 
FROM sales ;

SELECT * FROM a;

-- 计算每个城市的销售总额并存入临时表 b
CREATE TEMPORARY TABLE b
SELECT city, SUM(sales_value) AS sales_value
FROM sales
GROUP BY city; 

SELECT * FROM b;

-- 计算各区的销售占所在城市的总计金额的比例，和占全部销售总计金额的比例。我们可以通过下面的连接查询获得需要的结果：

SELECT 
	s.city AS 城市, s.county AS 区, s.sales_value AS 区销售销售额,
	b.sales_value AS 市销售额, s.sales_value / b.sales_value AS 市比例,
	a.sales_value AS 总销售额, s.sales_value / a.sales_value AS 总比例
FROM sales AS s
JOIN b ON s.city =b.city
JOIN a
ORDER BY s.city,s.county;

-- 1.1.2 窗口函数

SELECT 
	city as 城市, county as 区, sales_value AS 区销售额,
	SUM(sales_value) OVER (PARTITION BY city) AS 市销售额, -- 计算市销售额
	sales_value /SUM(sales_value) OVER(PARTITION BY city) AS 市比率,
	SUM(sales_value) OVER () AS 总销售额, -- 计算总销售额
	sales_value /SUM(sales_value) OVER() as 总比率
FROM 
	sales 
ORDER BY city,county ;

-- 2. 介绍窗口函数

CREATE TABLE goods(
id INT PRIMARY KEY AUTO_INCREMENT,
category_id INT,
category VARCHAR(15),
NAME VARCHAR(30),
price DECIMAL(10,2),
stock INT,
upper_time DATETIME
);

INSERT INTO goods(category_id,category,NAME,price,stock,upper_time)
VALUES
(1, '女装/女士精品', 'T恤', 39.90, 1000, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '连衣裙', 79.90, 2500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '卫衣', 89.90, 1500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '牛仔裤', 89.90, 3500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '百褶裙', 29.90, 500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '呢绒外套', 399.90, 1200, '2020-11-10 00:00:00'),
(2, '户外运动', '自行车', 399.90, 1000, '2020-11-10 00:00:00'),
(2, '户外运动', '山地自行车', 1399.90, 2500, '2020-11-10 00:00:00'),
(2, '户外运动', '登山杖', 59.90, 1500, '2020-11-10 00:00:00'),
(2, '户外运动', '骑行装备', 399.90, 3500, '2020-11-10 00:00:00'),
(2, '户外运动', '运动外套', 799.90, 500, '2020-11-10 00:00:00'),
(2, '户外运动', '滑板', 499.90, 1200, '2020-11-10 00:00:00');

-- 2.1 序列函数
-- 2.1.1 ROW_NUMBER：
-- 查询 goods 数据表中每个商品分类下价格降序排列的各个商品信息。
SELECT
	ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS row_num,
	id, category_id, category , name, price, stock 
FROM 
	goods ;
-- 查询 goods 数据表中每个商品分类下价格最高的3种商品信息。
SELECT * FROM 
	( SELECT 
		ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS row_num,
		id, category_id, category , name, price, stock 
	FROM goods ) AS t
WHERE 
	row_num<=3;
-- 2.1.2 RANK
-- 使用 RANK() 查询 goods 数据表中每个商品分类下价格降序排列的各个商品信息。
SELECT
	RANK() OVER (PARTITION BY category_id ORDER BY price DESC) AS row_num,
	id, category_id, category , name, price, stock 
FROM 
	goods ;
-- 2.1.3 DENSE_RANK
SELECT
	DENSE_RANK() OVER (PARTITION BY category_id ORDER BY price DESC) AS row_num,
	id, category_id, category , name, price, stock 
FROM 
	goods ;

-- 2.2 分布函数
-- 2.2.1  PERCENT_RANK()
-- 计算 goods 数据表中名称为“女装/女士精品”的类别下的商品的PERCENT_RANK值。
-- 写法1
SELECT
	RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS r,
	PERCENT_RANK() OVER (PARTITION BY category_id ORDER BY price DESC) AS pr,
	price,id, category_id, category , name, stock 
FROM 
	goods 
WHERE category_id =1;	

-- 写法2
SELECT 
	RANK() OVER w AS r,
	PERCENT_RANK() OVER w AS pr,
price,id, category_id, category , name, stock 
FROM 
	goods 
WHERE category_id =1 WINDOW w AS (PARTITION BY category_id ORDER BY price DESC);

-- 2.2.2 CUME_DIST
-- 查询goods数据表中，小于或等于当前价格的比例
SELECT
	CUME_DIST() OVER (PARTITION BY category_id ORDER BY price ASC) AS cd,
	price,id, category_id, category , name, stock 
FROM 
	goods ;
	
-- 2.3 前后函数
-- 2.3.1  LAG
-- 查询goods数据表中前一个商品价格与当前商品价格的差值
 SELECT 
 	id, category, name, price, pre_price, price - pre_price AS diff_price
 FROM (
  	SELECT  id, category, name, price, LAG(price,1) OVER w AS pre_price
 FROM goods
	WINDOW w AS (PARTITION BY category_id ORDER BY price)) t;
-- 2.3.2  LEAD
-- 查询goods数据表中后一个商品价格与当前商品价格的差值
SELECT id, category, name, behind_price, price,behind_price - price AS diff_price
     FROM(
      SELECT id, category, name, price,LEAD(price, 1) OVER w AS behind_price
      FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price)) t;
      
-- 2.4 首尾函数
-- 2.4.1  FIRST_VALUE
-- 按照价格排序，查询第1个商品的价格信息
SELECT id, category, name, price, stock,FIRST_VALUE(price) OVER w AS first_price
 FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);
-- 2.4.2 LAST_VALUE
-- 按照价格排序，查询最后一个商品的价格信息。
SELECT id, category, name, price, stock,LAST_VALUE(price) OVER w AS last_price
 FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);
 

-- 2.5 其它函数
-- 2.5.1 NTH_VALUE(expr,n)
-- 举例：查询goods数据表中排名第2和第3的价格信息。
SELECT id, category, NAME, price,NTH_VALUE(price,2) OVER w AS second_price,
    NTH_VALUE(price,3) OVER w AS third_price
    FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);
-- 2.5.2 NTILE(n)
-- 举例：将goods表中的商品按照价格分为3组。
 SELECT NTILE(3) OVER w AS nt,id, category, NAME, price
     FROM goods WINDOW w AS (PARTITION BY category_id ORDER BY price);
```

