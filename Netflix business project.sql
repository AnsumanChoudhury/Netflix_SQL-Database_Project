--- Netflix Database Project
create table Netflix (
    show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)

);

select * from Netflix;
select count(*) as total_content from Netflix;
select distinct type from netflix;

-- 14 Business Problems based on the data

-- 1. Count the number of movies vs TV shows
select type, count(*) as total_count
from Netflix
group by type;

-- 2. Find the most common rating for movies and TV Shows
with rating_counts as 
(select type, rating, count(*) as rating_count,
row_number() over (partition by type order by count(*) desc) as rn
from Netflix
group by type, rating)
select type, rating, rating_count
from rating_counts
where rn=1;

-- 3. List all movies released in a specific year (e.g., 2020)
select * from Netflix
where type='Movie' and release_year='2020';

-- 4. Find the top 5 countries with the most content on Netflix
select unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content
from Netflix
group by new_country
order by total_content desc
limit 5;

-- 5. Identify the longest movie
select * from Netflix
where type='Movie' and duration=(select max(duration) from Netflix);

-- 6. Find content added in the last 5 years
SELECT * FROM netflix
WHERE date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$'
  AND TO_DATE(date_added, 'DD-Mon-YY') >= (CURRENT_DATE - INTERVAL '5 years');

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from Netflix
where director ILIKE 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
select * from Netflix
where type= 'TV Show'
      and CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;

-- 9. Count the number of content items in each genre
select UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
count(show_id) as total_content
from Netflix
group by genre
order by total_content desc;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
SELECT 
    release_year,
    COUNT(*)::DECIMAL AS avg_content_release
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY release_year
ORDER BY avg_content_release DESC
LIMIT 5;

-- 11. Which 5 actors/actresses have appeared in the most Netflix titles
-- Insight: Helps us to identify the most common actors featured on Netflix, showing who dominates the platform’s content library.
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
    COUNT(*) AS total_titles
FROM netflix
WHERE casts IS NOT NULL
GROUP BY actor
ORDER BY total_titles DESC
LIMIT 5;

-- 12. Which 5 genres (listed in the listed_in column) have the most Netflix titles?
-- Insight: Tells us the top genres on Netflix, helping understand 
-- whether Netflix prioritizes Drama, Comedy, Kids, Documentaries, etc.
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_titles
FROM netflix
WHERE listed_in IS NOT NULL
GROUP BY genre
ORDER BY total_titles DESC
LIMIT 5;

-- 13. For each year, find the director(s) who released the highest number of titles on Netflix. 
-- Show the year, director, and number of titles. 
-- If multiple directors tie for the top spot in a year, show them all.
WITH yearly_director_counts AS (
    SELECT 
        release_year,
        director,
        COUNT(*) AS total_titles
    FROM netflix
    WHERE director IS NOT NULL
    GROUP BY release_year, director
),
ranked_directors AS (
    SELECT 
        release_year,
        director,
        total_titles,
        RANK() OVER (PARTITION BY release_year ORDER BY total_titles DESC) AS rnk
    FROM yearly_director_counts
)
SELECT 
    release_year,
    director,
    total_titles
FROM ranked_directors
WHERE rnk = 1
ORDER BY release_year DESC;

-- 14. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
-- Label content containing these keywords as 'Bad' and all other content as 'Good'. 
-- Count how many items fall into each category.
select
case when description ILIKE '%kill%'
or 
description ILIKE '%VIOLENCE%' then 'Bad'
else 'Good'
end as Content_Category,
count(*) as total_titles
from Netflix
group by Content_Category
Order by total_titles;



