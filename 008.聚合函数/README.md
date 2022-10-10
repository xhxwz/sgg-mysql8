## 聚合函数

作用于一组数据，并对一组数据返回一个值。

## `AVG/SUM`

> 只适用于数值类型

```SQL
SELECT
	AVG(salary), 
	SUM(salary)
FROM
	employees;
/*
+-------------+-------------+
| AVG(salary) | SUM(salary) |
+-------------+-------------+
| 6461.682243 |   691400.00 |
+-------------+-------------+
*/
```



## `MAX/MIN`

> 适用于数值、字符串、日期时间等类型

```sql
SELECT
	MAX(salary),
	MIN(salary)
FROM 
	employees;
/*
+-------------+-------------+
| MAX(salary) | MIN(salary) |
+-------------+-------------+
|    24000.00 |     2100.00 |
+-------------+-------------+
*/

SELECT
	MAX(last_name), MIN(last_name),
	MAX(hire_date), MIN(hire_date)
FROM
	employees;
/*
+----------------+----------------+----------------+----------------+
| MAX(last_name) | MIN(last_name) | MAX(hire_date) | MIN(hire_date) |
+----------------+----------------+----------------+----------------+
| Zlotkey        | Abel           | 2000-04-21     | 1987-06-17     |
+----------------+----------------+----------------+----------------+
*/
```



## `COUNT`

计算指定字段在查询结果中出现的个数（不含`NULL`）。

- 方式一：`COUNT(*)`
- 方式二：`COUNT(常量)`，比如`COUNT(1)`
- 方式三：`COUNT(具体字段)` -- 不一定对

```sql
SELECT
	COUNT(employee_id),
	COUNT(salary),
	COUNT(commission_pct),
	COUNT(department_id),
	COUNT(1), -- 常量
	COUNT(12), -- 常量
	COUNT(*),
	COUNT(NULL)
FROM
	employees;
/*
   COUNT(employee_id): 107
        COUNT(salary): 107
COUNT(commission_pct): 35
 COUNT(department_id): 106
             COUNT(1): 107
            COUNT(12): 107
             COUNT(*): 107
          COUNT(NULL): 0
*/

SELECT
	AVG(commission_pct),
	AVG(IFNULL(commission_pct, 0)),
	COUNT(commission_pct), SUM(commission_pct)/COUNT(commission_pct),
	COUNT(*), SUM(commission_pct)/COUNT(*)
FROM
	employees;
/*
                      AVG(commission_pct): 0.222857
           AVG(IFNULL(commission_pct, 0)): 0.072897
                    COUNT(commission_pct): 35
SUM(commission_pct)/COUNT(commission_pct): 0.222857
                                 COUNT(*): 107
             SUM(commission_pct)/COUNT(*): 0.072897
*/
```



## `GROUP BY`

