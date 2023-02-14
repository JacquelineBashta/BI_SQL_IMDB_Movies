## Explore columns
####################
-- movies table
-- ------------

SELECT max(movies.rank)
FROM movies;
SELECT min(movies.rank)
FROM movies;

SELECT *
FROM movies;

-- 1. index   : incremental unique value
-- 2. id (PK) : unique value not incremental (0-412320)
-- 3. name    : no null , not all english, require cleaning , no null
-- 4. year    : no null , clean integer
-- 5. rank    : 83% null, float between 1 and 9.9

############################################################
-- movie_genres table
-- ---------------------
select *
from movies_genres;

select distinct genre
from movies_genres;

select count(*)
from movies_genres
where genre is not null;

-- 
-- 1. index         : incremental unique value (0-395118)
-- 2. movie_id (FK) : NOT unique value not incremental (1-378614)  --> not all movies has genre entry
-- 3. genre         : no null, cat values [Documentary,Short,Comedy,Crime,Western,Family,Animation,Drama,Romance,Mystery,Thriller,Adult,Music,Action,Fantasy,Sci-Fi,Horror,War,Musical,Adventure,Film-Noir]

############################################################
-- roles table
-- ------------
select count(*)
from roles
-- where role = ""
;

-- roles
-- 1. index         : incremental unique value (0-3431965)
-- 2. actor_id (FK) : NOT unique value (2-845465) 
-- 3. movie_id (FK) : NOT unique value (1-412319) 
-- 4. role          : string , no null , 27% (empty string)

############################################################
-- actors table
-- ------------
select *
from actors
;

select distinct(gender)
from actors
;

select count(distinct(id))
from actors
;

-- actors
-- 1. index         : incremental unique value (0-817717)
-- 2. id (PK) 		: unique value (2-845465) 
-- 3. first_name 	: no null, string
-- 4. last_name     : no null, string , no null
-- 5. gender 		: no null, cat values [M,F]

############################################################
-- directors table
-- -----------------

select *
from directors;

select count(distinct(id))
from directors
-- where first_name = ""
;

-- 1. index         : incremental unique value (0-86879)
-- 2. id (PK) 		: unique value (1-88801) 
-- 3. first_name 	: no null, string
-- 4. last_name     : no null, string

############################################################
-- movies_directors table
-- ---------------------
select *
from movies_directors
;

-- 1. index            : incremental unique value (0-371179)
-- 2. director_id (FK) : NOT unique value (1-88801) 
-- 3. movie_id (FK)    : NOT unique value (0-412320) 

############################################################
-- directors_genres table
-- ---------------------
select *
from directors_genres
;

-- 1. index         : incremental unique value (0-156561)
-- 2. director_id (FK) : NOT unique value not incremental (2-88800) 
-- 3. genre         : no null, cat values [Short,Drama,Documentary,Action,Adventure,Comedy,Crime,Family,Romance,Thriller,Animation,Horror,Sci-Fi,Musical,War,Western,Mystery,Fantasy,Music,Film-Noir]
-- 4. prob          : no null, float (0.0.00162075 - 1)

###############################################################
## Answer questions
###############################################################
## The big picture
##################
-- How many actors are there in the actors table?
select count(distinct(id))
from actors;
-- -----------------------------------------------
-- How many directors are there in the directors table?
select count(distinct(id))
from directors;
-- -----------------------------------------------
-- How many movies are there in the movies table?
select count(distinct(id))
from movies;
-- -----------------------------------------------
## Exploring the movies
#######################
-- From what year are the oldest and the newest movies? What are the names of those movies?

select name , year
from movies
where (
	(year = (select min(year) from movies)) | 
    (year = (select max(year) from movies))
    )
;
-- -----------------------------------------------
-- What movies have the highest and the lowest ranks?
select movies.name , movies.rank
from movies
where (
	((movies.rank = (select min(movies.rank) from movies)) or 
    (movies.rank = (select max(movies.rank) from movies)))
      )
order by movies.rank desc;

