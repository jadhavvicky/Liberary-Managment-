-- Liberary Managment System Project 1
-- Crating branch table

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "Return Status"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

SELECT * From books;
SELECT * From branch;
SELECT * From employees;
SELECT * From issued_status;
SELECT * From members;
SELECT * From return_status;

-- Project Task
--Q1 Create a New Book Record  --"978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')


-- Task 2: Update an Existing Member's Address
UPDATE members
SET  member_address = '125 MAIN st'
WHERE member_id = 'C101'

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS107' from the issue

DELETE FROM issued_status
WHERE issued_id = 'IS107'


--Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * From issued_status
WHERE issued_emp_id = 'E101'

-- Task 5 :LIST The member who has issued more than one book -- objective use Group by to find the member

SELECT
	issued_emp_id,
	COUNT(issued_id) as total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*)>1

--TASK 6 : Create summary tables: Use CTAS to genrate new tables based on query result - each book and total book_isuued_cnt**
CREATE TABLE book_cnts
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;


SELECT * FROM
book_cnts;


-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'


-- Task 8: Find Total Rental Income by Category:
SELECT
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9. List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >=CURRENT_DATE - INTERVAL '180 Days'

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUEs
('C120','SAM','45A Van reypen','2025-02-02'),
('C121','JHON','49 Van Reypen', '2025-04-02');

-- Q 10 List the employee with their Branch manager's Name and their branch details:

SELECT
    e1.*, 
    b.manager_id,
    e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
    ON b.branch_id = e1.branch_id
JOIN employees AS e2
    ON b.manager_id = e2.emp_id;

--Q11 Create a table of book with rental price above a certain Threshold 7USD:
CREATE TABLE books_price_greater_then_seven
AS
SELECT * FROM Books
WHERE rental_price > 7

SELECT * FROM
books_price_greater_then_seven

--Q12 Retrive the list of the book not yet returned
SELECT
	DISTINCT ist.issued_book_name
FROM issued_status as ist

LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's_id, member's name, book title, issue date, and days overdue.

--issued_status == members == books == return_status
--filter books which is return
-- Overdue > 30

SELECT CURRENT_DATE


SELECT
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	--rs.return_date,
	 CURRENT_DATE -ist.issued_date as Over_Due
FROM issued_status as ist
JOIN
members as m
	ON m.member_id = ist.issued_member_id
JOIN
books as bk
	ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE rs.return_date is NULL

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to 
"Yes" when they are returned (based on entries in the return_status table)
*/

SELECT * FROM issued_status
WHERe issued_book_isbn = '978-0-451-52994-2';


SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

--
INSERT INTO return_status(return_id, issued_id, return_date)
VALUES
('RS125', 'IS130', CURRENT_DATE);
SELECT * FROM return_status
WHERE issued_id = 'IS130';


SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';
UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';

--Return Store Procedures

CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id VARCHAR(10), 
    p_issued_id VARCHAR(10), 
    p_book_quality VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    -- Get ISBN and Book Name based on issued ID
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Insert into return_status table
    INSERT INTO return_status(
        return_id, 
        issued_id, 
        return_book_name, 
        return_date, 
        return_book_isbn
        --, book_quality -- Uncomment if added
    )
    VALUES (
        p_return_id, 
        p_issued_id, 
        v_book_name, 
        CURRENT_DATE, 
        v_isbn
        --, p_book_quality
    );

    -- Update books table to mark as returned
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Confirmation message
    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS1189', 'IS120', 'Good');

SELECT * FROM return_status;

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.*/
SELECT * FROM branch;

SELECT * FROM issued_status;

SELECT * FROM employees;

SELECT * FROM books ;

SELECT * FROM return_status;

CREATE TABLE branch_reports
	AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id)as number_books_issued,
	COUNT(rs.return_id) as number_books_return,
	SUM(bk.rental_price)as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN 
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN
books as bk
ON ist. issued_book_isbn = bk.isbn
GROUP BY 1,2;


SELECT * FROM branch_reports


/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table 
active_members containing members who have
issued at least one book in the last  14 months*/
CREATE TABLE active_member
AS
SELECT * FROM members
Where member_id In( SELECT
						DISTINCT issued_member_id 
					FROM issued_status
					WHERE 
						issued_date >= CURRENT_DATE - INTERVAL  '14 month'
					)
SELECT * FROM active_member;


/*Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

SELECT 
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP By 1, 2



/*Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of 
books in a library system. Description: Write a stored procedure that updates the status 
of a book in the library based on its issuance. The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. The procedure should 
first check if the book is available (status = 'yes'). If the book is available, it should 
be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating 
that the book is currently not available.*/

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(50), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
		V_status VARCHAR(10);


BEGIN
--CHECK IF BOOK IS AVAILABLE
	SELECT
		status 
		INTO 
		V_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF 
	V_status = 'YES'
	THEN INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES
		(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
		UPDATE books
			SET status = 'no'
			WHERE isbn = issued_book_isbn;
		
		RAISE NOTICE 'BOOK RECORD ADDED SUCCESFULLY FOR BOOK ISBN : %', p_issued_book_isbn;
ELSE
		RAISE NOTICE 'SORRY, BUT BOOK IS NOT AVAILABLE AT PERTICULAR MOMENT book_isbn: %', p_issued_book_isbn;

		
END IF;
END;
$$


SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;


CALL issue_book('IS155', 'C108', '978-0-525-47535-5', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');



-- END OF THIS PROJECT--
