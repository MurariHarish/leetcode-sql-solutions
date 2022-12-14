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

/* 608. Tree Node */
SELECT id, 
    CASE WHEN p_id IS NULL THEN 'Root' 
    WHEN id IN (
        SELECT t.p_id
        FROM tree AS t
        ) THEN 'Inner'
    ELSE 'Leaf' END AS type
FROM tree;

/* 612. Shortest Distance in a Plane */
WITH cte1 AS (
    SELECT ROUND(SQRT(POW((two.x - one.x),2) + POW((two.y - one.x),2)),2) AS shortest
    FROM point2d AS one, point2d AS two)

SELECT MIN(shortest) AS shortest
FROM cte1
WHERE shortest > 0;

/* 614. Second Degree Follower */
SELECT followee AS follower, COUNT(followee) AS num
FROM follow
WHERE followee IN (
    SELECT DISTINCT follower
    FROM follow)
GROUP BY followee;

/* 626. Exchange Seats */
SELECT (
    CASE WHEN MOD (id,2) = 1 AND id != (SELECT COUNT(*) FROM seat) THEN id+1
    WHEN MOD(id,2)=0 THEN id-1
    ELSE id END)id, student
FROM seat
ORDER BY id;

/* 1045. Customers Who Bought All Products */
SELECT customer_id
FROM customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (
                                    SELECT COUNT(*) 
                                    FROM product);

/* 1070. Product Sales Analysis III */
SELECT product_id, year AS first_year, quantity, price
FROM sales
WHERE sale_id IN (
    SELECT sale_id
    FROM sales
    GROUP BY product_id
    HAVING MIN(year));

/* 1077. Project Employees III */
SELECT project_id, employee_id
FROM (
	SELECT p.project_id, p.employee_id, DENSE_RANK() OVER(PARTITION BY project_id ORDER BY experience_years DESC) AS rank
FROM Project p
JOIN Employee e
ON p.employee_id = e.employee_id) cte
WHERE rank = 1;

/* 1098. Unpopular Books */
SELECT book_id, name
FROM Books 
WHERE available_from<'2019-05-23' AND book_id NOT IN(
    SELECT book_id 
    FROM Orders 
    WHERE dispatch_date BETWEEN '2018-06-23' AND '2019-06-23' 
    GROUP BY 1 
    HAVING SUM(quantity)>=10);
    
/* 1107. New Users Daily Count */
SELECT activity_date AS login_date, COUNT(DISTINCT(user_id)) AS user_count
FROM traffic
WHERE activity = 'login' AND activity_date BETWEEN '2019-03-30' AND '2019-06-30'
GROUP BY login_date;

/*1112. Highest Grade For Each Student*/
WITH cte1 AS (
    SELECT student_id, course_id, grade, RANK() OVER(PARTITION BY student_id ORDER BY grade DESC) AS ranking
    FROM enrollments)
SELECT student_id, MIN(course_id) AS course_id, grade
FROM cte1
WHERE ranking  = 1
GROUP BY student_id;

/*1126. Active Businesses*/
WITH avg AS (
    SELECT event_type, AVG(occurences) AS avg_occ
    FROM events
    GROUP BY event_type)
    
SELECT DISTINCT business_id
FROM events
JOIN avg ON avg.event_type = events.event_type
WHERE occurences > avg_occ AND business_id  IN (SELECT business_id
                                               FROM events
                                               GROUP BY business_id
                                               HAVING COUNT(event_type) > 1);
                                               
/* 1149. Article Views II */
SELECT viewer_id AS id
FROM views
WHERE viewer_id NOT IN (SELECT viewer_id
                       FROM views
                       WHERE author_id = viewer_id)
GROUP BY viewer_id, view_date
HAVING COUNT(viewer_id) > 1;

/* 1158. Market Analysis I */
WITH cte1 AS (
    SELECT buyer_id, COUNT(buyer_id) AS orders_in_2019
    FROM orders
    WHERE EXTRACT(year FROM order_date) = 2019
    GROUP BY buyer_id)

