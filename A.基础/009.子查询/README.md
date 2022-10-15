## 谁的工资比 `Abel` 高

```sql
-- 方式1: 自连接
SELECT
	e.last_name,
	e.salary
FROM
	employees AS e, employees AS a
WHERE
	e.salary > a.salary
	AND a.last_name = 'Abel';

-- 方式2: 子查询
SELECT
	e.last_name,
	e.salary
FROM
	employees AS e
WHERE
	e.salary > (
  	SELECT salary
    FROM employees
    WHERE last_name = 'Abel'
  );
```

## 子查询

- 子查询（内查询）在主查询（外查询）之前执行完成
- 子查询的结果被主查询使用
- 子查询要包含在括号内
- 将子查询放在比较条件的右侧
- 单行操作符对应单行子查询，多行操作符对应多行子查询

> 在 `SELECT`中，除了 `GROUP BY` 和 `LIMIT` 之外，其它位置都可以声明子查询

## 单行子查询

```sql
-- 查询工资大于149号员工工资的员工信息
SELECT
	employee_id, last_name, salary
FROM
	employees
WHERE
	salary > (
  	SELECT salary FROM employees WHERE employee_id = 149
  );
/*
+-------------+-----------+----------+
| employee_id | last_name | salary   |
+-------------+-----------+----------+
|         100 | King      | 24000.00 |
|         101 | Kochhar   | 17000.00 |
|         102 | De Haan   | 17000.00 |
|         108 | Greenberg | 12000.00 |
|         114 | Raphaely  | 11000.00 |
|         145 | Russell   | 14000.00 |
|         146 | Partners  | 13500.00 |
|         147 | Errazuriz | 12000.00 |
|         148 | Cambrault | 11000.00 |
|         168 | Ozer      | 11500.00 |
|         174 | Abel      | 11000.00 |
|         201 | Hartstein | 13000.00 |
|         205 | Higgins   | 12000.00 |
+-------------+-----------+----------+
*/
  
-- 返回 job_id 与 141号员工相同，salary 比 143 员工多的员工姓名，job_id和工资

SELECT 
	last_name, job_id, salary
FROM 
	employees
WHERE
	job_id = (
  	SELECT job_id FROM employees WHERE employee_id = 141
  )
	AND
	salary > (
  	SELECT salary FROM employees WHERE employee_id = 143
  );
/*
+-------------+----------+---------+
| last_name   | job_id   | salary  |
+-------------+----------+---------+
| Nayer       | ST_CLERK | 3200.00 |
| Mikkilineni | ST_CLERK | 2700.00 |
| Bissot      | ST_CLERK | 3300.00 |
| Atkinson    | ST_CLERK | 2800.00 |
| Mallin      | ST_CLERK | 3300.00 |
| Rogers      | ST_CLERK | 2900.00 |
| Ladwig      | ST_CLERK | 3600.00 |
| Stiles      | ST_CLERK | 3200.00 |
| Seo         | ST_CLERK | 2700.00 |
| Rajs        | ST_CLERK | 3500.00 |
| Davies      | ST_CLERK | 3100.00 |
+-------------+----------+---------+
*/

-- 返回公司工资最少的员工信息
SELECT 
	last_name, job_id, salary
FROM 
	employees
WHERE
	salary = (
  	SELECT MIN(salary) FROM employees 
  );
/*
+-----------+----------+---------+
| last_name | job_id   | salary  |
+-----------+----------+---------+
| Olson     | ST_CLERK | 2100.00 |
+-----------+----------+---------+
*/

-- 查询与141号员工的manager_id和department_id相同的
-- 其它员工的 employee_id, manager_id, department_id

SELECT
	employee_id, manager_id, department_id
FROM 
	employees 
WHERE
	manager_id = (
  	SELECT manager_id FROM employees WHERE employee_id = 141
  )
	AND
	department_id = (
  	SELECT department_id FROM employees WHERE employee_id = 141
  )
  AND
  employee_id <> 141
 ;
/*
+-------------+------------+---------------+
| employee_id | manager_id | department_id |
+-------------+------------+---------------+
|         142 |        124 |            50 |
|         143 |        124 |            50 |
|         144 |        124 |            50 |
|         196 |        124 |            50 |
|         197 |        124 |            50 |
|         198 |        124 |            50 |
|         199 |        124 |            50 |
+-------------+------------+---------------+
*/

SELECT
	employee_id, manager_id, department_id
FROM 
	employees 
WHERE
	(manager_id, department_id) = (
  	SELECT manager_id, department_id FROM employees WHERE employee_id = 141
  )
  AND 
  employee_id <> 141;
/*
+-------------+------------+---------------+
| employee_id | manager_id | department_id |
+-------------+------------+---------------+
|         142 |        124 |            50 |
|         143 |        124 |            50 |
|         144 |        124 |            50 |
|         196 |        124 |            50 |
|         197 |        124 |            50 |
|         198 |        124 |            50 |
|         199 |        124 |            50 |
+-------------+------------+---------------+
*/

-- 查询最低工资大于110号部门最低工资的部门ID及其最低工资
SELECT
	department_id, MIN(salary) AS "min_salary"
FROM
	employees
WHERE department_id IS NOT NULL
GROUP BY
	department_id
HAVING
	min_salary > (
  	SELECT MIN(salary) FROM employees  WHERE department_id = 110 
  )
/*
+---------------+------------+
| department_id | min_salary |
+---------------+------------+
|            70 |   10000.00 |
|            90 |   17000.00 |
+---------------+------------+
*/

-- 显示员工的employee_id, last_name 和 location
-- 其中，若员工department_id与location_id为1800的department_id相同
-- 则 location 为 Canada，否则为 USA
SELECT
	employee_id, last_name, 
	-- CASE department_id
	-- 	WHEN (SELECT department_id FROM departments WHERE location_id=1800) THEN 'Canada'
	-- 	ELSE 'USA'
	-- END
	IF(department_id = (SELECT department_id FROM departments WHERE location_id=1800), 'Canada', 'USA')
	AS location
FROM 
	employees;
```

