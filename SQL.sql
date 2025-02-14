--SQL Famous Paintings & Museum Dataset:

--Overview Tables

SELECT * FROM artist
SELECT * FROM canvas_size
SELECT * FROM museum
SELECT * FROM museum_hours
SELECT * FROM product_size
SELECT * FROM subject 
SELECT * FROM work


--1) Fetch all the paintings which are not displayed on any museums?

SELECT name FROM work 
WHERE museum_id IS NULL

--2) Are there museuems without any paintings?

SELECT museum_id, name FROM museum
WHERE museum_id  IN (SELECT DISTINCT museum_id FROM work 
 WHERE NOT museum_id  IS NULL)

--3) How many paintings have an asking price of more than their regular price? 

SELECT counT(*) FROM product_size 
WHERE sale_price >= regular_price

--4) Identify the paintings whose asking price is less than 50% of its regular price

SELECT * FROM product_size 
WHERE sale_price*2 < regular_price

--5) Which canva size costs the most?

SELECT size_id, sale_price FROM product_size 
GROUP BY size_id, sale_price 
ORDER BY sale_price DESC
LIMIT 3


--6) Delete duplicate records from work, product_size, subject and image_link tables

--A.

DELETE FROM work 
WHERE work_id IN (SELECT work_id from 
                  (SELECT work_id, 
                  ROW_NUMBER() OVER(PARTITION BY work_id ORDER BY (SELECT NULL)) AS row_n
                  FROM work) as subquery
WHERE row_n > 1)

--B. 

DELETE FROM product_size WHERE work_id IN (
  	SELECT work_id FROM(
      SELECT work_id, ROW_NUMBER() OVER(PARTITION BY work_id ORDER BY work_id) AS row_n 
      from product_size) as subquery 
  		WHERE row_n > 1)

--C. 

DELETE from subject WHERE work_id in(
  	SELECT work_id FROM( 
      SELECT work_id, ROW_NUMBER() OVER(PARTITION BY work_id ORDER BY work_id) AS ROW_N 
      FROM subject) AS subquery 
  		WHERE ROW_N > 1)

--7) Identify the museums with invalid city information in the given dataset

--Postgresql

SELECT * FROM museum 
    WHERE city ~ '[A-Za-z]'

--MYSQL

SELECT * FROM museum
WHERE city REGEXP '[A-Za-z]'

--MSSQL

SELECT * FROM museum
WHERE city LIKE '%[A-Za-z]%'


--8) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT ms.museum_id ,ms.name, ms.city FROM museum_hours as mh 
JOIN museum AS ms ON mh.museum_id = ms.museum_id
WHERE day='Sunday' 
and EXISTs (SELECT 1 FROM museum_hours mh2 
            WHERE mh.museum_id=mh2.museum_id
            and mh2.day ='Monday')


--9) Which are the 3 most popular and 3 least popular painting styles?

SELECT * FROM (
  (SELECT DISTINCT subject, COUNT(*) AS cOUNT FROM subject 
GROUP by subject ORDER by 2 desc LIMIT 3) 

UNION 

(SELECT DISTINCT subject, COUNT(*) AS cOUNT FROM subject 
GROUP by subject ORDER by 2 ASC LIMIT 3)
) as s 
ORDER BY 2 DESC




--10) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

SELECT  a.full_name, COUNT(*) as no_of_paintings, a.nationality  
FROM work AS w 
JOIN artist as a on w.artist_id = a.artist_id 
JOIN museum as m on w.museum_id = m.museum_id 
WHERE M.country not in ('USA') 
GROUP by a.full_name, a.nationality 
ORDER by COUNT(*) DESC
LIMIT 3 


--11) How many museums are open every single day?

SELECT name from (
  SELECT m.name, mh.day, 
ROW_NUMBER() OVER(PARTITION BY M.name) AS ROW_N
from museum m 
JOIN museum_hours mh on m.museum_id = mh.museum_id 
GROUP by m.name, mh.day 
ORDER by m.name
	) as d 
WHERE row_n =7

--12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT ms.name,  count(*) FROM work as w 
JOIN museum ms on w.museum_id = ms.museum_id
GROUP by ms.name
ORDER by 2 desc
LIMIT 5

--13) How many paintings of each painting styles?

SELECT subject, counT(*) FROM subject
GROUP BY subject 
ORDER BY 2 DESC

--14) Display the 3 least popular canva sizes

SELECT label, count(*) from canvas_size 
GROUP by label 
order by 2 
LIMIT 3

--15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

SELECT name,state,day
from (SELECT ms.name,ms.state,mh.day,  to_timestamp(close, 'HH:MI PM') as close,
to_timestamp(open, 'HH:MI AM') AS open,
to_timestamp(close, 'HH:MI PM') - to_timestamp(open, 'HH:MI AM') AS duration,
rank() over(order by (to_timestamp(close, 'HH:MI PM') - to_timestamp(open, 'HH:MI AM')) desc) as rank_
FROM museum_hours mh 
JOIN museum as ms on mh.museum_id =ms.museum_id) x
WHERE rank_=1

--16) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. 
--If there are multiple value, seperate them with comma.

WITH cte1 as (
  SELECT country, COUNT(*),
	RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk 
	FROM museum 
	GROUP BY country),
cte2 as (
  SELECT city, COUNT(*),
	RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
	FROM museum 
	GROUP BY city) 
    
SELECT string_agg(DISTINCT country,', ') as country, string_agg(city,', ') as city 
FROM cte1 
cross JOIN cte2 
WHERE cte1.rnk =1 and cte2.rnk =1



















