/* 176. Second Highest Salary */
SELECT MAX(salary) AS SecondHighestSalary
FROM employee
WHERE salary NOT IN (SELECT MAX(salary)
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
        LIMIT 1 OFFSET M) AS SecondHighestSalary
  );

/* 178. Rank Scores */
SELECT score,
    DENSE_RANK() OVER(ORDER BY score DESC) AS 'rank'
FROM scores;




