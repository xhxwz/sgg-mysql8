## 存储过程

```sql
CREATE PROCEDURE 存储过程名(IN|OUT|INOUT 参数名 参数类型,...)
[characteristics ...]
BEGIN
	存储过程体

END
```

说明：

1、参数前面的符号的意思

- `IN`：当前参数为输入参数，也就是表示入参；

  存储过程只是读取这个参数的值。如果没有定义参数种类，`默认就是 IN`，表示输入参数。

- `OUT`：当前参数为输出参数，也就是表示出参；

  执行完成之后，调用这个存储过程的客户端或者应用程序就可以读取这个参数返回的值了。

- `INOUT`：当前参数既可以为输入参数，也可以为输出参数。

2、形参类型可以是 MySQL数据库中的任意类型。

3、`characteristics` 表示创建存储过程时指定的对存储过程的约束条件，其取值信息如下：

```mysql
LANGUAGE SQL
| [NOT] DETERMINISTIC
| { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
| SQL SECURITY { DEFINER | INVOKER }
| COMMENT 'string'
```

- `LANGUAGE SQL`：说明存储过程执行体是由SQL语句组成的，当前系统支持的语言为SQL。
- `[NOT] DETERMINISTIC`：指明存储过程执行的结果是否确定。DETERMINISTIC表示结果是确定的。每次执行存储过程时，相同的输入会得到相同的输出。NOT DETERMINISTIC表示结果是不确定的，相同的输入可能得到不同的输出。如果没有指定任意一个值，默认为NOT DETERMINISTIC。
- `{ CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }`：指明子程序使用SQL语句的限制。
  - `CONTAINS SQL`表示当前存储过程的子程序包含SQL语句，但是并不包含读写数据的SQL语句；
  - `NO SQL`表示当前存储过程的子程序中不包含任何SQL语句；
  - `READS SQL DAT`A表示当前存储过程的子程序中包含读数据的SQL语句；
  - `MODIFIES SQL DATA`表示当前存储过程的子程序中包含写数据的SQL语句。
  - 默认情况下，系统会指定为`CONTAINS SQ`L。
- `SQL SECURITY { DEFINER | INVOKER }`：执行当前存储过程的权限，即指明哪些用户能够执行当前存储过程。
  - `DEFINER`表示只有当前存储过程的创建者或者定义者才能执行当前存储过程；
  - `INVOKER`表示拥有当前存储过程的访问权限的用户能够执行当前存储过程。
  - 如果没有设置相关的值，则MySQL默认指定值为`DEFINE`R。
- `COMMENT 'string'`：注释信息，可以用来描述存储过程。

4、存储过程体中可以有多条 SQL 语句，如果仅仅一条SQL 语句，则可以省略 `BEGIN` 和 `END`

编写存储过程并不是一件简单的事情，可能存储过程中需要复杂的 SQL 语句。

```mysql
1. BEGIN…END：BEGIN…END 中间包含了多个语句，每个语句都以（;）号为结束符。
2. DECLARE：DECLARE 用来声明变量，使用的位置在于 BEGIN…END 语句中间，而且需要在其他语句使用之前进行变量的声明。
3. SET：赋值语句，用于对变量进行赋值。
4. SELECT… INTO：把从数据表中查询的结果存放到变量中，也就是为变量赋值。
```

5、需要设置新的结束标记

```mysql
DELIMITER 新的结束标记
```

因为MySQL默认的语句结束符号为分号`;`。为了避免与存储过程中SQL语句结束符相冲突，需要使用`DELIMITER`改变存储过程的结束符。

比如：`DELIMITER //`语句的作用是将MySQL的结束符设置为`//`，并以`END //`结束存储过程。存储过程定义完毕之后再使用`DELIMITER ;`恢复默认结束符。`DELIMITER`也可以指定其他符号作为结束符。

当使用`DELIMITER`命令时，应该避免使用反斜杠（`\`）字符，因为反斜线是MySQL的转义字符。

示例：

```mysql
DELIMITER $

CREATE PROCEDURE 存储过程名(IN|OUT|INOUT 参数名  参数类型,...)
[characteristics ...]
BEGIN
	sql语句1;
	sql语句2;

END $
```

调用存储过程

```mysql
CALL 存储过程名(实参列表)
```

**格式：**

1、调用in模式的参数：

```mysql
CALL sp1('值');
```

2、调用out模式的参数：

```mysql
SET @name;
CALL sp1(@name);
SELECT @name;
```

3、调用inout模式的参数：

```mysql
SET @name=值;
CALL sp1(@name);
SELECT @name;
```

举例

```sql
-- 准备工作
CREATE DATABASE dbtest15;
USE dbtest15;

