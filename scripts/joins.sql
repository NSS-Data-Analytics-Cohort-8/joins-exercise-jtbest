
-- ** Movie Database project. See the file movies_erd for table\column info. **

-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.

SELECT s.film_title, s.release_year, r.worldwide_gross
FROM specs as s
INNER JOIN revenue as r
USING (movie_id)
ORDER BY worldwide_gross
LIMIT 1;

--OR--

SELECT film_title, release_year, 
	(SELECT worldwide_gross
	FROM revenue
	WHERE movie_id = s.movie_id) as gross
FROM specs as s
ORDER BY gross
Limit 1;


--	Semi-Tough; 1977; 37187139

-- 2. What year has the highest average imdb rating

SELECT s.release_year, ROUND(AVG(imdb_rating),2) as avg_rating
FROM specs as s
INNER JOIN rating as r
USING (movie_id)
GROUP BY release_year
ORDER BY avg_rating DESC
LIMIT 1;

--OR--

SELECT (SELECT release_year
	   FROM specs
	   WHERE specs.movie_id = r.movie_id) as release_year, 
	   ROUND(AVG(imdb_rating),2) as avg_rating
FROM rating as r
GROUP BY release_year
ORDER BY avg_rating DESC
LIMIT 1;

--	1991 has an avg of 7.45

-- 3. What is the highest grossing G-rated movie? Which company distributed it?

SELECT s.film_title, d.company_name
FROM specs as s
INNER JOIN distributors as d
	ON s.domestic_distributor_id = d.distributor_id
INNER JOIN revenue as r
	ON s.movie_id = r.movie_id
WHERE s.mpaa_rating = 'G'
ORDER BY r.worldwide_gross DESC
LIMIT 1;

--OR--

SELECT s.film_title, (SELECT company_name
					 FROM distributors as d
					 WHERE d.distributor_id = s.domestic_distributor_id)
FROM specs as s
WHERE s.mpaa_rating = 'G'
ORDER BY (SELECT worldwide_gross
		  FROM revenue
		  WHERE s.movie_id=revenue.movie_id)DESC
LIMIT 1;


-- 	Toy Story 4, Walt Disney

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies 
-- table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

SELECT d.company_name, COUNT(s.film_title) as total_movies
FROM distributors as d
LEFT JOIN specs as s
ON d.distributor_id = s.domestic_distributor_id
GROUP BY d.company_name
ORDER BY total_movies DESC;



-- 5. Write a query that returns the five distributors with the highest average movie budget.

SELECT d.company_name, ROUND(AVG(r.film_budget),-3) as avg_budget
FROM distributors as d
INNER JOIN specs as s
ON d.distributor_id = s.domestic_distributor_id
INNER JOIN revenue as r
ON s.movie_id = r.movie_id
GROUP BY d.company_name
ORDER BY avg_budget DESC
LIMIT 5;

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

SELECT COUNT(*)
FROM distributors as d
INNER JOIN specs as s
ON d.distributor_id = s.domestic_distributor_id
INNER JOIN rating as r
ON s.movie_id = r.movie_id
WHERE d.headquarters NOT LIKE 'CA';

--	419 movies

SELECT s.film_title
FROM distributors as d
INNER JOIN specs as s
ON d.distributor_id = s.domestic_distributor_id
INNER JOIN rating as r
ON s.movie_id = r.movie_id
WHERE d.headquarters NOT LIKE 'CA'
ORDER BY r.imdb_rating DESC
LIMIT 1;

--	The Dark Knight

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

SELECT 
	CASE WHEN s.length_in_min > 120 THEN 'Longer than 2 hours'
		ELSE 'Shorter than 2 hours' END AS duration, 
		ROUND(AVG(r.imdb_rating),1) as avg_rating
FROM specs as s
INNER JOIN rating as r
USING (movie_id)
GROUP BY duration
ORDER BY avg_rating DESC;

-- Movies longer than 2 hours have a higher avg rating 


-- Extra work

-- 1.	Find the total worldwide gross and average imdb rating by decade. Then alter your query so it returns JUST the second highest average imdb rating and its decade. This should result in a table with just one row.

