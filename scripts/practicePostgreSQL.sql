CREATE TABLE flowlines03 
(OBJECTID int, SOURCE char(20), FEATUREID int, 
NextDownID int, Shape_Length real, LengthKM real);

\copy flowlines03 FROM '/home/kyle/practice/Flowlines03.csv' DELIMITER ',' CSV HEADER;



CREATE TABLE catchments03 
(OBJECTID int, Source char(20), FEATUREID int, 
NextDownID int, Shape_Length real, Shape_Area real, LengthKM real);

\copy catchments03 FROM '/home/kyle/practice/Catchments03.csv' DELIMITER ',' CSV HEADER;


SELECT * FROM flowlines03 WHERE source = 'Coastal';





SELECT * INTO flow_coast FROM flowlines03 WHERE source = 'Coastal'; -- "flow_coast" is a smaller, sample table


SELECT * INTO flow_long FROM flowlines03 WHERE lengthkm >= 4; -- "flow_coast" is a smaller, sample table



SELECT array_agg(featureid ORDER BY lengthkm DESC) FROM flow_coast;

SELECT string_agg(featureid, ',' ORDER BY lengthkm) FROM flow_coast;

SELECT AVG ( * ) OVER source FROM flow_long;


-- Subscripts

SELECT * FROM flow_long WHERE featureid[1];


-- Window Functions
---- Window function calls are permitted only in the SELECT list and the ORDER BY clause of the query


-- Averages the flowline length over the source typeq
SELECT lengthkm, AVG (lengthkm) OVER (PARTITION BY source) FROM flow_long;

SELECT featureid, array_agg(featureid) OVER (ORDER BY lengthkm) FROM flow_long;

SELECT featureid, array_agg(featureid) OVER (BETWEEN 1 AND 10) FROM flow_long;

SELECT featureid, MAX(lengthkm) OVER (PARTITION BY source ORDER BY lengthkm) FROM flow_long;

SELECT featureid, count(*) OVER (PARTITION BY source ORDER BY lengthkm) FROM flow_long;


-- Type Casts
-- ==========
----- A type cast specifies a conversion from one data type to another 
----- Fairly simple idea of editing types... similar to "as" in R (e.g. as.numeric)
----- The system will automatically aply type casts to pre-defined columns

SELECT CAST (100 AS integer);


-- Collation Expressions
-- =====================
------- overrides the collation of an expression
------- I think collate affects the where clause. This first statement works:
SELECT * FROM flow_long WHERE source = 'Delineation' COLLATE "C";

-- While this one throws an error: "collations are not supported by type integer"
SELECT source FROM flow_long WHERE lengthkm > 3 COLLATE "C";


-- Scalar Subqueries
-- =================
--------- A scalar subquery is an ordinary SELECT query in parentheses that returns exactly one row with one column
SELECT featureid, (SELECT max(lengthkm) FROM lines WHERE source = 'Coastal')
    FROM lines;


-- An example using a scalar subquery to get the max length of a flowline in coastal area
SELECT * FROM lines 
	WHERE (lengthkm = (SELECT max(lengthkm) FROM lines WHERE source = 'Coastal'));

SELECT * FROM cats 
	WHERE (areasqkm = (SELECT max(areasqkm) FROM cats WHERE source = 'Coastal'));	




-- Array Constructors
-- ==================

-- basic setup
SELECT ARRAY[1,2,3+4];

-- override element type
SELECT ARRAY[1,2,22.7]::integer[];

-- Omit "ARRAY" in inner constructors:
SELECT ARRAY[ARRAY[1,2], ARRAY[3,4]];
-- equal to:
SELECT ARRAY[[1,2],[3,4]];

	

-- 4.2.13. Row Constructors
-- ========================

SELECT ROW(1,2.5,'this is a test');	
	

	
-- Row constructor can include the syntax rowvalue.*, which will be expanded to a list of the elements of the row value. 
-- This is similar to top level of select.

-- selects all rows and adds a column of all "5" to it
SELECT ROW(lines.*, 5) FROM lines;


SELECT ROW(lines.source, lines.featureid, 42) FROM lines;	
	
	
	
	
	
CREATE TABLE mytable(f1 int, f2 float, f3 text);

CREATE FUNCTION getf1(mytable) RETURNS int AS 'SELECT $1.f1' LANGUAGE SQL;

-- No cast needed since only one getf1() exists
SELECT getf1(ROW(1,2.5,'this is a test'));	
	
	
	
	
	
	
	
	
-- By default, the value created by a ROW expression is of an anonymous record type. If necessary, it can be cast to a named composite type 

-- As far as I can understand, you can create multiple functions of the same name. If this happens and the types within them are different,
--		then you must specify the type by using CAST.



CREATE FUNCTION getfid(lines) RETURNS int AS 'SELECT $1.featureid' LANGUAGE SQL;	
	
SELECT getfid((lines));
	
SELECT getfid(lines);

	
	
	
CREATE FUNCTION getf2(mytable) RETURNS float AS 'SELECT $1.f1' LANGUAGE SQL;	
	
	
	
	
-- 4.2.14 Expression Evaluation Rules

--	There is no guaranteed order of operation (i.e. not necessarily left to right).

-- Untrustworthy way of avoiding division by 0:
SELECT ... WHERE x > 0 AND y/x > 1.5;
-- But this is safe:
SELECT ... WHERE CASE WHEN x > 0 THEN y/x > 1.5 ELSE false END;	
	