CREATE TABLE employees
AS
SELECT * FROM atguigudb.employees;

CREATE TABLE departments
AS 
SELECT * FROM atguigudb.departments;

-- 1. 创建存储过程 select_all_data()，查看 employees 表的所有数据
DELIMITER $
CREATE PROCEDURE select_all_data()
BEGIN
	SELECT * FROM employees;
END $
DELIMITER ;

-- 2. 创建存储过程 avg_employee_salary()，返回所有员工的平均工资
DELIMITER $
CREATE PROCEDURE avg_employee_salary()
BEGIN
	SELECT AVG(salary) FROM employees;
END $
DELIMITER ;

-- 3. 创建存储过程 show_max_salary()，用来查看员工表的最高薪资值
DELIMITER //
CREATE PROCEDURE show_max_salary()
BEGIN
	SELECT MAX(salary) FROM employees;
END //
DELIMITER ;

-- 4. 创建存储过程 show_min_salary()，查看员工表的最低薪资值。并将最低薪资通过OUT参数 ms 输出
DELIMITER //
CREATE PROCEDURE show_min_salary(OUT ms DOUBLE(8,2))
BEGIN
	SELECT MIN(salary) INTO ms FROM employees;
END //
DELIMITER ;
-- 调用
CALL show_min_salary(@ms);
SELECT @ms;

-- 5. 创建存储过程 show_someone_salary()，查看某个员工的薪资，并用IN参数 empname 输入员工姓名。
DELIMITER //
CREATE PROCEDURE show_someone_salary(IN empname varchar(25))
BEGIN
	SELECT salary FROM employees WHERE last_name=empname;
END //
DELIMITER ;
-- 调用方式1
CALL show_someone_salary('King');
-- 调用方式2
SET @empname = 'King';
-- 或 SET @empname := 'King';
CALL show_someone_salary(@empname);

-- 6. ：创建存储过程 show_someone_salary2() ，查看某个员工的薪资，并用IN参数 empname 输入员工姓名，用OUT参数 empsalary 输出员工薪资。
DELIMITER //
CREATE PROCEDURE show_someone_salary2(IN empname varchar(25), OUT empsalary DOUBLE)
BEGIN
	SELECT salary INTO empsalary FROM employees WHERE last_name=empname;
END //
DELIMITER ;

-- 调用1
CALL show_someone_salary2('Bell', @empsalary);
SELECT @empsalary;
-- 调用2
SET @empname := 'Bell';
CALL show_someone_salary2(@empname, @empsalary);
SELECT @empname, @empsalary;

-- 7. 创建存储过程 show_mgr_name()，查询某个员工领导的姓名，并用INOUT参数 empname 输入员工姓名，输出领导的姓名。

DELIMITER //
CREATE PROCEDURE show_mgr_name(INOUT empname varchar(25))
BEGIN
	SELECT m.last_name INTO empname
	FROM employees AS e
	JOIN
		employees AS m
	ON e.manager_id=m.employee_id
	WHERE e.last_name = empname;
END //
DELIMITER ;
-- 调用
SET @empname:="Abel";
CALL show_mgr_name(@empname);
SELECT @empname;
```

## 存储函数

语法格式：

```mysql
CREATE FUNCTION 函数名(参数名 参数类型,...) 
RETURNS 返回值类型
[characteristics ...]
BEGIN
	函数体   #函数体中肯定有 RETURN 语句

END
```

说明：

1、参数列表：指定参数为`IN`、`OUT`或`INOUT`只对`PROCEDURE`是合法的，`FUNCTION`中总是默认为IN参数。

2、`RETURNS type` 语句表示函数返回数据的类型；

`RETURNS`子句只能对`FUNCTION`做指定，对函数而言这是`强制`的。它用来指定函数的返回类型，而且函数体必须包含一个`RETURN value`语句。

3、`characteristi`c 创建函数时指定的对函数的约束。取值与创建存储过程时相同，这里不再赘述。

4、函数体也可以用`BEGIN…END`来表示SQL代码的开始和结束。如果函数体只有一条语句，也可以省略`BEGIN…END`。

调用存储函数：

```mysql
SELECT 函数名(实参列表)
```

**注意：**

若在创建存储函数中报错“`you might want to use the less safe log_bin_trust_function_creators variable`”，有两种处理方法：

- 方式1：加上必要的函数特性`[NOT] DETERMINISTIC”和“{CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA}`


- 方式2：


```mysql
mysql> SET GLOBAL log_bin_trust_function_creators = 1;
```

举例：

```sql
-- 1. 创建存储函数，名称为 email_by_name()，参数定义为空，该函数查询Abel的email，并返回，数据类型为字符串型。
DELIMITER //
CREATE FUNCTION email_by_name()
RETURNS VARCHAR(25)
DETERMINISTIC
CONTAINS SQL
BEGIN
	RETURN (SELECT email FROM employees WHERE last_name='Abel');