## 多行子查询

- 也称为集合比较子查询
- 内查询返回多行
- 使用多行比较操作符

| 操作符 | 含义                                                         |
| ------ | ------------------------------------------------------------ |
| `IN`   | 等于列表中的**任意一个**                                     |
| `ANY`  | 需要和单行比较操作符一起使用，和子查询返回的**某一个**值比较 |
| `ALL`  | 需要和单行比较操作符一起使用，和子查询返回的**所有**值比较   |
| `SOME` | `ANY`的别名，通常使用 `ANY`                                  |

```sql
-- IN ，哪些员工的工资刚好等于各部门最低工资
SELECT employee_id, last_name,salary
FROM employees
WHERE salary IN(
	SELECT MIN(salary)
  FROM employees
  GROUP BY department_id
)

-- 【ANY】 返回其它 job_id 中，比 job_id = 'IT_PROG' 部门【任一】工资低的员工的信息
SELECT
	employee_id, last_name, job_id, salary
FROM employees
WHERE
	salary < ANY (
  	SELECT salary
  	FROM employees
    WHERE job_id = 'IT_PROG'
  )
  AND
  	job_id <> 'IT_PROG'
;

-- 【ALL】 返回其它 job_id 中，比 job_id = 'IT_PROG' 部门【所有】工资低的员工的信息
SELECT
	employee_id, last_name, job_id, salary
FROM employees
WHERE
	salary < ALL (
  	SELECT salary
  	FROM employees
    WHERE job_id = 'IT_PROG'
  )
  AND
  	job_id <> 'IT_PROG'
;

-- 查询平均工资最低的部门ID

/*SELECT department_id,AVG(salary)  as "avg_sal"
FROM employees
  WHERE department_id is not null
GROUP BY department_id
  ORDER BY avg_sal ASC
  LIMIT 1;
*/
-- 方式1
SELECT
	department_id
FROM 
	employees
GROUP BY 
	department_id
HAVING 
	AVG(salary) = (
      SELECT 
    		MIN(t.avg_sal)
      FROM (
        SELECT AVG(salary) AS "avg_sal"
        FROM employees
        GROUP BY department_id
      ) AS t
  );
  
-- 方式2
SELECT
	department_id
FROM 
	employees
GROUP BY 
	department_id
HAVING 
	AVG(salary) <= ALL (
        SELECT AVG(salary) AS "avg_sal"
        FROM employees
        GROUP BY department_id
  );
```