```sql
SELECT
	department_id, AVG(salary), SUM(salary)
FROM
	employees
GROUP BY 
	department_id;

/*
+---------------+--------------+-------------+
| department_id | AVG(salary)  | SUM(salary) |
+---------------+--------------+-------------+
|          NULL |  7000.000000 |     7000.00 |
|            10 |  4400.000000 |     4400.00 |
|            20 |  9500.000000 |    19000.00 |
|            30 |  4150.000000 |    24900.00 |
|            40 |  6500.000000 |     6500.00 |
|            50 |  3475.555556 |   156400.00 |
|            60 |  5760.000000 |    28800.00 |
|            70 | 10000.000000 |    10000.00 |
|            80 |  8955.882353 |   304500.00 |
|            90 | 19333.333333 |    58000.00 |
|           100 |  8600.000000 |    51600.00 |
|           110 | 10150.000000 |    20300.00 |
+---------------+--------------+-------------+
*/

SELECT
	job_id, AVG(salary), SUM(salary)
FROM
	employees
GROUP BY 
	job_id;
/*
+------------+--------------+-------------+
| job_id     | AVG(salary)  | SUM(salary) |
+------------+--------------+-------------+
| AC_ACCOUNT |  8300.000000 |     8300.00 |
| AC_MGR     | 12000.000000 |    12000.00 |
| AD_ASST    |  4400.000000 |     4400.00 |
| AD_PRES    | 24000.000000 |    24000.00 |
| AD_VP      | 17000.000000 |    34000.00 |
| FI_ACCOUNT |  7920.000000 |    39600.00 |
| FI_MGR     | 12000.000000 |    12000.00 |
| HR_REP     |  6500.000000 |     6500.00 |
| IT_PROG    |  5760.000000 |    28800.00 |
| MK_MAN     | 13000.000000 |    13000.00 |
| MK_REP     |  6000.000000 |     6000.00 |
| PR_REP     | 10000.000000 |    10000.00 |
| PU_CLERK   |  2780.000000 |    13900.00 |
| PU_MAN     | 11000.000000 |    11000.00 |
| SA_MAN     | 12200.000000 |    61000.00 |
| SA_REP     |  8350.000000 |   250500.00 |
| SH_CLERK   |  3215.000000 |    64300.00 |
| ST_CLERK   |  2785.000000 |    55700.00 |
| ST_MAN     |  7280.000000 |    36400.00 |
+------------+--------------+-------------+
*/

SELECT
	department_id,job_id, AVG(salary), SUM(salary)
FROM
	employees
GROUP BY 
	department_id,job_id;
/*
+---------------+------------+--------------+-------------+
| department_id | job_id     | AVG(salary)  | SUM(salary) |
+---------------+------------+--------------+-------------+
|            90 | AD_PRES    | 24000.000000 |    24000.00 |
|            90 | AD_VP      | 17000.000000 |    34000.00 |
|            60 | IT_PROG    |  5760.000000 |    28800.00 |
|           100 | FI_MGR     | 12000.000000 |    12000.00 |
|           100 | FI_ACCOUNT |  7920.000000 |    39600.00 |
|            30 | PU_MAN     | 11000.000000 |    11000.00 |
|            30 | PU_CLERK   |  2780.000000 |    13900.00 |
|            50 | ST_MAN     |  7280.000000 |    36400.00 |
|            50 | ST_CLERK   |  2785.000000 |    55700.00 |
|            80 | SA_MAN     | 12200.000000 |    61000.00 |
|            80 | SA_REP     |  8396.551724 |   243500.00 |
|          NULL | SA_REP     |  7000.000000 |     7000.00 |
|            50 | SH_CLERK   |  3215.000000 |    64300.00 |
|            10 | AD_ASST    |  4400.000000 |     4400.00 |
|            20 | MK_MAN     | 13000.000000 |    13000.00 |
|            20 | MK_REP     |  6000.000000 |     6000.00 |
|            40 | HR_REP     |  6500.000000 |     6500.00 |
|            70 | PR_REP     | 10000.000000 |    10000.00 |
|           110 | AC_MGR     | 12000.000000 |    12000.00 |
|           110 | AC_ACCOUNT |  8300.000000 |     8300.00 |
+---------------+------------+--------------+-------------+
*/
```

- `SELECT` 中出现的非组函数的字段，必须声明在 `GROUP BY` 中 
- `GROUP BY` 中声明的字段，可以不出现在 `SELECT` 中
- `GROUP BY`，在 `WHERE` 的后面，`ORDER BY`和`LIMIT`的前面

`WITH ROLLUP`：

在所有查询的分组记录之后增加一条记录，该记录计算查询出来的所有记录的总和。当使用 `WITH ROLLUP`时，不能同时使用 `ORDER BY` 。

```sql
SELECT
	department_id, AVG(salary), SUM(salary)
FROM
	employees
GROUP BY 
	department_id
WITH ROLLUP;
/*
+---------------+--------------+-------------+
| department_id | AVG(salary)  | SUM(salary) |
+---------------+--------------+-------------+
|          NULL |  7000.000000 |     7000.00 |
|            10 |  4400.000000 |     4400.00 |
|            20 |  9500.000000 |    19000.00 |
|            30 |  4150.000000 |    24900.00 |
|            40 |  6500.000000 |     6500.00 |
|            50 |  3475.555556 |   156400.00 |
|            60 |  5760.000000 |    28800.00 |
|            70 | 10000.000000 |    10000.00 |
|            80 |  8955.882353 |   304500.00 |
|            90 | 19333.333333 |    58000.00 |
|           100 |  8600.000000 |    51600.00 |
|           110 | 10150.000000 |    20300.00 |
|          NULL |  6461.682243 |   691400.00 |
+---------------+--------------+-------------+
*/
```



## `HAVING`

- 如果过滤条件中使用了聚合函数，必须使用 `HAVING` 替换 `WHERE`
- 当过滤条件中没有聚合函数时，此过滤条件声明在 `WHERE` 优于 `HAVING`
- `HAVING` 必须声明在 `GROUP BY` 后面
- 使用 `HAVING` 的前提是，使用了 `GROUP BY`

```sql
SELECT
	department_id, MAX(salary) AS "max_salary"
FROM
	employees
GROUP BY 
	department_id
HAVING max_salary > 10000;
/*
+---------------+------------+
| department_id | max_salary |
+---------------+------------+
|            20 |   13000.00 |
|            30 |   11000.00 |
|            80 |   14000.00 |
|            90 |   24000.00 |
|           100 |   12000.00 |
|           110 |   12000.00 |
+---------------+------------+
*/

SELECT
	department_id, MAX(salary) AS "max_salary"
FROM
	employees
WHERE
	department_id IN(10,20,30,40) -- 推荐方式
GROUP BY 
	department_id
HAVING 
	max_salary > 10000
;
/*
+---------------+------------+
| department_id | max_salary |
+---------------+------------+
|            20 |   13000.00 |
|            30 |   11000.00 |
+---------------+------------+
*/

SELECT
	department_id, MAX(salary) AS "max_salary"
FROM
	employees
GROUP BY 
	department_id
HAVING 
	department_id IN(10,20,30,40) -- 效率低于 WHERE
	AND
	max_salary > 10000
;
/*
+---------------+------------+
| department_id | max_salary |
+---------------+------------+
|            20 |   13000.00 |
|            30 |   11000.00 |
+---------------+------------+
*/
```