SELECT user_id, join_date, orders_in_2019
FROM users
LEFT JOIN cte1 ON user_id = buyer_id;

/* 1158. 1164. Product Price at a Given Date */
SELECT T1.product_id, IFNULL(T2.new_price,10) AS price
FROM (SELECT DISTINCT product_id FROM Products) AS T1 
  LEFT JOIN
            (SELECT product_id, new_price
              FROM Products
              WHERE (product_id, change_date) IN (SELECT product_id, MAX(change_date) AS last_date
                                                                                 FROM Products
                                                                                  WHERE change_date <= '2019-08-16'
                                                                                  GROUP BY product_id)) AS T2
 ON T1.product_id = T2.product_id;
 
/* 1174. Immediate Food Delivery II below */
SELECT (SUM(imm) / COUNT(imm)) * 100 AS immediate_percentage
FROM (
    SELECT customer_id, IF(order_date = customer_pref_delivery_date,1,0) AS imm
    FROM delivery
    WHERE (customer_id, order_date) IN (
        SELECT customer_id, MIN(order_date)
        FROM delivery
        GROUP BY customer_id)) AS l;
        
/* 1193. Monthly Transactions I */   
WITH cte1 AS (
    SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month, country, COUNT(id) AS trans_count,         SUM(amount) AS trans_total_amount
    FROM transactions
    GROUP BY MONTH(trans_date), country),
cte2 AS (
    SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month, COUNT(id) AS approved_count, SUM(amount) AS approved_total_amount
    FROM transactions
    WHERE state = 'approved'
    GROUP BY MONTH(trans_date), country)
SELECT cte1.month,country,trans_count,approved_count,trans_total_amount,approved_total_amount
FROM cte1
INNER JOIN cte2
ON cte1.month = cte2.month;

