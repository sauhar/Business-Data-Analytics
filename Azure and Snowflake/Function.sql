  USE DATABASE titanic_db;
  USE SCHEMA public;

  --classify fare

  create or replace function classify_fare(fare float)
  returns varchar
  LANGUAGE SQL
  AS
  $$
    case when fare = 0 then 'Free'
    when fare<10 then 'Budget'
    when fare between 10 and 50 then 'Standard'
    when fare between 50 and 100 then 'Premimum'
    else 'Luxury'
end
$$;

select name,fare,classify_fare(fare) as farelabel
from cleaned_titanic_dataset


---survival risk(age, pclass)

CREATE OR REPLACE FUNCTION survival_risk(age FLOAT, pclass INT)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
    CASE
        WHEN pclass = 1 AND age < 18  THEN 'Very Low Risk'
        WHEN pclass = 1               THEN 'Low Risk'
        WHEN pclass = 2 AND age < 18  THEN 'Low Risk'
        WHEN pclass = 2               THEN 'Medium Risk'
        WHEN pclass = 3 AND age < 18  THEN 'Medium Risk'
        ELSE                               'High Risk'
    END
$$;

-- STEP 2: Use it in SELECT
SELECT
    Name,
    Age,
    Pclass,
    Survived,
    survival_risk(Age, Pclass)   AS RiskLevel
FROM cleaned_titanic_dataset
LIMIT 20;