|        | 优点                         | 缺点                                   |
| ------ | ---------------------------- | -------------------------------------- |
| `WHERE`  | 先筛选数据再关联，执行效率高 | 不能使用分组中的计算函数进行筛选       |
| `HAVING` | 可以使用分组中的计算函数     | 在最后的结果集中进行筛选，执行效率较低 |

## `SELECT` 底层执行原理

### `SELECT`语句的完整结构

```sql
#方式1：
SELECT ...,....,...
FROM ...,...,....
WHERE 多表的连接条件
AND 不包含组函数的过滤条件
GROUP BY ...,...
HAVING 包含组函数的过滤条件
ORDER BY ... ASC/DESC
LIMIT ...,...

#方式2：
SELECT ...,....,...
FROM ... JOIN ... 
ON 多表的连接条件
JOIN ...
ON ...
WHERE 不包含组函数的过滤条件
AND/OR 不包含组函数的过滤条件
GROUP BY ...,...
HAVING 包含组函数的过滤条件
ORDER BY ... ASC/DESC
LIMIT ...,...

#其中：
#（1）from：从哪些表中筛选
#（2）on：关联多表查询时，去除笛卡尔积
#（3）where：从表中筛选的条件
#（4）group by：分组依据
#（5）having：在统计结果中再次筛选
#（6）order by：排序
#（7）limit：分页
```

### `SELECT` 执行过程

#### 书写顺序

```
SELECT ... FROM ... WHERE ... GROUP BY ... HAVING ... ORDER BY ... LIMIT...
```

#### 执行顺序

```
FROM -> WHERE -> GROUP BY -> HAVING -> SELECT 的字段 -> DISTINCT -> ORDER BY -> LIMIT
```

比如：

```sql
SELECT DISTINCT player_id, player_name, count(*) as num # 顺序 5
FROM player JOIN team ON player.team_id = team.team_id # 顺序 1
WHERE height > 1.80 # 顺序 2
GROUP BY player.team_id # 顺序 3
HAVING num > 2 # 顺序 4
ORDER BY num DESC # 顺序 6
LIMIT 2 # 顺序 7
```

### SQL 的执行原理

`SELECT` 是先执行 `FROM` 这一步的。在这个阶段，如果是多张表联查，还会经历下面的几个步骤：

1. 首先先通过 `CROSS JOIN` 求笛卡尔积，相当于得到虚拟表` vt（virtual table）1-1`；
2. 通过 `ON` 进行筛选，在虚拟表 `vt1-1` 的基础上进行筛选，得到虚拟表 `vt1-2`；
3. 添加外部行。如果我们使用的是左连接、右链接或者全连接，就会涉及到外部行，也就是在虚拟表 `vt1-2` 的基础上增加外部行，得到虚拟表 `vt1-3`。

当然如果我们操作的是两张以上的表，还会重复上面的步骤，直到所有表都被处理完为止。这个过程得到是我们的原始数据。

当我们拿到了查询数据表的原始数据，也就是最终的虚拟表 `vt1`，就可以在此基础上再进行 `WHERE 阶段`。在这个阶段中，会根据 vt1 表的结果进行筛选过滤，得到虚拟表 `vt2`。

然后进入第三步和第四步，也就是 `GROUP 和 HAVING 阶段`。在这个阶段中，实际上是在虚拟表 `vt2` 的基础上进行分组和分组过滤，得到中间的虚拟表 `vt3` 和 `vt4`。

当我们完成了条件筛选部分之后，就可以筛选表中提取的字段，也就是进入到 `SELECT 和 DISTINCT 阶段`。

首先在 `SELECT` 阶段会提取想要的字段，然后在 `DISTINCT` 阶段过滤掉重复的行，分别得到中间的虚拟表 `vt5-1` 和 `vt5-2`。

当我们提取了想要的字段数据之后，就可以按照指定的字段进行排序，也就是 `ORDER BY 阶段`，得到虚拟表 `vt6`。

最后在 `vt6` 的基础上，取出指定行的记录，也就是 `LIMIT 阶段`，得到最终的结果，对应的是虚拟表 `vt7`。

当然我们在写 `SELECT` 语句的时候，不一定存在所有的关键字，相应的阶段就会省略。

同时因为 SQL 是一门类似英语的结构化查询语言，所以我们在写 `SELECT` 语句的时候，还要注意相应的关键字顺序，**所谓底层运行的原理，就是我们刚才讲到的执行顺序。**

