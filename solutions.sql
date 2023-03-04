-- 1. Provide a query showing Customers (just their full names, customer ID and country) who are not in the US.
SELECT
  CONCAT(first_name, ' ', last_name)
, customer_id
, country
FROM customer
WHERE country != 'US';

-- 2. Provide a query only showing the Customers from Brazil.
SELECT *
FROM customer
WHERE country = 'Brazil';

-- 3. Provide a query showing the Invoices of customers who are from Brazil.
-- The resultant table should show the customer's full name, Invoice ID, Date of the invoice and billing country.
SELECT
  CONCAT(customer.first_name, ' ', customer.last_name)
, invoice.invoice_id
, invoice.invoice_date
, invoice.billing_country
FROM invoice
JOIN customer USING (customer_id);

-- 4. Provide a query showing only the Employees who are Sales Agents.
SELECT *
FROM employee
WHERE title ILIKE 'Sales % Agent';

-- 5. Provide a query showing a unique list of billing countries from the Invoice table.
SELECT DISTINCT
  billing_country
FROM invoice;

-- 6. Provide a query that shows the invoices associated with each sales agent.
-- The resultant table should include the Sales Agent's full name.
SELECT
  CONCAT(employee.first_name, ' ', employee.last_name)
, employee.title
, invoice.*
FROM invoice
JOIN customer USING (customer_id)
JOIN employee ON customer.support_rep_id = employee.employee_id
WHERE employee.title ILIKE 'Sales % Agent';

-- 7. Provide a query that shows the Invoice Total, Customer name, Country and Sale Agent name for all invoices and customers.
SELECT
  invoice.total
, CONCAT(customer.first_name, ' ', customer.last_name)
, invoice.billing_country
, CONCAT(employee.first_name, ' ', employee.last_name)
FROM invoice
JOIN customer USING (customer_id)
JOIN employee ON customer.support_rep_id = employee.employee_id;

-- 8. How many Invoices were there in 2009 and 2011? What are the respective total sales for each of those years?
SELECT
  EXTRACT(YEAR FROM invoice_date)
, SUM(total)
FROM invoice
WHERE EXTRACT(YEAR FROM invoice_date) BETWEEN 2009 AND 2011
GROUP BY 1;

-- 9. Looking at the InvoiceLine table, provide a query that COUNTs the number of line items for Invoice ID 37.
SELECT
  COUNT(*)
FROM invoice
JOIN invoice_line USING (invoice_id)
WHERE invoice_id = 37;

-- 10. Looking at the InvoiceLine table, provide a query that COUNTs the number of line items for each Invoice.
SELECT
  invoice_id
, COUNT(*)
FROM invoice
JOIN invoice_line USING (invoice_id)
GROUP BY invoice_id;

-- 11. Provide a query that includes the track name with each invoice line item.
SELECT
  track.name
, invoice_line.*
FROM invoice_line
JOIN track USING (track_id);

-- 12. Provide a query that includes the purchased track name AND artist name with each invoice line item.
SELECT
  track.name
, artist.name
, invoice_line.*
FROM invoice_line
JOIN track USING (track_id)
JOIN album USING (album_id)
JOIN artist USING (artist_id);

-- 13. Provide a query that shows the # of invoices per country.
SELECT
  billing_country
, COUNT(*)
FROM invoice
GROUP BY billing_country;

-- 14. Provide a query that shows the total number of tracks in each playlist.
-- The Playlist name should be included on the resultant table.
SELECT
  name
, COUNT(*)
FROM playlist
JOIN playlist_track USING (playlist_id)
GROUP BY playlist_id
ORDER BY 2;

-- 15. Provide a query that shows all the Tracks, but displays no IDs.
-- The resultant table should include the Album name, Media type and Genre.
SELECT
  track.name
, album.title
, media_type.name
, genre.name
FROM track
JOIN album USING (album_id)
JOIN media_type USING (media_type_id)
JOIN genre USING (genre_id);

