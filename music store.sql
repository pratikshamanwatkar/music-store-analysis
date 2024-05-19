-- who is the senior most employee based on job title ?
select * from employee order by levels desc limit 1;
-- which countries have the most invoices ?
select count(*) as c, billing_country from invoice
group by billing_country
order by c desc limit 5;
--what are top 3 values of total invoice ?
select total from invoice
order by total desc limit 3;
-- which city has the best customers ?
select sum(total) as invoice_total,billing_city from invoice
group by billing_city
order by invoice_total desc;
-- who is the best customer ?
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total desc
limit 1;

-- moderate level
-- write query to return the email,first name,last name,genre of all rock music listeners.return your list ordered
-- aplhabetically by email starting with A ? 
select distinct email,first_name,last_name
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(select track_id from track1 join genre on track1.genre_id = genre.genre_id
				  where genre.name like 'Rock'
)
order by email;
--let's invite the artists who have written the most rock music in our dataset.
--write a query that returns the artist name and total track count of top 10 rock bands ?
select artist.artist_id,artist.name, count(artist.artist_id) as number_of_songs
from track1
join album on album.album_id = track1.album_id
join artist on artist.artist_id = album.album_id
join genre on genre.genre_id = track1.genre_id
where genre.name like 'Rock'
group by artist.artist_id,artist.name
order by number_of_songs desc
limit 10;
--return all the track names that have a song length longer than the average song length.
--return the name and milliseconds for each track, order by the song length with longest songs listed first ?
select name,milliseconds
from track1
where milliseconds > (select avg(milliseconds) as avg_track_length 
					 from track1)
order by milliseconds desc;
-- ADVANCED LEVELS
-- find  how much amount spend by aech customer on artists? 
-- write to return customer name, artist anme and total spent ?
with best_selling_artist as (
select artist.artist_id as artist_id,artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity)
as total_sales
from invoice_line
join track1 on track1.track_id = invoice_line.track_id
join album on album.album_id = track1.album_id
join artist on artist.artist_id = album.artist_id
group by 1,artist.name
order by 3 desc
	limit 1
)
select c.customer_id ,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track1 t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;
--write a query that determine the customer has spent the most on music for each country.
--write a query that return the country along with the top customer and how much they spent.
--for countries where the top amount spent is shared , provide all customers who spent this amount
with recursive
customer_with_country as (select customer.customer_id,first_name,last_name,billing_country,sum(total) as 
						 total_spending from invoice
						 join customer on customer.customer_id = invoice.customer_id
						 group by 1,2,3,4
						 order by 2,3 desc),
			country_max_spending as(
			select billing_country,max(total_spending) as max_spending
			from customer_with_country
			group by billing_country)
select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;




