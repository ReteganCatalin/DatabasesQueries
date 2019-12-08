use [Debate Competitions]
GO
--modify a column
CREATE OR ALTER PROC ups1 
AS
	ALTER TABLE Debater 
	ALTER COLUMN DateOfBirth datetime
GO
CREATE OR ALTER PROC dps1
AS
	ALTER TABLE Debater
	ALTER COLUMN DateOfBirth date
Go
--add/remove a column
CREATE OR ALTER PROC ups2
AS
	ALTER TABLE Room 
	ADD  RoomTables smallint
GO
CREATE OR ALTER PROC dps2
AS
	ALTER TABLE Room
	Drop Column RoomTables 
Go
--Add/remove a DEFAULT constraint
CREATE or ALTER PROC ups3
AS
	ALTER TABLE Debater
	ADD Constraint num_of_competitions DEFAULT 3 for NumofCompetitions
GO

CREATE or ALTER PROC dps3
AS
	ALTER TABLE Debater
	DROP CONSTRAINT num_of_competitions
GO

--add/remove a primary key
CREATE or ALTER PROC ups4
AS
	--ALTER TABLE Debate_Match
	--ALTER COLUMN Government_Team varchar(30) NOT NULL 
	--ALTER TABLE Debate_Match
	--ALTER COLUMN Opposition_Team varchar(30) NOT NULL 
	ALTER TABLE Debate_Match
	ADD CONSTRAINT Debate_MatchPK Primary Key NONCLUSTERED (Government_Team,Opposition_Team)
GO

CREATE or ALTER PROC dps4
AS
	ALTER TABLE Debate_Match
	Drop CONSTRAINT Debate_MatchPK
GO

--add/remove a candidate key
CREATE or ALTER PROC ups5
AS
	ALTER TABLE Debate_Motion
	ADD CONSTRAINT Unique_Motion UNIQUE (Motion_Name,Motion_Descriptrion)
GO

CREATE or ALTER PROC dps5
AS
	ALTER TABLE Debate_Motion
	DROP CONSTRAINT Unique_Motion
GO
--add/remove a foreign key 

CREATE or ALTER PROC ups6
AS
	ALTER TABLE Debate_Match
	DROP CONSTRAINT FK__Debate_Ma__Adjud__1EA48E88
GO

CREATE or ALTER PROC dps6
AS
	ALTER TABLE Debate_Match
	ADD CONSTRAINT FK__Debate_Ma__Adjud__1EA48E88 FOREIGN KEY (Adjudicator) REFERENCES Adjudicator (Adjudicator_NickName)
GO

--create/drop table

CREATE or ALTER PROC ups7
AS
	CREATE TABLE WeatherForecast(
	Dateweather DATE ,
	LocationName varchar(30), 
	Primary Key NONCLUSTERED (Dateweather,LocationName))
GO
CREATE or ALTER PROC dps7
AS
	DROP TABLE IF EXISTS WeatherForecast
GO

--create the database version table
DROP TABLE IF EXISTS LogChanges
CREATE TABLE LogChanges
	(
		id INT IDENTITY (1,1) PRIMARY KEY,
		crt_version INT
	);

--current version is #0

GO
CREATE OR ALTER PROCEDURE goToVersion 
	@version INT AS	
	DECLARE @crtVersion INT
	SET @crtVersion = (SELECT C.crt_version 
					   FROM LogChanges c)
	--print(@crtVersion)
	DECLARE @procedure VARCHAR(50)

	IF @version<0 OR @version>7 --check for wrong input version 
		BEGIN 
			PRINT 'Version must be between 0 and 7'
			RETURN
		END
	ELSE 
		BEGIN
			IF @version>@crtVersion 
			BEGIN
				WHILE @version>@crtVersion
				BEGIN
					SET @crtVersion = @crtVersion+1
					SET @procedure = 'ups' + CAST(@crtVersion AS VARCHAR(5))
					EXEC @procedure
				END
			END
			ELSE 
			BEGIN
				WHILE @version<@crtVersion 
				BEGIN
					IF @crtVersion!=0 
					BEGIN
						SET @procedure='dps'+CAST(@crtVersion AS VARCHAR(5))
						EXEC @procedure
					END
					SET @crtVersion=@crtVersion-1
				END
			END
			UPDATE LogChanges SET crt_version = @version;
			RETURN
		END	
GO

EXEC goToVersion 0
GO

update LogChanges SET crt_version=0