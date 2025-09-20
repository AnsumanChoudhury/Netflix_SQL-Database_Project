# Netflix Movies and TV Shows Data Analysis using SQL
![](https://github.com/AnsumanChoudhury/Netflix_SQL-Database_Project/blob/main/logo.png)

## 📖 Overview
This project explores **Netflix's content dataset** using **PostgreSQL**.  
It involves designing a database schema, inserting the dataset, and solving **14 real-world business problems** using SQL queries.  
The goal is to gain **insights about Netflix’s library**, including trends in content type, ratings, countries, directors, genres, and more.  

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.
---

## 🛠️ Database Schema
```sql
CREATE TABLE Netflix (
    show_id       VARCHAR(5),
    type          VARCHAR(10),
    title         VARCHAR(250),
    director      VARCHAR(550),
    casts         VARCHAR(1050),
    country       VARCHAR(550),
    date_added    VARCHAR(55),
    release_year  INT,
    rating        VARCHAR(15),
    duration      VARCHAR(15),
    listed_in     VARCHAR(250),
    description   VARCHAR(550)
);

## Business Problems Solved(with SQL queries)

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(*) AS total_count
FROM Netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH rating_counts AS (
    SELECT type, rating, COUNT(*) AS rating_count,
           ROW_NUMBER() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rn
    FROM Netflix
    GROUP BY type, rating
)
SELECT type, rating, rating_count
FROM rating_counts
WHERE rn = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM Netflix
WHERE type = 'Movie' AND release_year = 2020;

```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
       COUNT(show_id) AS total_content
FROM Netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT * 
FROM Netflix
WHERE type = 'Movie' 
  AND duration = (SELECT MAX(duration) FROM Netflix);

```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT * 
FROM Netflix
WHERE date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$'
  AND TO_DATE(date_added, 'DD-Mon-YY') >= (CURRENT_DATE - INTERVAL '5 years');
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select * from Netflix
where director ILIKE 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * 
FROM Netflix
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;

```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
       COUNT(show_id) AS total_content
FROM Netflix
GROUP BY genre
ORDER BY total_content DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average number of content releases in India (Top 5 years)

```sql
SELECT release_year,
       COUNT(*)::DECIMAL AS avg_content_release
FROM Netflix
WHERE country ILIKE '%India%'
GROUP BY release_year
ORDER BY avg_content_release DESC
LIMIT 5;

```

**Objective:** Calculate the average number of content releases by India each year

### 11. Top 5 actors/actresses with the most Netflix titles

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
       COUNT(*) AS total_titles
FROM Netflix
WHERE casts IS NOT NULL
GROUP BY actor
ORDER BY total_titles DESC
LIMIT 5;

```



### 12. Top 5 most common genres on Netflix

```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
       COUNT(*) AS total_titles
FROM Netflix
WHERE listed_in IS NOT NULL
GROUP BY genre
ORDER BY total_titles DESC
LIMIT 5;

```



### 13. For each year, find the director(s) with the most releases

```sql
WITH yearly_director_counts AS (
    SELECT release_year, director, COUNT(*) AS total_titles
    FROM Netflix
    WHERE director IS NOT NULL
    GROUP BY release_year, director
),
ranked_directors AS (
    SELECT release_year, director, total_titles,
           RANK() OVER (PARTITION BY release_year ORDER BY total_titles DESC) AS rnk
    FROM yearly_director_counts
)
SELECT release_year, director, total_titles
FROM ranked_directors
WHERE rnk = 1
ORDER BY release_year DESC;
```


### 14. Categorize content as 'Good' or 'Bad' based on keywords in description
```sql
SELECT CASE 
           WHEN description ILIKE '%kill%' 
             OR description ILIKE '%violence%' THEN 'Bad'
           ELSE 'Good'
       END AS content_category,
       COUNT(*) AS total_titles
FROM Netflix
GROUP BY content_category
ORDER BY total_titles;

```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Key Insights

-- Netflix has more movies than TV shows, but TV shows dominate in binge-watching trends.

-- Certain actors and genres dominate the platform, showing Netflix’s content strategy.

-- Directors like Rajiv Chilaka are consistent contributors.

-- India has had spikes in content releases in specific years.

-- Around Netflix’s library, only a fraction contains explicit or violent descriptions.
-- This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

## Author - Ansuman Choudhury, B.Tech from NIT Rourkela
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/ansuman-choudhury-316a69247/)
