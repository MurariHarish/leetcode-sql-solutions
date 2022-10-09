/* 176. Second Highest Salary */
SELECT MAX(salary) AS SecondHighestSalary
FROM employee
WHERE salary NOT IN (
	SELECT MAX(salary)
	FROM employee);

/* 177. Nth Highest Salary */
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
DECLARE M int;
SET M = N - 1;
  RETURN (
      # Write your MySQL query statement below.
    SELECT
    (SELECT DISTINCT
            Salary
        FROM
            Employee
        ORDER BY Salary DESC
        LIMIT 1 OFFSET M) AS SecondHighestSalary);

/* 178. Rank Scores */
SELECT score,
    DENSE_RANK() OVER(ORDER BY score DESC) AS 'rank'
FROM scores;

/* 180. Consecutive Numbers */
WITH cte1 AS (
    SELECT *, LAG(num, 1) OVER(ORDER BY id) AS previous_num_1, LAG(num, 2) OVER(ORDER by id) AS previous_num_2
    FROM logs),
cte2 AS (
    SELECT *
    FROM cte1
    WHERE num = previous_num_1 AND num = previous_num_2)
SELECT DISTINCT num AS ConsecutiveNums
FROM cte2;

/* 184. Department Highest Salary */
WITH cte1 AS(
    SELECT *, DENSE_RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS rank
    FROM Employee)
SELECT department.name AS Department, cte1.name AS Employee, cte1.salary
FROM cte1
INNER JOIN department ON cte1.departmentId = department.id
WHERE rank = '1';

/* 534. Game Play Analysis III */
SELECT player_id, event_date, SUM(games_played) 
	OVER(PARTITION BY player_id  
    ORDER BY player_id 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS games_played_so_far
FROM activity;

/* 550. Game Play Analysis IV */
WITH cte1 AS (
    SELECT player_id, event_date, LAG(event_date)OVER(PARTITION BY player_id ORDER BY event_date) AS previous_login
    FROM activity)
SELECT ROUND(COUNT(player_id) / (SELECT COUNT(DISTINCT(player_id)) FROM cte1),2) AS fraction
FROM cte1
WHERE DATEDIFF(event_date,previous_login) = 1;

/* 570. Managers with at Least 5 Direct Reports */
SELECT name
FROM employee
WHERE id IN (
    SELECT managerID
    FROM employee
    GROUP BY managerID
    HAVING COUNT(managerID) >= 5);
    
/* 574. Winning Candidate */
SELECT name
FROM candidate JOIN vote ON candidate.id = vote.candidateid
GROUP BY candidateid
ORDER BY COUNT(*) DESC
LIMIT 1;

/* 578. Get Highest Answer Rate Question */
SELECT
  question_id AS survey_log
FROM
  surveylog
GROUP BY 1
ORDER BY
  SUM(CASE WHEN action = 'answer' THEN 1 ELSE 0 END) / SUM(CASE WHEN action = 'show' THEN 1 ELSE 0 END) DESC, 1
LIMIT 1;

/* 580. Count Student Number in Departments */
SELECT dept_name, COUNT(student_id) AS student_number
FROM department
LEFT JOIN student ON department.dept_id = student.dept_id
GROUP BY department.dept_name
ORDER BY student_number DESC, department.dept_name;

/* 585. Investments in 2016 */
WITH cte1 AS (SELECT tiv_2015
FROM insurance
GROUP BY tiv_2015
HAVING COUNT(tiv_2015) > 1)
SELECT SUM(i.tiv_2016) AS tiv_2016
FROM insurance AS i
INNER JOIN cte1 ON cte1.tiv_2015 = i.tiv_2015
WHERE CONCAT(lat, lon) IN (
    SELECT
    CONCAT(LAT, LON)
    FROM insurance
    GROUP BY LAT , LON
    HAVING COUNT(*) = 1);
    

/* 602. Friend Requests II: Who Has the Most Friends */
WITH cte1 AS (
    SELECT accepter_id FROM requestaccepted
    UNION ALL
    SELECT requester_id FROM requestaccepted)
SELECT accepter_id as id, COUNT(accepter_id) AS num
FROM cte1
GROUP BY accepter_id
ORDER BY COUNT(accepter_id) DESC
LIMIT 1;
