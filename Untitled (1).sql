  USE ROLE ACCOUNTADMIN;

CREATE STORAGE INTEGRATION titanic_azure_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = '06d85260-9d73-4a2e-b881-8715c7edc475'
  STORAGE_ALLOWED_LOCATIONS = (
    'azure://snowflakedataset.blob.core.windows.net/titanicdataset/'
  );

DESC INTEGRATION titanic_azure_integration;

-- A stage = a pointer to external or internal storage where data files are kept

USE DATABASE practice;
USE SCHEMA public;

CREATE OR REPLACE STAGE titanic_azure_stage
  STORAGE_INTEGRATION = titanic_azure_integration
  URL = 'azure://snowflakedataset.blob.core.windows.net/titanicdataset/'
  FILE_FORMAT = (
    TYPE              = 'CSV'
    FIELD_DELIMITER   = ','
    SKIP_HEADER       = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF           = ('', 'NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
  );


  LIST @titanic_azure_stage;


  CREATE OR REPLACE TABLE azure_titanic (
  PassengerId  INT,
  Survived     INT,       -- 0 = No, 1 = Yes
  Pclass       INT,       -- 1 = First class, 2 = Second, 3 = Third
  Name         VARCHAR(200),
  Sex          VARCHAR(10),
  Age          FLOAT,
  SibSp        INT,       -- Number of siblings/spouses aboard
  Parch        INT,       -- Number of parents/children aboard
  Ticket       VARCHAR(50),
  Fare         FLOAT,
  Cabin        VARCHAR(50),
  Embarked     VARCHAR(5) -- S=Southampton, C=Cherbourg, Q=Queenstown
);


COPY INTO azure_titanic
FROM @titanic_azure_stage/titanic_dataset.csv
FILE_FORMAT = (
  TYPE                        = 'CSV'
  FIELD_DELIMITER             = ','
  SKIP_HEADER                 = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF                     = ('', 'NULL', 'null')
  EMPTY_FIELD_AS_NULL         = TRUE
);



-- How many rows?
SELECT COUNT(*) FROM azure_titanic;
-- Should be 891

-- See first 10 rows
SELECT * FROM azure_titanic LIMIT 10;