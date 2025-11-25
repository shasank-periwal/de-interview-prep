Question 1
--Create a data model for a chain of cinemas.
--In your data model please include the theaters in the cinemas, the seats in those theaters, customers, and tickets sold for show times.
--Answer can be in pseudo code but should include the PK and FK entities

TableName
    Column1
    Column2 PK


Cinema
    Cinema_ID    - CK
    Cinema_Name  - CK
    Theatre_ID
    
Theatre
    Theatre_id - CK
    seat_id -    CK -- E, P, B
    seat_price
    name
    no_of_economy_seats 
    no_of_premium_seats
    no_of_busiess_seats
    no_rows
    
Ticket
    ticket_id   - pk
    no_of_seats(int)
    seat_id
    price

Customer
    customer_id - pk
    name
    ticket_id
    date
    
Question 2
--Write a query to count the total number of tickets sold at each theater.

tickets_df.alias('a').join(theatre_df.alias('b'), on=(col(a.seat_id) == (b.seat_id)))) \
    .select(b.theatre_id, a.seat_id).agg(col(b.theatre_id)).count(col(a.seat_id)).alias('number_of_tickets').select(col(theatre_id), col(number_of_tickets))).show()
    


Question 3
--Using a window function please find the theater with the second highest count of ticket sold.
ticket_count_df = tickets_df.alias('a').join(theatre_df.alias('b'), on=(col(a.seat_id) == (b.seat_id)))) \
    .select(b.theatre_id, a.seat_id).agg(col(b.theatre_id)).count(col(a.seat_id)).alias('number_of_tickets').select(col(theatre_id), col(number_of_tickets))).show()

df = ticket_count_df.withColumn('rnk',row_number.over(Window.order_by(col(number_of_tickets).desc(), theatre_id)).filter(col(rnk)==2)