-- 16. Provide a query that shows all Invoices but includes the # of invoice line items.
SELECT *
FROM invoice,
     LATERAL (
       SELECT
         COUNT(*) line_count
       FROM invoice_line
       WHERE invoice.invoice_id = invoice_line.invoice_id
       ) invoice_line_count;

-- 17. Provide a query that shows total sales made by each sales agent.
SELECT
  employee_id
, SUM(total)
FROM employee
JOIN customer ON employee.employee_id = customer.support_rep_id
JOIN invoice USING (customer_id)
WHERE employee.title ILIKE 'Sales % Agent'
GROUP BY employee_id;

-- 18. Which sales agent made the most in sales in 2009?
SELECT
  employee_id
, SUM(total) sales_sum
FROM employee
JOIN customer ON employee.employee_id = customer.support_rep_id
JOIN invoice USING (customer_id)
WHERE employee.title ILIKE 'Sales % Agent'
  AND EXTRACT(YEAR FROM invoice.invoice_date) = 2009
GROUP BY employee_id
ORDER BY 2 DESC
LIMIT 1;

-- 19. Which sales agent made the most in sales in 2010?
SELECT
  employee_id
, SUM(total) sales_sum
FROM employee
JOIN customer ON employee.employee_id = customer.support_rep_id
JOIN invoice USING (customer_id)
WHERE employee.title ILIKE 'Sales % Agent'
  AND EXTRACT(YEAR FROM invoice.invoice_date) = 2010
GROUP BY employee_id
ORDER BY 2 DESC
LIMIT 1;

-- 20. Which sales agent made the most in sales over all?
SELECT
  employee_id
, SUM(total) sales_sum
FROM employee
JOIN customer ON employee.employee_id = customer.support_rep_id
JOIN invoice USING (customer_id)
WHERE employee.title ILIKE 'Sales % Agent'
GROUP BY employee_id
ORDER BY 2 DESC
LIMIT 1;

-- 21. Provide a query that shows the # of customers assigned to each sales agent.
SELECT
  customer.support_rep_id
, COUNT(*)
FROM employee
JOIN customer ON employee.employee_id = customer.support_rep_id
GROUP BY customer.support_rep_id;

-- 22. Provide a query that shows the total sales per country. Which country's customers spent the most?
WITH
  data AS (
    SELECT
      billing_country
    , customer_id
    , SUM(total) AS sum
    , RANK() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rank
    FROM invoice
    GROUP BY billing_country, customer_id
  )
SELECT
  billing_country
, customer_id
, sum
FROM data
WHERE rank = 1
ORDER BY sum DESC;

-- 23. Provide a query that shows the most purchased track of 2013.
SELECT
  track_id
, SUM(quantity)
FROM invoice_line
JOIN invoice USING (invoice_id)
WHERE EXTRACT(YEAR FROM invoice_date) = 2013
GROUP BY track_id
ORDER BY 2 DESC
LIMIT 1;

-- 24. Provide a query that shows the top 5 most purchased tracks over all.
SELECT
  track_id
, SUM(quantity)
FROM invoice_line
GROUP BY track_id
ORDER BY 2 DESC
LIMIT 5;

-- 25. Provide a query that shows the top 3 best selling artists.
SELECT
  artist_id
, SUM(quantity) AS sells
FROM invoice_line
JOIN track USING (track_id)
JOIN album USING (album_id)
GROUP BY artist_id
ORDER BY 2 DESC
LIMIT 3;

-- 26. Provide a query that shows the most purchased Media Type.
SELECT
  media_type
, SUM(quantity)
FROM invoice_line
JOIN track USING (track_id)
JOIN media_type USING (media_type_id)
GROUP BY media_type
ORDER BY 2 DESC
LIMIT 1;

-- 27. Provide a query that shows the number tracks purchased in all invoices that contain more than one genre.
WITH
  invoice_with_genre_count AS (
    SELECT
      invoice_id
    , CARDINALITY(ARRAY_AGG(DISTINCT genre_id)) AS genre_count
    FROM invoice_line
    JOIN track USING (track_id)
    GROUP BY invoice_id
  )
SELECT
  COUNT(*)
FROM invoice_with_genre_count
WHERE genre_count > 1;
