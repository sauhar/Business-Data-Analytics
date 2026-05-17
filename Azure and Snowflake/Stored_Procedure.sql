---survived by class

  USE DATABASE titanic_db;
  USE SCHEMA public;

CREATE OR REPLACE PROCEDURE survival_by_class()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
BEGIN
    RETURN (
        SELECT ARRAY_AGG(
            OBJECT_CONSTRUCT(
                'Pclass', Pclass,
                'Total', Total,
                'Survived', Survived,
                'Died', Died,
                'SurvivalRate', SurvivalRate
            )
        )
        FROM (
            SELECT 
                Pclass,
                COUNT(*) AS Total,
                SUM(COALESCE(Survived, 0)) AS Survived,
                COUNT(*) - SUM(COALESCE(Survived, 0)) AS Died,
                ROUND(SUM(COALESCE(Survived, 0)) * 100 / COUNT(*), 2) AS SurvivalRate
            FROM cleaned_titanic_dataset
            GROUP BY Pclass
        )
    );
END;
$$;

    Call survival_by_class();





CREATE OR REPLACE PROCEDURE survival_by_gender()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
BEGIN
    RETURN (
        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
            'Sex',          Sex,
            'Total',        Total,
            'Survived',     Survived,
            'Died',         Died,
            'SurvivalRate', SurvivalRate
        ))
        FROM (
            SELECT
                Sex,
                COUNT(*)                                              AS Total,
                SUM(COALESCE(Survived, 0))                            AS Survived,
                COUNT(*) - SUM(COALESCE(Survived, 0))                 AS Died,
                ROUND(SUM(COALESCE(Survived, 0)) * 100.0 / COUNT(*), 2) AS SurvivalRate
            FROM cleaned_titanic_dataset
            GROUP BY Sex
            ORDER BY SurvivalRate DESC
        )
    );
END;
$$;

call survival_by_gender()