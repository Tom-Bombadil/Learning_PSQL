-- \list <- lists all databases



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
-- oid, tableoid, xmin, cmin, xmax, cmax, ctid
-- Can't name other columns these names

-- OIDs are not necessarily unique within a table


-- ====================
-- 5.5 Modifying Tables
-- ====================
-- Designed to alter the definition, or structure, of the table


-- 5.5.1 Adding a Column
-- ---------------------
	ALTER TABLE products ADD COLUMN description text;
-- all options applied to a column in "CREATE TABLE" may be applied at this step
-- default values must satisfy given constraints
-- if no default is specified to the new column, a physical update is avoided. Therefore, if most new rows will be nondefault, best to not have a default.


-- 5.5.2 Removing a Column
-- -----------------------
	ALTER TABLE products DROP COLUMN description;
-- If the column is referenced elsewhere, the foreign key constraint will not get dropped unless "CASCADE" is added to the command


-- 5.5.3 Adding a Constraint
-- -------------------------
	ALTER TABLE products ADD CHECK (name <> '');

-- Add a not-null constraint
	ALTER TABLE products ALTER COLUMN product_no SET NOT NULL;
	
-- The constraint is checked immediately


-- 5.5.4 Removing a Constraint
-- ---------------------------
-- Must know the name of a constraint to remove it
-- Use the psql commend: "\d tablename" to inspect the table details and find the constraint name.
	ALTER TABLE products DROP CONSTRAINT some_name;
-- If a default name is given (e.g. $2) then double quotes must be used to make it valid
-- "CASCADE" added to drop a constraint that something else depends on

-- To drop a not-null constraint:
	ALTER TABLE products ALTER COLUMN product_no DROP NOT NULL;
	
	
-- 5.5.5 Changing a Column's Default Value
-- ---------------------------------------
-- To change future default values:	
	ALTER TABLE products ALTER COLUMN price SET DEFAULT 7.77;
-- Doesn't alter existing default

-- To remove any default (essentially changes deafult to NULL):
	ALTER TABLE products ALTER COLUMN price DROP DEFAULT;
	
	
-- 5.5.6 Changing a Column's Data Type
-- -----------------------------------
-- Convert data type:
	ALTER TABLE products ALTER COLUMN price TYPE numeric(10,2);
-- This only works if it can be converted using an implicit cast. Add "USING" for a more complex conversion
-- It is best to drop constraints before changing type and then add back suitably modified versions.


-- 5.5.7 Renaming a Column
-- -----------------------
ALTER TABLE products RENAME COLUMN product_no TO product_number;


-- 5.5.8 Renaming a Table
-- ----------------------
ALTER TABLE products RENAME TO items;



-- ===============
-- 5.6  Privileges
-- ===============
GRANT -- used to assign privileges to a user
PUBLIC -- as usernames, allows access to all users on the system
REVOKE -- removes privileges


-- ===========
-- 5.7 Schemas
-- ===========

-- One or more schema in a database
-- same object name used in different schemas without conflict
-- schemas are not rigidly separated like databases
-- analagous to directories at the operating system level, but cannot be nested

-- Qualified names: names including the database.schema.table path (e.g. NHDHRDV2_06.data.daymet)
-- Unqualified name: stand alone name (e.g. daymet)

-- 5.7.1. Creating a Schema
-- ------------------------

CREATE SCHEMA myschema;

-- Create or access objects in schema by separating with dot: schema.table ( e.g. data.daymet)

-- Create a new table in new schema:
CREATE TABLE myschema.mytable (
 ...
);

-- Drop empty schema:
DROP SCHEMA myschema;

-- Drop schema with objects:
DROP SCHEMA myschema CASCADE;

-- Create schema for someone else
CREATE SCHEMA schemaname AUTHORIZATION username;


-- 5.7.2. The Public Schema
-- ------------------------

-- Not specifying a schema puts the table into the public schema. The statements below are equivalent:
CREATE TABLE products ( ... );
CREATE TABLE public.products ( ... );


-- 5.7.3. The Schema Search Path
-- -----------------------------

-- Check current search path for tables:
SHOW search_path;
-- Lists schemas to be searched
 search_path
--------------
 "$user",public
 

-- To set search path (list schemas after "TO"):
SET search_path TO myschema,public;
SET search_path TO data,public;

-- Now we don't have to specify "data.daymet", instead just "daymet" will work.


-- If you need to write a qualified operator name in an expression, there is a special provision: you must write
OPERATOR(schema.operator)


-- 5.7.4. Schemas and Privileges
-- -----------------------------
-- Owner must grant privilege to users

-- All users have privileges on the public schema. To revoke these privileges:
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- (The first "public" is the schema, the second "public" means "every user". 
			-- In the first sense it is an identifier, in the second sense it is a key word, hence the different capitalization; 
			-- recall the guidelines from Section 4.1.1.)

-- 5.7.5. The System Catalog Schema
-- --------------------------------
pg_catalog -- This schema contains the system tables and all the built-in data types, functions, and operators

-- If possible, avoid table names beginning with "pg_"


-- 5.7.6. Usage Patters
-- --------------------
-- No schemas
-- 1 schema per user
-- Different schemas for shared applications (tables, functions, etc.)


-- 5.7.7. Portability
-- ------------------