END //
DELIMITER ;

SELECT email_by_name();

-- 2. 创建存储函数，名称为 email_by_id()，参数传入 emp_id，该函数查询emp_id的email，并返回，数据类型为字符串型

DELIMITER //
CREATE FUNCTION email_by_id(emp_id INT)
RETURNS VARCHAR(25)
DETERMINISTIC
CONTAINS SQL
BEGIN
	RETURN (SELECT email FROM employees WHERE employee_id=emp_id);
END //
DELIMITER ;

SELECT email_by_id(137);

-- 3. 创建存储函数 count_by_id()，参数传入dept_id，该函数查询dept_id部门的员工人数，并返回，数据类型为整型。

DELIMITER //
CREATE FUNCTION count_by_id(dept_id INT)
RETURNS INT
DETERMINISTIC
CONTAINS SQL
BEGIN
	RETURN (SELECT COUNT(*) FROM employees WHERE department_id=dept_id);
END //
DELIMITER ;

SELECT count_by_id(60);
```

## 存储过程和函数的查看、修改、删除

**1. 使用SHOW CREATE语句查看存储过程和函数的创建信息**

基本语法结构如下：

```mysql
SHOW CREATE {PROCEDURE | FUNCTION} 存储过程名或函数名
```

举例：

```mysql
SHOW CREATE FUNCTION test_db.CountProc \G
```

**2. 使用SHOW STATUS语句查看存储过程和函数的状态信息**

基本语法结构如下：

```mysql
SHOW {PROCEDURE | FUNCTION} STATUS [LIKE 'pattern']
```

这个语句返回子程序的特征，如数据库、名字、类型、创建者及创建和修改日期。

[LIKE 'pattern']：匹配存储过程或函数的名称，可以省略。当省略不写时，会列出MySQL数据库中存在的所有存储过程或函数的信息。
举例：SHOW STATUS语句示例，代码如下：

```mysql
mysql> SHOW PROCEDURE STATUS LIKE 'SELECT%' \G 
*************************** 1. row ***************************
                  Db: test_db
                Name: SelectAllData
                Type: PROCEDURE
             Definer: root@localhost
            Modified: 2021-10-16 15:55:07
             Created: 2021-10-16 15:55:07
       Security_type: DEFINER
             Comment: 
character_set_client: utf8mb4
collation_connection: utf8mb4_general_ci
  Database Collation: utf8mb4_general_ci