-- -----------------------------------------------
-- What is the most common movie title?
select count(*) as title_count , name
from movies
group by name
order by title_count desc
limit 1;
-- -----------------------------------------------
## Understanding the database
##############################
-- Are there movies with multiple directors?
select count(distinct(director_id)) as directors_per_movie
from movies_directors
group by movie_id
having directors_per_movie > 1
order by directors_per_movie desc
;
-- -----------------------------------------------
-- What is the movie with the most directors? Why do you think it has so many?
--  its a series that last between 1984 till 2010 with total of 2,425 episodes!
with movie_max_directors as(
select count(distinct(director_id)) as directors_per_movie , movie_id
from movies_directors
group by movie_id
having directors_per_movie > 1
order by directors_per_movie desc
limit 1)
select directors_per_movie , movies.name , movies.year
from movie_max_directors
join movies
on movie_max_directors.movie_id = movies.id;
;
-- -----------------------------------------------
-- On average, how many actors are listed by movie?

-- distribution
with t as(
select (count(distinct(actor_id))) as n_actors , movie_id
from roles
group by movie_id)
select avg(n_actors) from t;
;

--  avg value hint: don't add distinct for actor_id as same actor can work in different movies
select (count(actor_id) / count(distinct(movie_id))) as avg_actors_per_movie
from roles
;
-- -----------------------------------------------
-- Are there movies with more than one “genre”?
select movie_id, count(distinct(genre)) as num_genre_per_movie
from movies_genres
group by movie_id
having num_genre_per_movie > 1
order by num_genre_per_movie desc
;
-- -----------------------------------------------
## Looking for specific movies
##############################
-- Can you find the movie called “Pulp Fiction”?
select *
from movies
-- where name like "%Pulp Fiction%"
where name = "Pulp Fiction"
;

-- -----------------------------------------------
-- Who directed it?
with movie_info as(
select id , name
from movies
where name = "Pulp Fiction"
)
select name,first_name, last_name
from movie_info
join movies_directors
on movie_info.id = movies_directors.movie_id
join directors
on movies_directors.director_id = directors.id
;

-- -----------------------------------------------
-- Which actors where casted on it?
with movie_info as(
select id , name
from movies
where name = "Pulp Fiction"
)
select distinct(actor_id), first_name , last_name , gender
from movie_info
join roles
on movie_info.id = roles.movie_id
join actors
on roles.actor_id = actors.id
;
-- -----------------------------------------------
-- Can you find the movie called “La Dolce Vita”?
select *
from movies
where name like "%La Dolce Vita%"
-- where name = "La Dolce Vita"
;
-- -----------------------------------------------
-- Who directed it?
with movie_info as(
select id , name
from movies
where name like "%La Dolce Vita%"
)
select name,first_name, last_name
from movie_info
join movies_directors
on movie_info.id = movies_directors.movie_id
join directors
on movies_directors.director_id = directors.id
;
-- -----------------------------------------------
-- Which actors where casted on it?
with movie_info as(
select id , name
from movies
where name like "%La Dolce Vita%"
)
select distinct(actor_id), first_name , last_name , gender
from movie_info
join roles
on movie_info.id = roles.movie_id
join actors
on roles.actor_id = actors.id
;
-- -----------------------------------------------
-- When was the movie “Titanic” by James Cameron released?
with movie_info as(
select  name , id , year
from movies
where name like "Titanic"
)
select name,first_name, last_name , year
from movie_info
join movies_directors
on movie_info.id = movies_directors.movie_id
join directors
on movies_directors.director_id = directors.id
where (first_name like "%James%" and last_name like "%Cameron%")
;
-- -----------------------------------------------
## Actors and directors
##############################
-- Who is the actor that acted more times as “Himself”?
with winer_actor_info as (
select count(distinct(movie_id)) as num_himself_per_actor,actor_id
from roles
where role like "%Himself%"
group by actor_id
order by num_himself_per_actor desc
limit 1)
select num_himself_per_actor , first_name , last_name, gender
from winer_actor_info
join actors
on actors.id = winer_actor_info.actor_id;
-- -----------------------------------------------
-- What is the most common name for actors? And for directors?
-- Q : first name or full name?
select count(distinct(id)) as num_of_actors , first_name , last_name
from actors
group by first_name, last_name
order by num_of_actors desc
limit 1;


select count(distinct(id)) as num_of_directors , first_name , last_name
from directors
group by first_name, last_name
order by num_of_directors desc
limit 1;
-- -----------------------------------------------
## Analysing genders
##############################
-- How many actors are male and how many are female?

with male_female as (
SELECT
  COUNT(CASE WHEN gender = 'M' THEN (id) END) AS male,
  COUNT(CASE WHEN gender = 'F' THEN (id) END) AS female,
  COUNT(*) AS Total
FROM actors)
select male , round(male*100/total ,2) as male_pct ,female, round(female*100/total,2) as female_pct
from male_female
;

