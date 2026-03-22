select *
from titanic_dataset

select distinct "PassengerId"
from titanic_dataset



ALTER TABLE titanic_dataset RENAME COLUMN "PassengerId" TO passenger_id;
ALTER TABLE titanic_dataset RENAME COLUMN "Survived" TO survived;
ALTER TABLE titanic_dataset RENAME COLUMN "Pclass" TO pclass;
ALTER TABLE titanic_dataset RENAME COLUMN "Name" TO name;
ALTER TABLE titanic_dataset RENAME COLUMN "Sex" TO sex;
ALTER TABLE titanic_dataset RENAME COLUMN "Age" TO age;
ALTER TABLE titanic_dataset RENAME COLUMN "SibSp" TO sibsp;
ALTER TABLE titanic_dataset RENAME COLUMN "Parch" TO parch;
ALTER TABLE titanic_dataset RENAME COLUMN "Ticket" TO ticket;
ALTER TABLE titanic_dataset RENAME COLUMN "Fare" TO fare;
ALTER TABLE titanic_dataset RENAME COLUMN "Cabin" TO cabin;
ALTER TABLE titanic_dataset RENAME COLUMN "Embarked" TO embarked;

select distinct passenger_id
from titanic_dataset


select *
from dirty_cafe_sales