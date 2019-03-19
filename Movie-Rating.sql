/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');


/*
# Q1: 
Find the titles of all movies directed by Steven Spielberg.
*/
select title
from Movie
where director = "Steven Spielberg";


/*
# Q2: 
Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 
*/
select distinct year
from Movie
join Rating on Movie.mID=Rating.mID
where stars>=4 
order by year;


/*
# Q3: 
Find the titles of all movies that have no ratings. 
*/
select title
from Movie
where mID not in (select mID from Rating);


/*
# Q4: 
Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
*/
select name
from Reviewer
where rID in (select rID from Rating where ratingDate is Null);


/*
# Q5: 
Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
*/
select Reviewer.name, Movie.title, Rating.stars, Rating.ratingDate
from Movie
join Rating on Movie.mID=Rating.mID
join Reviewer on Rating.rID=Reviewer.rID
order by Reviewer.name, Movie.title, Rating.stars; 


/*
# Q6: 
For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
*/
select name, title
from Reviewer, Movie, Rating r1, Rating r2
where r1.mID=Movie.mID and Reviewer.rID=r1.rID 
  and r1.rID = r2.rID and r2.mID = Movie.mID
  and r1.mID=r2.mID
  and r1.stars < r2.stars and r1.ratingDate < r2.ratingDate;
  
select name, title
from Reviewer, Movie, Rating r1, Rating r2
where r1.mID=Movie.mID and Reviewer.rID=r1.rID 
  and r1.rID = r2.rID and r1.mID=r2.mID
  and r1.stars < r2.stars and r1.ratingDate < r2.ratingDate;
  
  
/*
# Q7: 
For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
*/
select title, max(stars)
from Movie, Rating
where Movie.mID=Rating.mID
group by title
order by title;

select title, max(stars)
from Movie, Rating
where Movie.mID=Rating.mID
group by Movie.mID
order by title;


/*
# Q8: 
For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
*/
select title, max(stars)-MIN(stars) as diff
from Movie, Rating
where Movie.mID=Rating.mID
group by Movie.mID
order by diff desc, title; 


/*
# Q9: 
Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 
*/
select before_1980 - after_1980
from 
 (select avg(average) as before_1980
  from
   (
    select Movie.mID, title, year,avg(stars) as average 
    from Movie, Rating
    where Movie.mID=Rating.mID and year <1980
    group by Movie.mID
   )
 ), 
 (select avg(average) as after_1980
  from
   (
    select Movie.mID, title, year,avg(stars) as average 
    from Movie, Rating
    where Movie.mID=Rating.mID and year >1980
    group by Movie.mID
   )
 ); 
 
 
 
 
 
 
 /* Movie-Rating Query Exercises Extras */
 
 /*
 # Q1:
 Find the names of all reviewers who rated Gone with the Wind. 
 */
select name
from Reviewer
where rID in 
  (
  	select rID 
  	from Rating, Movie 
  	where Rating.mID=Movie.mID and Movie.title ="Gone with the Wind"
  );
  
  
/*
# Q2: 
For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 
*/
select Movie.director, Movie.title, stars
from Movie, 
(
 select rID, mID, stars 
 from Rating 
 where rID in (select rID from Reviewer, Movie where Reviewer.name=Movie.director)
 ) as a
where Movie.mID = a.mID; 


/*
# Q3:
Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 
*/
select name from Reviewer
union 
select title from Movie; 


/*
# Q4:
Find the titles of all movies not reviewed by Chris Jackson. 
*/
select title
from Movie
where mID not in 
      (
      	select mID 
      	from Rating left Join Reviewer on Rating.rID=Reviewer.rID 
      	where Reviewer.name ='Chris Jackson'
      );
      

/*
# Q5:
For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 
*/
select distinct a.name, b.name
from Reviewer a, Reviewer b, Rating c, Rating d
where 
    a.rID=c.rID and 
    b.rID=d.rID and 
    a.name<b.name and 
    c.mID=d.mID
order by a.name, b.name; 


/*
# Q6:
For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 
*/
select rID, mID 
from Rating 
where stars in (select min(stars) from Rating); 
/* note: lowest stars in rating table */

select name, title, stars
from Movie, Rating, Reviewer
where Movie.mID=Rating.mID and 
      Rating.rID=Reviewer.rID and 
      stars in (select min(stars) from Rating); 


/*
# Q7:
List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 
*/
select mID, avg(stars) as mean
from Rating
group by mID; 
/* note: average stars for each movie in rating table */

select title, mean
from Movie, (select mID, avg(stars) as mean from Rating group by mID) as a
where Movie.mID=a.mID
order by mean desc, title; 


/*
# Q8:
Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.) 
*/
select rID, count(*) as num
from Rating
group by rID; 
/* note: number of rating made by each reviewers */

select name
from Reviewer, (select rID, count(*) as num from Rating group by rID) as a
where Reviewer.rID=a.rID and num>2; 


/*
# Q9:
Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 
*/
select a.title, a.director
from Movie as a
where (select count(*) from movie as b where a.director=b.director )>1
order by 1,2; 


/*
# Q10:
Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 
*/
select mID, avg(stars) as mean
from Rating
group by mID; 
/* note: finding the average stars in rating table */

select title, mean 
from Movie, (select mID, avg(stars) as mean from Rating group by mID) as a
where Movie.mID=a.mID; 
/* note: finding the title and average stars (joining Movie table) */

/* Another Way: */
select title, mean
from Movie, (select mID, avg(stars) as mean from Rating group by mID) as a
where Movie.mID=a.mID
group by title
having mean=(select max(mean) from (select mID, avg(stars) as mean from Rating group by mID)); 
/* note: There might be multiple results with maximum average stars */

/* Another Way: */
SELECT title, AVG(stars) AS average
FROM Movie
INNER JOIN Rating USING(mId)
GROUP BY mId
HAVING average = (
  SELECT MAX(average_stars)
  FROM (
    SELECT title, AVG(stars) AS average_stars
    FROM Movie
    INNER JOIN Rating USING(mId)
    GROUP BY mId
  )
);


/*
# Q11:
Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 
*/
select title, mean
from Movie, (select mID, avg(stars) as mean from Rating group by mID) as a
where Movie.mID=a.mID
group by title
having mean=(select min(mean) from (select mID, avg(stars) as mean from Rating group by mID)); 


/*
# Q12:
For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 
*/
select director, title, max(stars)
from Movie, Rating
where movie.mID=rating.mID and director is not null
group by director;  


