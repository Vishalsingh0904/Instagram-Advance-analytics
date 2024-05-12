-- Mandatory Project (Advance Sql)

use ig_clone; -- Dataset

-- 1. How many times does the average user post?

SELECT AVG(post_count) AS average_posts_per_user
FROM (
    SELECT user_id, COUNT(*) AS post_count
    FROM photos
    GROUP BY user_id
) AS user_post_counts;


-- 2. Find the top 5 most used hashtags ?

select tag_name, count(tag_name) as total from tags t join photo_tags pt
on t.id = pt.tag_id 
group by t.id order by total desc
limit 5;

-- 3. Find users who have liked every single photo on the site ?

with cte_total_likes as (
select username, count(id) as total from users u
join likes l 
on u.id = l.user_Id
group by u.id
)
select * from cte_total_likes where total =(select count(*) from photos);


-- 4 Retrieve a list of users along with their usernames and the rank of their account creation,
-- ordered by the creation date in ascending order ?
 
select user_id, username, users.created_at,
rank () over (order by users.created_at) as 'rank'
from users 
inner join photos on users.id = photos.user_id group by user_id, username ;
 
 -- 5 List the comments made on photos with their comment texts, photo URLs,
 -- and usernames of users who posted the comments.
 -- Include the comment count for each photo ?

WITH CommentCounts AS (                                  #CommentCounts CTE -- calculates the count of comments for each photo
    SELECT 
        photo_id,
        COUNT(comment_text) AS c_count
    FROM 
        comments
    GROUP BY 
        photo_id
),
PhotoComments AS (                                #PhotoComments CTE - retrieves the username of the user who posted the comment,
    SELECT                                                             --  the comment text, the photo URL, and the photo ID
        u.username, 
        c.comment_text, 
        p.image_url,
        c.photo_id
    FROM 
        photos p
    JOIN 
        comments c ON p.id = c.photo_id
    JOIN 
        users u ON c.user_id = u.id
)
SELECT                            #Main Query -selects columns from the PhotoComments and CommentCounts CTEs
    pc.username,
    pc.comment_text,
    pc.image_url,
    cc.c_count
FROM 
    PhotoComments pc
JOIN 
    CommentCounts cc ON pc.photo_id = cc.photo_id;


    
-- 6.For each tag, show the tag name and the number of photos associated with that tag.
-- Rank the tags by the number of photos in descending order ?

SELECT 
    tag_name,
    num_photos,
    RANK() OVER (ORDER BY num_photos DESC) AS tag_rank
FROM (
    SELECT 
        t.tag_name,
        COUNT(pt.photo_id) AS num_photos
    FROM 
        tags t
    LEFT JOIN 
        photo_tags pt ON t.id = pt.tag_id
    GROUP BY 
        t.tag_name
) AS tag_counts;


-- 7.List the usernames of users who have posted photos along with the count of photos they have posted.
-- Rank them by the number of photos in descending order ?
    
SELECT 
    username,
    no_of_photos,
    RANK() OVER (ORDER BY no_of_photos DESC) AS user_rank
FROM (
    SELECT 
        u.username,
        COUNT(p.id) AS no_of_photos 
    FROM 
        photos p 
    JOIN 
        users u ON p.user_id = u.id 
    GROUP BY 
        u.username 
) AS user_photo_counts;



-- 8.Display the username of each user along with the creation date of their
-- first posted photo and the creation date of their next posted photo ? 

select username, created_at,
lag(created_at) over (order by created_at) as first_post, 
lead(created_at) over (order by created_at) as next_post 
from users;

-- 9.For each comment, show the comment text, the username of the commenter, and the comment text of 
-- the previous comment made on the same photo ?

SELECT
    u.username AS commenter_username,
    c.comment_text AS comment_text,
    LAG(c.comment_text) OVER (PARTITION BY c.photo_id ORDER BY c.id) AS previous_comment_text
FROM
    comments c
JOIN
    users u ON c.user_id = u.id
ORDER BY
    c.photo_id, c.id;
    
    -- 10.Show the username of each user along with the number of photos they have posted and the number of photos posted
    -- by the user before them and after them, based on the creation date ?
    
    SELECT
    u.username,
    p.num_photos AS photos_posted,
    LAG(p.num_photos) OVER (ORDER BY u.created_at) AS prev_photos,
    LEAD(p.num_photos) OVER (ORDER BY u.created_at) AS next_photos
FROM users u
JOIN (
    SELECT
        user_id,
        COUNT(*) AS num_photos
    FROM photos
    GROUP BY user_id
) p ON u.id = p.user_id
ORDER BY u.created_at;
