use bank;
select * from bank;
select * from countries;
select * from states;
select * from cities;
select * from zip_codes;
select * from bank_branches;
select * from departments;
select * from branch_departments;
select * from facilities;
select * from branch_facilities;
select * from persons;
select * from job_titles;
select * from employees;
select * from customers;
select * from customer_facilities;
select * from account_types;
select * from accounts;
select * from customer_accounts;
select * from transaction_type;
select * from transactions; 
select * from audit;
select * from card_types;
select * from cards;

CALL FundTransfer(1,2,500);
CALL withdraw (4,300);
CALL deposit (4,500);
CALL card_swipe(3099383746,200);
CALL card_swipe(8746798541,200);
CALL credit_payment(8746798541,200);

SELECT * FROM ACCOUNTS 
WHERE ACCOUNT_ID = 1;
select ACCOUNT_ID, STATE, BALANCE from accounts
WHERE STATE = 'open'
and BALANCE < 6000
ORDER BY BALANCE;

CALL avg_balance_of_all_accounts(4);

SELECT DISTINCT c.Branch_Name AS Branch_Name
FROM accounts a 
INNER JOIN account_types b
ON a.Type_ID = b.Type_ID
inner JOIN bank_branches c
ON a.BRANCH_ID = c.Branch_ID
WHERE b.Type_ID = 3;


SELECT a.Cust_ID, COUNT(*) AS number_of_loans
from customer_accounts a
INNER JOIN accounts c
	ON a.Account_ID = c.Account_ID
WHERE c.Type_ID = 3
GROUP BY Cust_ID
HAVING count(*) > 1;

SELECT c.bank_name, b.branch_name, a.Branch_ID, count(*) AS NumberOfAccounts 
FROM ACCOUNTS a
inner JOIN bank_branches b
ON a.Branch_ID = b.Branch_ID
INNER JOIN bank c
ON b.Bank_ID = c.Bank_ID
GROUP BY Branch_ID;




CREATE VIEW TransactionsBetweenGivenDates AS
SELECT c.Cust_ID, p.First_Name AS 'Customer Name' ,  t.Transaction_ID, tt.transaction_Type_Name,t.ACCOUNT_ID , t.AMOUNT, t.Date_Time
FROM transactions t 
INNER JOIN transaction_type tt
ON t.Transaction_Type_ID = tt.Transaction_Type_ID
INNER JOIN customer_accounts c
ON t.account_ID = c.account_ID
INNER JOIN customers cu
ON c.Cust_ID = cu.Cust_ID
INNER JOIN persons p
ON cu.Person_ID = p.Person_ID
ORDER BY Cust_ID;

-- DROP VIEW TransactionsBetweenGivenDates;

SELECT * FROM TransactionsBetweenGivenDates
WHERE DATE_TIME between '2016-12-9 00:00:00' AND '2016-12-12 00:00:00';


CREATE VIEW TopBanks AS
SELECT c.bank_name, b.branch_name, a.Branch_ID, count(*) AS NumberOfAccounts 
FROM ACCOUNTS a
inner JOIN bank_branches b
ON a.Branch_ID = b.Branch_ID
INNER JOIN bank c
ON b.Bank_ID = c.Bank_ID
GROUP BY Branch_ID;

SELECT bank_name, SUM(NumberOfAccounts) AS NumberOfAccounts 
FROM TopBanks
GROUP BY bank_name
ORDER BY NumberOfAccounts DESC;

-- SELECT EMPLOYEE_ID, Department_ID
-- FROM Employees
-- WHERE DEPARTMENT_ID = (SELECT DEPARTMENT_ID from departments WHERE DEPARTMENT_NAME = 'Cash Management');

SELECT p.First_Name AS 'Employee Name', e.employee_ID,    d.department_name
FROM employees e
INNER JOIN departments d
ON e.department_ID = d.department_ID
INNER JOIN persons p
ON e.Person_ID = p.Person_ID
ORDER BY employee_ID;

SELECT COUNT(ACCOUNT_ID) FROM accounts
WHERE BALANCE >= (SELECT avg(Balance) FROM accounts);


SELECT MAX(Total_Balance) AS Larget_Total
FROM (SELECT Branch_ID, SUM(BALANCE) AS Total_Balance 
FROM accounts  
GROUP BY Branch_ID)
 AS totals ;

UPDATE accounts
SET BALANCE = BALANCE*1.02
WHERE balance <= 3000
AND state = 'open'
AND ACCOUNT_ID > 0;


SELECT COUNT(ACCOUNT_ID) - COUNT(DISTINCT(ACCOUNT_ID))
FROM customer_accounts;

SELECT COUNT(DISTINCT(MANAGER_ID))
from employees;


DELIMITER |
CREATE trigger tr_insert_transaction
AFTER UPDATE ON accounts
FOR EACH row
BEGIN
	DECLARE TYPE_ID INT;
	DECLARE AMOUNT INT;
	IF OLD.BALANCE > NEW.BALANCE THEN
		SET TYPE_ID = 2;
		SET AMOUNT = OLD.BALANCE - NEW.BALANCE;
	ELSE 
		SET TYPE_ID = 1;
		SET AMOUNT = NEW.BALANCE - OLD.BALANCE;
	END IF;
	INSERT INTO transactions
	(
	 DATE_TIME,
	 Transaction_Type_ID,
	 Account_ID,
	 AMOUNT,
	 OLD_BALANCE,
	 NEW_BALANCE)

	VALUES (
			CURRENT_TIMESTAMP(), 
			TYPE_ID, 
			OLD.Account_ID,
			AMOUNT,
			OLD.Balance,
			NEW.Balance);
END;
|


-- DROP trigger tr_insert_transaction;

DELIMITER |
CREATE trigger tr_insert_audit
AFTER UPDATE ON persons
FOR EACH row
BEGIN
	
	INSERT INTO audit
	(
	 PERSON_ID,
	 DATE_TIME,
	 OLD_FIRST_NAME,
     NEW_FIRST_NAME,
     OLD_LAST_NAME,
	 NEW_LAST_NAME,	
	 OLD_EMAIL,
     NEW_EMAIL,
     OLD_CONTACT_NUMBER,
     NEW_CONTACT_NUMBER,
     OLD_ZIPCODE_ID,
	 NEW_ZIPCODE_ID
	 )

	VALUES (
			OLD.PERSON_ID, 
			CURRENT_TIMESTAMP(), 
			OLD.FIRST_NAME,
            NEW.FIRST_NAME,
			OLD.LAST_NAME,
			NEW.LAST_NAME,
            OLD.EMAIL,
			NEW.EMAIL,
            OLD.CONTACT_NUMBER,
            NEW.CONTACT_NUMBER,
            OLD.ZIPCODE_ID,
            NEW.ZIPCODE_ID);
END;
|


