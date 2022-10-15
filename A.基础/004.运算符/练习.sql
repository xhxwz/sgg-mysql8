-- 1. 选择工资不在5000到12000的员工的姓名和工资
SELECT last_name,salary FROM employees 
-- WHERE salary NOT BETWEEN 5000 AND 12000;
-- WHERE NOT(salary  BETWEEN 5000 AND 12000);
-- WHERE NOT(salary  >= 5000 AND salary <= 12000);
WHERE salary  < 5000 OR salary > 12000;

-- 2. 选择在20或50号部门工作的员工姓名和部门号
SELECT last_name,department_id FROM employees
-- WHERE department_id=20 OR department_id=50;
WHERE department_id in(20,50);

-- 3. 选择公司中没有管理员的员工姓名及job_id
SELECT last_name, job_id FROM employees
-- WHERE manager_id IS NULL;
-- WHERE manager_id <=> NULL;
WHERE ISNULL(manager_id);

-- 4. 选择公司中有奖金的员工姓名，工资和奖金级别
SELECT last_name,salary,commission_pct FROM employees
-- WHERE commission_pct IS NOT NULL
-- WHERE NOT (commission_pct IS  NULL)
WHERE NOT ISNULL(commission_pct)
;

-- 5. 选择员工姓名的第三个字母是a的员工姓名
SELECT first_name, last_name FROM employees
-- WHERE last_name LIKE '__a%'
WHERE last_name REGEXP '^\\w{2}a'
;

-- 6. 选择姓名中有字母a和k的员工姓名
SELECT first_name, last_name FROM employees
 WHERE last_name LIKE '%a%' AND last_name LIKE '%k%'
--  WHERE last_name LIKE '%a%k%' OR last_name LIKE '%k%a%'
;


-- 7. 显示出表 employees 表中 first_name 以 e 结尾的员工信息
SELECT first_name, last_name FROM employees
    -- WHERE first_name LIKE '%e'
    WHERE first_name REGEXP 'e$'
;
-- 8. 显示出表 employees 部门编号在 80-100 之间的姓名、工种
SELECT last_name,job_id,department_id FROM employees
-- WHERE department_id BETWEEN 80 AND 100
WHERE department_id >= 80 AND department_id<=100
;

-- 9. 显示出表 employees 的 manager_id 是100,101,110的员工姓名、工资、管理者id
SELECT last_name,salary,manager_id FROM employees
WHERE manager_id IN(100,101,110);