-- What percentage of actors are female, and what percentage are male?

-- -----------------------------------------------
## Movies across time
##############################
-- How many of the movies were released after the year 2000?
select count(distinct(id)) as movies_after_2000
from movies
where year > 2000
;
-- -----------------------------------------------
-- How many of the movies where released between the years 1990 and 2000?
select count(distinct(id)) as movies_bet_1990_2000
from movies
where year between 1990 and 2000
;
-- -----------------------------------------------
-- Which are the 3 years with the most movies? How many movies were produced on those years?
select count(distinct(id))as movies_count, year 
from movies
group by year
order by movies_count desc
limit 3;
-- -----------------------------------------------
-- What are the top 5 movie genres?
select count(distinct(movie_id)) as num_genre, genre
from movies_genres
group by genre
order by num_genre desc
limit 5 ;

-- -----------------------------------------------
-- What are the top 5 movie genres before 1920?
select count(distinct(movie_id)) as num_genre, genre
from movies_genres
join movies
on movies.id = movies_genres.movie_id
where movies.year < 1920
group by genre
order by num_genre desc
limit 5 
;
select max(year)
from movies;
-- -----------------------------------------------
-- What is the evolution of the top movie genres across all the decades of the 20th century?
with genre_count_per_decade as (
select rank() over (partition by decade order by movies_per_genre desc) ranking, genre, decade
from (SELECT 
    genre,
    FLOOR(m.year / 10) * 10 AS decade,
    COUNT(genre) AS movies_per_genre
FROM
    movies_genres mg
        JOIN
    movies m ON m.id = mg.movie_id
GROUP BY decade , genre) as a
)
select genre, decade
FROM genre_count_per_decade
WHERE ranking = 1;

with all_genres as (
	select count(movie_id) as num_movies , genre , (floor(year/10)*10) as decade
	from movies
	join movies_genres
	on movies.id = movies_genres.movie_id
	group by decade, genre
	having decade >= 1900
	)
select num_movies, genre, decade
from (
	select *, row_number() over(partition by decade order by num_movies desc) row_num
	from all_genres
	) rn_q
where row_num = 1;

-- -----------------------------------------------
## Putting it all together: names, genders and time
#########################################################
-- Has the most common name for actors changed over time?
-- Get the most common actor name for each decade in the XX century.
-- Q : why I get different answer when I use count(actors.id)  instead of count(actors.first_name) ??
 with all_actors as (
select count(actors.first_name) as actors_num , first_name  , (floor(year/10)*10) as decade
from actors
join roles on actors.id = roles.actor_id
join movies on movies.id = roles.movie_id
group by decade , first_name

)
select t.actors_num , t.first_name , t.decade 
from (
	select *, rank() over ( partition by decade order by actors_num desc) as rk_actors_num
	from all_actors
    ) as t
where rk_actors_num = 1;

-- -----------------------------------------------
-- Re-do the analysis on most common names, splitted for males and females.
 with all_actors as (
select count(actors.first_name) as actors_num , first_name  ,gender, (floor(year/10)*10) as decade
from actors
join roles on actors.id = roles.actor_id
join movies on movies.id = roles.movie_id
-- where gender = "M"
group by decade , first_name,gender

)
select t.actors_num , t.first_name , t.gender , t.decade 
from (
	select *, rank() over ( partition by decade,gender order by actors_num desc) as rk_actors_num
	from all_actors
    ) as t
where rk_actors_num = 1
;
-- -----------------------------------------------
-- How many movies had a majority of females among their cast?
-- What percentage of the total movies had a majority female cast?
## Question : percentage shall be calc num_female_movie/ (select count(id) from movies) and not /(select count(distinct(movie_id)
with overall_q as(
	with cast_split as (
		select movies.id ,
			count(case when gender = 'M' then (actors.id) end) as male_cast,
			count(case when gender = 'F' then (actors.id) end) as female_cast
		from movies
		join roles on movies.id = roles.movie_id
		join actors on roles.actor_id = actors.id 
		group by movies.id
						)
	select count(id) as num_female_movie
	from cast_split
	where female_cast > male_cast
)
select * , (100*num_female_movie/ (select count(id) from movies)) as pct_female_movies
from overall_q ;
-- -----------------------------------------------
