 USE ROLE ACCOUNTADMIN;


---In Snowflake, a storage integration is a secure configuration that lets Snowflake access cloud storage (like Azure Blob Storage) without storing credentials in your SQL.

CREATE STORAGE INTEGRATION azure_titanic_integration  
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE  -- Activates the integration
  AZURE_TENANT_ID = '06d85260-9d73-4a2e-b881-8715c7edc475'
  STORAGE_ALLOWED_LOCATIONS = (
    'azure://snowflakedataset.blob.core.windows.net/titanicdataset/'
  );


  DESC INTEGRATION azure_titanic_integration;

  CREATE DATABASE titanic_db;
  USE DATABASE titanic_db;
  USE SCHEMA public;

CREATE OR REPLACE STAGE titanic_stage  -- create a stage i.e. Pointer to file location
  URL = 'azure://snowflakedataset.blob.core.windows.net/titanicdataset/'
  STORAGE_INTEGRATION = azure_titanic_integration;


  LIST @titanic_stage;


drop table original_titanic_dataset
drop table cleaned_titanic_dataset

  -- Table 1 — Main Titanic dataset
CREATE OR REPLACE TABLE original_titanic_dataset (
    PassengerId   INT,
    Survived      INT,
    Pclass        INT,
    Name          VARCHAR,
    Sex           VARCHAR,
    Age           FLOAT,
    SibSp         INT,
    Parch         INT,
    Ticket        VARCHAR,
    Fare          FLOAT,
    Cabin         VARCHAR,
    Embarked      VARCHAR
);

-- Table 2
CREATE OR REPLACE TABLE cleaned_titanic_dataset (
    PassengerId   INT,
    Survived  INT,
    Pclass        INT,
    Name          VARCHAR,
    Sex           VARCHAR,
    Age           FLOAT,
    SibSp         INT,
    Parch         INT,
    Ticket        VARCHAR,
    Fare          FLOAT,
    Cabin         VARCHAR,
    Embarked      VARCHAR,
    AgeGroup      VARCHAR,
    HasCabin      VARCHAR,
    Deck          VARCHAR,              
    RawName       VARCHAR,
    FamilySize    VARCHAR,
    FamilyType    VARCHAR,
    FareCategory  VARCHAR,
    Alone         VARCHAR
);


-- 6. STAGING TABLES (IMPORTANT FOR MERGE)

CREATE OR REPLACE TABLE stg_original_titanic AS
SELECT * FROM original_titanic_dataset WHERE 1=0;  ---1=0 is always false so no data are copied only the tables structure is copied

CREATE OR REPLACE TABLE stg_cleaned_titanic AS
SELECT * FROM cleaned_titanic_dataset WHERE 1=0;


-- Load file 1
COPY INTO stg_original_titanic
FROM @titanic_stage/titanic_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' -- Handles values like: "John Doe","New York"
    SKIP_HEADER = 1                --Ignores the first row (column names)
    NULL_IF = ('', 'NA', 'null')   -- handles missing values in Titanic data i.e. convert  empty, na into null
);

-- Load file 2
COPY INTO stg_cleaned_titanic
FROM @titanic_stage/titanic_cleaned.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('', 'NA', 'null')
);



-- MERGE INTO FINAL TABLES (DEDUP SAFE)

-- RAW TABLE MERGE
MERGE INTO original_titanic_dataset t
USING stg_original_titanic s
ON t.PassengerId = s.PassengerId

WHEN MATCHED THEN UPDATE SET
    t.Survived = s.Survived,
    t.Pclass = s.Pclass,
    t.Name = s.Name,
    t.Sex = s.Sex,
    t.Age = s.Age,
    t.SibSp = s.SibSp,
    t.Parch = s.Parch,
    t.Ticket = s.Ticket,
    t.Fare = s.Fare,
    t.Cabin = s.Cabin,
    t.Embarked = s.Embarked

WHEN NOT MATCHED THEN
    INSERT (PassengerId, Survived, Pclass, Name, Sex, Age, SibSp, Parch, Ticket, Fare, Cabin, Embarked)
    VALUES (s.PassengerId, s.Survived, s.Pclass, s.Name, s.Sex, s.Age, s.SibSp, s.Parch, s.Ticket, s.Fare, s.Cabin, s.Embarked);


-- CLEANED TABLE MERGE
MERGE INTO cleaned_titanic_dataset t
USING stg_cleaned_titanic s
ON t.PassengerId = s.PassengerId

WHEN MATCHED THEN UPDATE SET
    t.Survived = s.Survived,
    t.Pclass = s.Pclass,
    t.Name = s.Name,
    t.Sex = s.Sex,
    t.Age = s.Age,
    t.SibSp = s.SibSp,
    t.Parch = s.Parch,
    t.Ticket = s.Ticket,
    t.Fare = s.Fare,
    t.Cabin = s.Cabin,
    t.Embarked = s.Embarked,
    t.AgeGroup = s.AgeGroup,
    t.HasCabin = s.HasCabin,
    t.Deck = s.Deck,
    t.RawName = s.RawName,
    t.FamilySize = s.FamilySize,
    t.FamilyType = s.FamilyType,
    t.FareCategory = s.FareCategory,
    t.Alone = s.Alone

WHEN NOT MATCHED THEN
    INSERT (
        PassengerId, Survived, Pclass, Name, Sex, Age, SibSp, Parch, Ticket,
        Fare, Cabin, Embarked, AgeGroup, HasCabin, Deck, RawName,
        FamilySize, FamilyType, FareCategory, Alone
    )
    VALUES (
        s.PassengerId, s.Survived, s.Pclass, s.Name, s.Sex, s.Age, s.SibSp, s.Parch, s.Ticket,
        s.Fare, s.Cabin, s.Embarked, s.AgeGroup, s.HasCabin, s.Deck, s.RawName,
        s.FamilySize, s.FamilyType, s.FareCategory, s.Alone
    );


-- VALIDATION


SELECT COUNT(*) FROM original_titanic_dataset;   -- should be 418
SELECT COUNT(*) FROM cleaned_titanic_dataset;    -- should be 418