/* 1204. Last Person to Fit in the Bus */
WITH cte1 AS (
    SELECT *, SUM(weight) OVER(ORDER BY turn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_weight
    FROM queue)
SELECT person_name
FROM cte1
WHERE running_weight <= 1000
ORDER BY running_weight DESC
LIMIT 1;

/* 1205. Monthly Transactions II */
WITH cte1 AS(
    SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month, country, COUNT(id) AS approved_count, SUM(amount) AS approved_amount 
    FROM transactions
    WHERE state = 'approved'
    GROUP BY DATE_FORMAT(trans_date, '%Y-%m'), country),
cte2 AS(
    SELECT DATE_FORMAT(c.trans_date, '%Y-%m') AS month,  COUNT(c.trans_id) AS chargeback_count, t.amount AS chargeback_amount
    FROM transactions AS t
    JOIN chargebacks AS c ON c.trans_id = t.id
    GROUP BY DATE_FORMAT(c.trans_date, '%Y-%m'))
SELECT cte1.month, country, approved_count, approved_amount, chargeback_count, chargeback_amount
FROM cte1
FULL JOIN cte2 ON cte2.month = cte1.month;

/* 1212. Team Scores in Football Tournament */
SELECT team_id, team_name, SUM(CASE WHEN team_id = host_team AND host_goals > guest_goals THEN 3 
                            WHEN team_id = guest_team AND guest_goals > host_goals THEN 3 
                            WHEN team_id = host_team AND host_goals = guest_goals THEN 1
                            WHEN team_id = guest_team AND host_goals = guest_goals THEN 1 ELSE 0
                            END) AS num_points
FROM teams
LEFT JOIN matches ON team_id = host_team OR team_id = guest_team
GROUP BY team_id
ORDER BY num_points DESC, team_id;

/* 1264. Page Recommendations */
WITH cte1 AS (SELECT CASE WHEN user1_id = 1 THEN user2_id
            WHEN user2_id = 1 THEN user1_id
            END AS friends_id
FROM friendship
WHERE user1_id = 1 OR user2_id = 1)
SELECT DISTINCT page_id AS recommended_page
FROM likes
JOIN cte1 ON user_id = friends_id
WHERE page_id NOT IN (SELECT page_id
                     FROM likes
                     WHERE user_id = 1);
            
/* 1270. All People Report to the Given Manager */
SELECT e1.employee_id
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.employee_id
JOIN employees e3 ON e2.manager_id = e3.employee_id
WHERE e3.manager_id = 1 AND e1.employee_id != 1;

/* 1285. Find the Start and End Number of Continuous Ranges */
SELECT min(log_id) AS start_id, max(log_id) AS end_id
FROM (
    SELECT log_id, RANK() OVER(ORDER BY log_id) as num
    FROM Logs) a
GROUP BY log_id - num;

/* 1285. 1308. Running Total for Different Genders */
SELECT gender, day, SUM(score_points) OVER(PARTITION BY gender ORDER BY day) AS total
FROM scores
ORDER BY gender, day;

/* 1321. Restaurant Growth */
SELECT visited_on, SUM(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount, 
AVG(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS average_amount
FROM (SELECT visited_on, SUM(amount) AS amount
     FROM customer
     GROUP BY visited_on) t
ORDER BY visited_on
OFFSET 6 ROWS;

/* 1341. Movie Rating */
(SELECT name AS results
FROM movierating mr
JOIN users u ON u.user_id = mr.user_id
GROUP BY u.user_id
ORDER BY COUNT(mr.user_id) DESC
LIMIT 1)
UNION
(SELECT m.title AS results
FROM movierating mr
JOIN movies m ON m.movie_id = mr.movie_id
WHERE DATE_FORMAT(created_at, '%Y-%m') = '2020-02'
GROUP BY mr.movie_id
ORDER BY AVG(rating) DESC, title
LIMIT 1)

/* 1355. Activity Participants */
SELECT activity
FROM (SELECT activity,
               COUNT(1) cnt,
               MAX(Count(1))
                 OVER() max_cnt,
               MIN(Count(1))
                 OVER() min_cnt
        FROM   friends
        GROUP  BY activity) a
WHERE  cnt != max_cnt
       AND cnt != min_cnt;
       
/* 1364. Number of Trusted Contacts of a Customer */
WITH cte1 AS (SELECT i.invoice_id, cus.customer_name, i.price, COUNT(con.user_id) AS contacts_cnt
FROM invoices AS i
JOIN customers AS cus ON i.user_id = cus.customer_id
LEFT JOIN contacts AS con ON i.user_id = con.user_id
GROUP BY i.invoice_id),
cte2 AS (SELECT customer_name, COUNT(contact_name) AS trusted_contacts_cnt
FROM contacts
JOIN customers ON contacts.user_id = customers.customer_id
WHERE contact_name IN (SELECT customer_name
                      FROM customers)
GROUP BY customer_id)
SELECT invoice_id, cte1.customer_name, price, contacts_cnt, IFNULL(trusted_contacts_cnt,0) AS trusted_contacts_cnt
FROM cte1
LEFT JOIN cte2 ON cte2.customer_name = cte1.customer_name
ORDER BY invoice_id;

/* 1393. Capital Gain/Loss */
SELECT stock_name, SUM(
    CASE WHEN operation = 'Buy' THEN -price 
    ELSE price 
    END
) AS capital_gain_loss
FROM stocks
GROUP BY stock_name;

/* 1440. Evaluate Boolean Expression */
SELECT e.left_operand, e.operator, e.right_operand,
    (
        CASE
            WHEN e.operator = '<' AND v1.value < v2.value THEN 'true'
            WHEN e.operator = '=' AND v1.value = v2.value THEN 'true'
            WHEN e.operator = '>' AND v1.value > v2.value THEN 'true'
            ELSE 'false'
        END
    ) AS value
FROM Expressions e
JOIN Variables v1
ON e.left_operand = v1.name
JOIN Variables v2
ON e.right_operand = v2.name;

/* 1445. Apples & Oranges */
SELECT sale_date, SUM(
    CASE WHEN fruit = 'oranges' THEN -sold_num ELSE sold_num END) AS diff
FROM sales
GROUP BY sale_date;

/* 1454. Active Users */
SELECT DISTINCT l1.id,
(SELECT name FROM Accounts WHERE id = l1.id) AS name
FROM Logins l1
JOIN Logins l2 ON l1.id = l2.id AND DATEDIFF(l2.login_date, l1.login_date) BETWEEN 1 AND 4
GROUP BY l1.id, l1.login_date
HAVING COUNT(DISTINCT l2.login_date) = 4;

/* 1459. Rectangles Area */
SELECT p1.id AS P1, p2.id AS P2, ABS((p1.x_value - p2.x_value) * (p1.y_value - p2.y_value)) AS AREA
FROM points p1 
JOIN points p2 ON p1.id <= p2.id
WHERE ABS((p1.x_value - p2.x_value) * (p1.y_value - p2.y_value)) != 0
ORDER BY area DESC, p1.id, p2.id;

/* 1468. Calculate Salaries */
SELECT company_id, employee_id, employee_name
,ROUND(CASE
    WHEN MAX(salary) over(PARTITION BY company_id) < 1000 THEN salary
    WHEN MAX(salary) over(PARTITION BY company_id) BETWEEN 1000 AND 10000 THEN salary*.76
    ELSE salary*.51
END,0) salary
FROM salaries;

/* 1501. Countries You Can Safely Invest In */
SELECT co.name AS country
FROM country AS co
JOIN person AS p ON SUBSTRING(phone_number,1,3) = country_code
JOIN calls AS ca ON p.id IN (ca.caller_id, ca.callee_id)
GROUP BY co.name
HAVING AVG(duration) > (
    SELECT AVG(duration)
    FROM calls);

/* 1532. The Most Recent Three Orders */
WITH cte1 AS (
    SELECT customer_id, order_id, order_date, RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS rank
    FROM orders)
SELECT name AS customer_name, cte1.customer_id, order_id, order_date
FROM customers
JOIN cte1 ON cte1.customer_id = customers.customer_id
WHERE rank <= 3
ORDER BY customer_name, cte1.customer_id, order_date DESC;

/* 1549. The Most Recent Orders for Each Product */
WITH table1 AS (SELECT order_id, order_date, customer_id, product_id, RANK() OVER(PARTITION BY product_id ORDER BY order_date DESC) AS rank
   FROM orders)
SELECT product_name, table1.product_id, order_id, order_date
FROM products
JOIN table1 ON products.product_id = table1.product_id
WHERE rank = 1
ORDER BY product_name, table1.product_id, order_id;

/* 1555. Bank Account Summary */
WITH table1 AS (SELECT user_id,IFNULL(SUM(CASE WHEN user_id = paid_by THEN -amount
                                WHEN user_id = paid_to THEN amount END),0) AS credit_amount
FROM users
LEFT JOIN transactions ON user_id IN (paid_by, paid_to)
GROUP BY user_id)
SELECT users.user_id, user_name, (credit+credit_amount) AS credit, CASE WHEN (credit+credit_amount) < 0 THEN 'Yes' ELSE 'No' END AS credit_limit_breached
FROM users
LEFT JOIN table1 ON table1.user_id = users.user_id;

/* 1596. The Most Frequently Ordered Products for Each Customer */
WITH table1 AS (SELECT customer_id, product_id, COUNT(order_id) AS f, RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_id) DESC) AS rank 
FROM orders
GROUP BY customer_id, product_id)
SELECT customer_id, table1.product_id, product_name
FROM table1
JOIN products ON products.product_id = table1.product_id
WHERE rank = 1;

/* 1613. Find the Missing IDs */
WITH RECURSIVE id_seq AS (
    SELECT 1 as initial_num
    UNION 
    SELECT initial_num + 1
    FROM id_seq
    WHERE initial_num < (SELECT MAX(customer_id) FROM Customers) 
)
SELECT initial_num AS ids
FROM id_seq
WHERE initial_num NOT IN (SELECT customer_id FROM Customers);

/* 1699. Number of Calls Between Two Persons */
SELECT LEAST (from_id, to_id) AS person1,
        GREATEST (from_id, to_id) AS person2,
    COUNT(duration) AS call_count,
    SUM(duration) AS total_duration       
FROM Calls
GROUP BY person1,person2;