1 row in set (0.00 sec)
```

**3. 从information_schema.Routines表中查看存储过程和函数的信息**

MySQL中存储过程和函数的信息存储在information_schema数据库下的Routines表中。可以通过查询该表的记录来查询存储过程和函数的信息。其基本语法形式如下：

```mysql
SELECT * FROM information_schema.Routines
WHERE ROUTINE_NAME='存储过程或函数的名' [AND ROUTINE_TYPE = {'PROCEDURE|FUNCTION'}];
```

说明：如果在MySQL数据库中存在存储过程和函数名称相同的情况，最好指定ROUTINE_TYPE查询条件来指明查询的是存储过程还是函数。

举例：从Routines表中查询名称为CountProc的存储函数的信息，代码如下：

```mysql
SELECT * FROM information_schema.Routines
WHERE ROUTINE_NAME='count_by_id'　AND　ROUTINE_TYPE = 'FUNCTION' \G
```

**4 .修改**

```mysql
ALTER {PROCEDURE | FUNCTION} 存储过程或函数的名 [characteristic ...]
```

其中，`characteristic`指定存储过程或函数的特性，其取值信息与创建存储过程、函数时的取值信息略有不同。

```mysql
{ CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
| SQL SECURITY { DEFINER | INVOKER }
| COMMENT 'string'
```

- `CONTAINS SQL`，表示子程序包含SQL语句，但不包含读或写数据的语句。
- `NO SQL`，表示子程序中不包含SQL语句。
- `READS SQL DATA`，表示子程序中包含读数据的语句。
- `MODIFIES SQL DATA`，表示子程序中包含写数据的语句。
- `SQL SECURITY { DEFINER | INVOKER }`，指明谁有权限来执行。
  - `DEFINER`，表示只有定义者自己才能够执行。
  - `INVOKER`，表示调用者可以执行。
- `COMMENT 'string'`，表示注释信息。

> 修改存储过程使用ALTER PROCEDURE语句，修改存储函数使用ALTER FUNCTION语句。但是，这两个语句的结构是一样的，语句中的所有参数也是一样的。

**举例1：**

修改存储过程`CountProc`的定义。将读写权限改为`MODIFIES SQL DATA`，并指明调用者可以执行，代码如下：

```mysql
ALTER　PROCEDURE　CountProc
MODIFIES SQL DATA
SQL SECURITY INVOKER ;
```

查询修改后的信息：

```mysql
SELECT specific_name,sql_data_access,security_type
FROM information_schema.`ROUTINES`
WHERE routine_name = 'CountProc' AND routine_type = 'PROCEDURE';
```

结果显示，存储过程修改成功。从查询的结果可以看出，访问数据的权限`（SQL_DATA_ ACCESS）`已经变成`MODIFIES SQL DATA`，安全类型`（SECURITY_TYPE）`已经变成`INVOKER`。

**举例2：**

修改存储函数`CountProc`的定义。将读写权限改为`READS SQL DATA`，并加上注释信息`FIND NAME`，代码如下：

```mysql
ALTER　FUNCTION　CountProc
READS SQL DATA
COMMENT 'FIND NAME' ;
```

存储函数修改成功。从查询的结果可以看出，访问数据的权限`（SQL_DATA_ACCESS`）已经变成`READS SQL DATA`，函数注释（`ROUTINE_COMMENT`）已经变成`FIND NAME`。

**5.删除**

删除存储过程和函数，可以使用DROP语句，其语法结构如下：

```mysql
DROP {PROCEDURE | FUNCTION} [IF EXISTS] 存储过程或函数的名
```

`IF EXISTS`：如果程序或函数不存储，它可以防止发生错误，产生一个用`SHOW WARNINGS`查看的警告。

举例：

```mysql
DROP PROCEDURE CountProc;
```

```mysql
DROP FUNCTION CountProc;
```

## 关于存储过程使用的争议

尽管存储过程有诸多优点，但是对于存储过程的使用，**一直都存在着很多争议**，比如有些公司对于大型项目要求使用存储过程，而有些公司在手册中明确禁止使用存储过程，为什么这些公司对存储过程的使用需求差别这么大呢？

###  优点

**1、存储过程可以一次编译多次使用。**存储过程只在创建时进行编译，之后的使用都不需要重新编译，这就提升了 SQL 的执行效率。

**2、可以减少开发工作量。**将代码`封装`成模块，实际上是编程的核心思想之一，这样可以把复杂的问题拆解成不同的模块，然后模块之间可以`重复使用`，在减少开发工作量的同时，还能保证代码的结构清晰。

**3、存储过程的安全性强。**我们在设定存储过程的时候可以`设置对用户的使用权限`，这样就和视图一样具有较强的安全性。

**4、可以减少网络传输量。**因为代码封装到存储过程中，每次使用只需要调用存储过程即可，这样就减少了网络传输量。

**5、良好的封装性。**在进行相对复杂的数据库操作时，原本需要使用一条一条的 SQL 语句，可能要连接多次数据库才能完成的操作，现在变成了一次存储过程，只需要`连接一次即可`。

###  缺点

基于上面这些优点，不少大公司都要求大型项目使用存储过程，比如微软、IBM 等公司。但是国内的阿里并不推荐开发人员使用存储过程，这是为什么呢？

> #### 阿里开发规范
>
> 【强制】禁止使用存储过程，存储过程难以调试和扩展，更没有移植性。

存储过程虽然有诸如上面的好处，但缺点也是很明显的。

**1、可移植性差。**存储过程不能跨数据库移植，比如在 MySQL、Oracle 和 SQL Server 里编写的存储过程，在换成其他数据库时都需要重新编写。

**2、调试困难。**只有少数 DBMS 支持存储过程的调试。对于复杂的存储过程来说，开发和维护都不容易。虽然也有一些第三方工具可以对存储过程进行调试，但要收费。

**3、存储过程的版本管理很困难。**比如数据表索引发生变化了，可能会导致存储过程失效。我们在开发软件的时候往往需要进行版本管理，但是存储过程本身没有版本控制，版本迭代更新的时候很麻烦。

**4、它不适合高并发的场景。**高并发的场景需要减少数据库的压力，有时数据库会采用分库分表的方式，而且对可扩展性要求很高，在这种情况下，存储过程会变得难以维护，`增加数据库的压力`，显然就不适用了。

小结：

存储过程既方便，又有局限性。尽管不同的公司对存储过程的态度不一，但是对于我们开发人员来说，不论怎样，掌握存储过程都是必备的技能之一。