
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

-- 	Toy Story 4, Walt Disney

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies 
-- table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

SELECT d.company_name, COUNT(s.film_title) as total_movies
FROM distributors as d
INNER JOIN specs as s
ON d.distributor_id = s.domestic_distributor_id
GROUP BY d.company_name
ORDER BY total_movies DESC;


-- 5. Write a query that returns the five distributors with the highest average movie budget.

SELECT d.company_name, ROUND(AVG(r.film_budget),1) as avg_budget
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
ORDER BY r.imdb_rating
LIMIT 1;

--	Jaws 3-D

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

SELECT 
	CASE WHEN s.length_in_min >= 120 THEN 'Longer than 2 hours'
		ELSE 'Shorter than 2 hours' END AS duration, 
		ROUND(AVG(r.imdb_rating),1) as avg_rating
FROM specs as s
INNER JOIN rating as r
USING (movie_id)
GROUP BY duration
ORDER BY avg_rating DESC;

-- Movies longer than 2 hours have a higher avg rating 