-- Week1Practice setup: run once in SSMS (creates the database, schema and sample sales data)

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  name TEXT,
  city TEXT,
  signup_date DATE
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER,
  order_date DATE,
  amount DECIMAL(10,2),
  status TEXT
);

INSERT INTO customers VALUES
  (1, 'Adaeze Okafor', 'Winnipeg', '2024-01-15'),
  (2, 'Brian Chen', 'Vancouver', '2024-02-20'),
  (3, 'Chidi Eze', 'Toronto', '2024-03-10'),
  (4, 'Diana Ross', 'Calgary', '2024-01-05'),
  (5, 'Emeka Nwosu', 'Winnipeg', '2024-04-01');

INSERT INTO orders VALUES
  (101, 1, '2024-05-01', 120.00, 'completed'),
  (102, 1, '2024-05-15', 80.00, 'completed'),
  (103, 1, '2024-06-02', 200.00, 'completed'),
  (104, 2, '2024-05-03', 150.00, 'completed'),
  (105, 2, '2024-06-10', 150.00, 'cancelled'),
  (106, 2, '2024-07-01', 300.00, 'completed'),
  (107, 3, '2024-05-20', 50.00, 'completed'),
  (108, 3, '2024-06-20', 60.00, 'completed'),
  (109, 3, '2024-07-20', 300.00, 'completed'),
  (110, 4, '2024-05-11', 500.00, 'completed'),
  (111, 4, '2024-06-11', 50.00, 'refunded'),
  (112, 5, '2024-07-05', 75.00, 'completed');
GO