-- The CASE step can be limited by attempts to perform early constant evaluation:
SELECT CASE WHEN x > 0 THEN x ELSE 1/0 END FROM tab;
	
-- Aggregate expressions still get evaluated first. This does not protect against division by zero.
SELECT CASE WHEN min(employees) > 0
            THEN avg(expenses / employees)
       END
    FROM departments;

-- Instead, a WHERE clause should be used to 
	


	
-- ======================
-- 4.3. Calling Functions
-- ======================	
	
	

	
	
	
	
-- ===================================================================================================================================
-- 														Chapter 5. Data Definition
-- ===================================================================================================================================

-- ================	
-- 5.1 Table Basics
-- ================
	
-- No guarantees about order of rows in a table
-- No IDs assigned to rows. Possibility of several identical rows
-- It is customary to drop a table name before creating it


CREATE TABLE products (
    product_no integer,
    name text,
    price numeric
);


DROP TABLE products;

-- ==================
-- 5.2 Default Values
-- ==================

-- Default values are listed after the 	column data type

CREATE TABLE products (
    price numeric DEFAULT 9.99
);

-- "SERIAL" is the shorthand used to sequence rows


-- ===============
-- 5.3 Constraints
-- ===============

-- Error thrown if the column/table does not meet constraint

-- 5.3.1 Check Constraints
-- -----------------------
-- Can specify a value that satisfies a Boolean expression
	price numeric CHECK (price > 0)

-- Naming a constraint
	price numeric CONSTRAINT positive_price CHECK (price > 0)



-- Table constraint is set separately from the column created (order is irrelevant)
	price numeric CHECK (price > 0),						-- column constraint
    discounted_price numeric CHECK (discounted_price > 0),  -- column constraint
    CHECK (price > discounted_price)                        -- table constraint

	-- column constraints may be written as table constraints, e.g.
		discounted_price numeric,
		CHECK (discounted_price > 0)
	
-- Name a table constraint
	CONSTRAINT valid_discount CHECK (price > discounted_price)

-- Note: check constraint is satisfied if it comes up as null, which is the case if any operand is null


-- 5.3.2 Not-Null Constraints
-- --------------------------	
-- Specifies null values are not allowed
	CREATE TABLE products (
    product_no integer NOT NULL,
    name text NOT NULL,
    price numeric
	);
	
-- Multiple constraints get written one after another
	price numeric NOT NULL CHECK (price > 0)
	
-- Inverse is NULL and sets the default of the column (not a constraint)
	price numeric NULL,


-- 5.3.3 Unique Constraints
-- ------------------------
-- Unique constraint in a column ensures unique values with respect to all rows in the table
	product_no integer UNIQUE, -- column constraint
	
	product_no integer, 
	UNIQUE (product_no), -- table constraint
	
-- Multiple columns listed with commas indicates that the combination of elements across a row is unique (doesn't mean that the values in each column individually are unique)
	UNIQUE (a,b,c),
	
-- Assign a name to the unique constraint
	product_no integer CONSTRAINT must_be_different UNIQUE, -- "must_be_different" is the named constraint
	
-- Duplicate NULL values are allowed by the "UNIQUE" constraint


-- 5.3.4. Primary Keys
-- -------------------
-- Primary keys are just a combination of a unique and a not-null constraint:
	
	product_no integer UNIQUE NOT NULL,
	-- is equal to:
	product_no integer PRIMARY KEY,
	
-- Basically indicates that a column or group of columns can be used as a unique ID for rows in the table. Just gets around the fact that UNIQUE doesn't work for NULL values
-- Only 1 Primary Key per table. Each table should have a Primary Key
	
-- 5.3.5. Foreign Keys
-- -------------------
-- Values in a column must match values appearing in some row of another table (maintains referential integrity).

	-- referenced table:
	CREATE TABLE products (
		product_no integer PRIMARY KEY,
		name text,
		price numeric
	);
	
	-- referencing table:
	CREATE TABLE orders (
		order_id integer PRIMARY KEY,
		product_no integer REFERENCES products (product_no),
		quantity integer
	);
	-- impossible to create orders with non-NULL product_no entries that do not appear in the products table
	-- in absence of a column list the primary key of the referenced table is used as the referenced column(s)

	-- Reference a group of columns:
	FOREIGN KEY (b, c) REFERENCES other_table (c1, c2)
	-- number/type of constrained columns must match number/type of referenced columns
	
-- multiple foregin keys are allow
	
-- Actions taken on deleting referenced rows ("ON DELETE"):
	-- RESTRICT prevents deletion of a referenced row
	-- CASCADE specifies that when a referenced row is deleted, row(s) referencing it should be automatically deleted as well
	-- NO ACTION - if referenced row still exists when constraint is checked, an error is raised
	-- Other options: SET NULL and SET DEFAULT (self-explanatory, do not excuse from observing constraints)
	
-- Can also apply to "ON UPDATE"

-- 
-- "MATCH FULL" means a referencing row escapes satisfying the constraint only if all its referencing columns are null. Means all rows have to match.
	-- Declare referencing columns as NOT NULL to make them unable to avoid satisfying foreign key constraint

-- Referenced columns always have an index. Referencing columns should have an index


-- 5.3.6. Exclusion Constraints
-- ----------------------------
-- I don't understand this section.

-- && = overlap - test if they have column elements



-- ==================
-- 5.4 System Columns
-- ==================

	

	