## 相关子查询

```sql
-- 查询工资大于本部门平均工资的员信息
-- 方式1: 相关子查询
SELECT
	e.last_name, e.salary, e.department_id
FROM
	employees AS e
WHERE
	salary > (
  	SELECT AVG(salary) FROM employees WHERE department_id=e.department_id
  )
ORDER BY e.department_id,e.salary,e.employee_id;

-- 方式2: 在FROM中声明子查询
SELECT
	e.last_name, e.salary, e.department_id
FROM
	employees AS e,
	(
  	SELECT AVG(salary) AS avg_sal, department_id FROM employees GROUP BY  department_id
  ) AS t
WHERE
	e.salary > t.avg_sal
	AND e.department_id = t.department_id
ORDER BY e.department_id,e.salary,e.employee_id;

-- 方式3:在JOIN中声明子查询
SELECT
	e.last_name, e.salary, e.department_id
FROM
	employees AS e
	join
	(
  	SELECT AVG(salary) AS avg_sal, department_id FROM employees GROUP BY  department_id
  ) AS t
  ON e.department_id = t.department_id
WHERE
	e.salary > t.avg_sal
ORDER BY e.department_id,e.salary,e.employee_id;


-- 查询员工信息，按照department_name排序
-- 方式1: LEFT JOIN
SELECT
	e.employee_id, e.last_name, e.salary, d.department_name
FROM
	employees AS e
LEFT JOIN
	departments AS d
ON
	e.department_id = d.department_id
ORDER BY
	d.department_name

-- 方式2: 在 ORDER BY 中声明子查询
SELECT
	e.employee_id, e.last_name, e.salary
FROM
	employees AS e
ORDER BY (
	SELECT d.department_name FROM departments AS d
  WHERE e.department_id = d.department_id
) ASC;

-- 若 employees 表中，employee_id 与 job_history 表中 employee_id 相同的数目不少于2，
-- 输出这些相同 employee_id 的员工信息

-- 方式1
SELECT
	e.employee_id,e.last_name, e.job_id
FROM 
	employees AS e
WHERE 
	2 <= (
  	SELECT COUNT(*) FROM job_history where employee_id = e.employee_id 
  );

-- 方式2
SELECT
	e.employee_id,e.last_name, e.job_id
FROM 
	employees AS e
WHERE 
	e.employee_id = (
    SELECT employee_id FROM job_history where employee_id = e.employee_id 
    having count(*) >= 2
  )
-- 方式3  
SELECT
	e.employee_id,e.last_name, e.job_id
FROM 
	employees AS e,
	(
    SELECT employee_id, count(*) AS c_eid FROM job_history GROUP BY employee_id
  ) AS t
where
	e.employee_id = t.employee_id
	and
	t.c_eid >= 2;
```

### `EXISTS` 和 `NOT EXISTS`

```sql
-- 查询公司管理者的信息
-- 方式1
SELECT
	e.employee_id,e.last_name, e.job_id, e.department_id
FROM 
	employees AS e
WHERE 1<= (
	SELECT COUNT(*) FROM employees WHERE manager_id=e.employee_id
)
-- 方式2
SELECT
	e.employee_id,e.last_name, e.job_id, e.department_id
FROM 
	employees AS e
WHERE EXISTS (
	SELECT employee_id FROM employees WHERE manager_id=e.employee_id
)

-- 查询 departments 表中，不存在于 employees 表中的记录
-- 方式1：
SELECT
	d.department_id, d.department_name
FROM
	departments AS d
WHERE NOT EXISTS (
	SELECT department_id FROM employees WHERE department_id = d.department_id
);

-- 方式2:
SELECT
	 d.department_id, d.department_name
FROM
	departments AS d
LEFT JOIN
	employees AS e
ON
	d.department_id = e.department_id
WHERE
	e.department_id IS  NULL;
```