SELECT 
	CASE WHEN s.release_year BETWEEN 1960 AND 1970 THEN '1960s'
		WHEN s.release_year BETWEEN 1970 AND 1980 THEN '1970s'
		WHEN s.release_year BETWEEN 1980 AND 1990 THEN '1980s'
		WHEN s.release_year BETWEEN 1990 AND 2000 THEN '1990s'
		WHEN s.release_year BETWEEN 2000 AND 2010 THEN '2000s'
		WHEN s.release_year BETWEEN 2010 AND 2020 THEN '2010s'
		ELSE 'N/A' END as decade,
		SUM(re.worldwide_gross) as gross_sum,
		ROUND(AVG(ra.imdb_rating),2) as avg_rating
 FROM specs as s
 INNER JOIN revenue as re
 USING (movie_id)
 INNER JOIN rating as ra
 USING (movie_id)
 GROUP BY decade
 ORDER BY decade;


-- need to figure out how to get that second largest avg isolated. maybe window? hmm


-- 2.	Our goal in this question is to compare the worldwide gross for movies compared to their sequels. 

-- a.	Start by finding all movies whose titles end with a space and then the number 2.

SELECT film_title
FROM specs
WHERE film_title LIKE '% 2'


-- b.	For each of these movies, create a new column showing the original film’s name by removing the last two characters of the film title. For example, for the film “Cars 2”, the original title would be “Cars”. Hint: You may find the string functions listed in Table 9-10 of https://www.postgresql.org/docs/current/functions-string.html to be helpful for this. 

SELECT trim(' 2' FROM film_title) as original, film_title as sequel
FROM specs
WHERE film_title LIKE '% 2'


-- c.	Bonus: This method will not work for movies like “Harry Potter and the Deathly Hallows: Part 2”, where the original title should be “Harry Potter and the Deathly Hallows: Part 1”. Modify your query to fix these issues. 


SELECT film_title as sequel, 
FROM specs
WHERE film_title LIKE '% 2'


-- d.	Now, build off of the query you wrote for the previous part to pull in worldwide revenue for both the original movie and its sequel. Do sequels tend to make more in revenue? Hint: You will likely need to perform a self-join on the specs table in order to get the movie_id values for both the original films and their sequels. Bonus: A common data entry problem is trailing whitespace. In this dataset, it shows up in the film_title field, where the movie “Deadpool” is recorded as “Deadpool “. One way to fix this problem is to use the TRIM function. Incorporate this into your query to ensure that you are matching as many sequels as possible.







-- ________________________________________
-- 3.	Sometimes movie series can be found by looking for titles that contain a colon. For example, Transformers: Dark of the Moon is part of the Transformers series of films.
-- ​
-- a.	Write a query which, for each film will extract the portion of the film name that occurs before the colon. For example, “Transformers: Dark of the Moon” should result in “Transformers”.  If the film title does not contain a colon, it should return the full film name. For example, “Transformers” should result in “Transformers”. Your query should return two columns, the film_title and the extracted value in a column named series. Hint: You may find the split_part function useful for this task.
-- b.	Keep only rows which actually belong to a series. Your results should not include “Shark Tale” but should include both “Transformers” and “Transformers: Dark of the Moon”. Hint: to accomplish this task, you could use a WHERE clause which checks whether the film title either contains a colon or is in the list of series values for films that do contain a colon.
-- c.	Which film series contains the most installments?
-- d.	Which film series has the highest average imdb rating? Which has the lowest average imdb rating?
-- ________________________________________
-- 4.	How many film titles contain the word “the” either upper or lowercase? How many contain it twice? three times? four times? Hint: Look at the sting functions and operators here: https://www.postgresql.org/docs/current/functions-string.html 
-- ________________________________________
-- 5.	For each distributor, find its highest rated movie. Report the company name, the film title, and the imdb rating. Hint: you may find the LATERAL keyword useful for this question. This keyword allows you to join two or more tables together and to reference columns provided by preceding FROM items in later items. See this article for examples of lateral joins in postgres: https://www.cybertec-postgresql.com/en/understanding-lateral-joins-in-postgresql/ 
-- ​
-- 6.	Follow-up: Another way to answer 5 is to use DISTINCT ON so that your query returns only one row per company. You can read about DISTINCT ON on this page: https://www.postgresql.org/docs/current/sql-select.html. 
-- ​
-- 7.	Which distributors had movies in the dataset that were released in consecutive years? For example, Orion Pictures released Dances with Wolves in 1990 and The Silence of the Lambs in 1991. Hint: Join the specs table to itself and think carefully about what you want to join ON. 