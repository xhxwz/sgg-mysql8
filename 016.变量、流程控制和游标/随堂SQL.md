```sql
-- 查看全局系统变量
SHOW GLOBAL VARIABLES;
-- 查看会话系统变量
SHOW SESSION VARIABLES;
-- 默认查询的是会话系统变量
SHOW VARIABLES ;

-- 查看部分系统变量
SHOW GLOBAL  VARIABLES LIKE 'admin_%';
SHOW SESSION  VARIABLES  LIKE 'character_%';
SHOW VARIABLES LIKE 'character_%';

-- 查看指定变量的值
SELECT @@global.max_connections; -- 服务器最大连接数
SELECT @@session.pseudo_thread_id; -- 当前会话的的连接ID
SELECT @@global.character_set_client;
SELECT @@max_connections; -- 先查询 session，如果没有再查询 global 

-- 修改系统变量的值
SET @@global.max_connections = 151;
SET GLOBAL  max_connections = 151;

SET @@session.character_set_client = utf8mb4;
SET SESSION  character_set_client = utf8mb4;

-- 导入数据
CREATE TABLE employess
AS
SELECT  * from atguigudb.employees;

CREATE table departments
AS
SELECT * FROM atguigudb.departments;

-- 创建存储过程 get_count_by_limit_total_salary()
-- 声明IN参数 limit_total_salary，DOUBLE类型；
-- 声明OUT参数total_count，INT类型。
-- 函数的功能可以实现累加薪资最高的几个员工的薪资值，
-- 直到薪资总和达到limit_total_salary参数的值，
-- 返回累加的人数给total_count。

DELIMITER //

CREATE PROCEDURE get_count_by_limit_total_salary(IN limit_total_salary DOUBLE, OUT total_count INT)
BEGIN
	DECLARE sum_salary DOUBLE DEFAULT 0; -- 记录累加的总工资
	DECLARE cursor_salary DOUBLE DEFAULT 0; -- 记录某一个工资值
	DECLARE  emp_count INT DEFAULT 0; -- 记录循环个数
	
	-- 定义游标
	DECLARE emp_cursor CURSOR FOR SELECT salary FROM employess ORDER BY salary DESC;
	-- 打开游标
	OPEN emp_cursor;

	REPEAT
		-- 从游标中获取数据
		FETCH emp_cursor INTO cursor_salary;
	
		-- 累加
		SET sum_salary = sum_salary  + cursor_salary ;
		SET emp_count  = emp_count  + 1;
	
		UNTIL sum_salary >= limit_total_salary 
	END REPEAT ;

	set total_count  = emp_count ;
	-- 关闭游标
	CLOSE emp_cursor ;
END //


DELIMITER ;

CALL get_count_by_limit_total_salary(100000, @tc);
SELECT @tc;
```

