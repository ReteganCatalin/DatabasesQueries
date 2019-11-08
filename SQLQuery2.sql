USE master
GO
IF NOT EXISTS (
   SELECT name
   FROM sys.databases
   WHERE name = N'Debate Competitions'
)
CREATE DATABASE [Debate Competitions]
GO
USE [Debate Competitions]
CREATE TABLE Trainer 
(	TrainerID INT PRIMARY KEY,
	FirstName VARCHAR(30) DEFAULT 'TBA',
	LastName VARCHAR(30) DEFAULT 'TBA',
	YearsofExperience TINYINT NOT NULL,
	Gender CHAR(1) CHECK(Gender='F' or Gender='M')
)
ALTER TABLE Trainer
ADD DateOfBirth DATE

ALTER TABLE Debater
ADD DateOfBirth DATE

CREATE TABLE Debater 
(	Debater_ID INT PRIMARY KEY,
	FirstName VARCHAR(30) DEFAULT 'TBA',
	LastName VARCHAR(30) DEFAULT 'TBA',
	NumofCompetitions TINYINT NOT NULL,
	Gender CHAR(1) CHECK(Gender='F' or Gender='M'),
	Trainer_ID INT FOREIGN KEY REFERENCES Trainer(TrainerID)
)

CREATE TABLE Debate_Competition
(
	CompetitionID TINYINT PRIMARY KEY,
	NumofRounds TINYINT DEFAULT 4,
	NumofTeams TINYINT DEFAULT 24,
	LocationName varchar(30) DEFAULT 'Bucharest'
)

ALTER TABLE Debate_Competition
ADD StartingDate Date


CREATE TABLE C_A_Team_Member
(
	CompetitionID TINYINT FOREIGN KEY REFERENCES Debate_Competition(CompetitionID) ON UPDATE CASCADE ON DELETE NO ACTION,
	TrainerID INT FOREIGN KEY REFERENCES Trainer(TrainerID) ON UPDATE CASCADE ON DELETE NO ACTION
)

ALTER TABLE C_A_Team_Member
ADD MotionsAdded TINYINT

CREATE TABLE Adjudicator
(
	CompetitionID TINYINT FOREIGN KEY REFERENCES Debate_Competition(CompetitionID) ON UPDATE CASCADE ON DELETE NO ACTION,
	TrainerID INT FOREIGN KEY REFERENCES Trainer(TrainerID) ON UPDATE CASCADE ON DELETE NO ACTION,
	
)
ALTER TABLE Adjudicator
ADD Adjudicator_Nickname varchar(50) PRIMARY KEY
CREATE TABLE Debate_Motion
(
	MotionID INT IDENTITY PRIMARY KEY,
	Motion_Name VARCHAR(255) NOT NULL,
	Motion_Descriptrion VARCHAR(1005),
);

CREATE TABLE Debate_Round
(
	RoundNumber TINYINT DEFAULT 4,
	CompetitionID TINYINT FOREIGN KEY REFERENCES Debate_Competition(CompetitionID) ON UPDATE CASCADE ON DELETE NO ACTION,
	FK_Motion_ID INT UNIQUE FOREIGN KEY REFERENCES Debate_Motion(MotionID),
	RoundID INT Primary Key
)



CREATE TABLE Debate_Team
(
	Speaker1_ID INT FOREIGN KEY REFERENCES Debater(Debater_ID) ON UPDATE CASCADE ON DELETE NO ACTION,
	Speaker2_ID INT FOREIGN KEY REFERENCES Debater(Debater_ID) ON UPDATE NO ACTION ON DELETE NO ACTION  ,
	Speaker3_ID INT FOREIGN KEY REFERENCES Debater(Debater_ID) ON UPDATE NO ACTION ON DELETE NO ACTION ,
	Team_Name varchar(30) PRIMARY KEY,
	Competitions_Together TINYINT DEFAULT 0
)

CREATE TABLE Room
(
	Room_Capacity SMALLINT NOT NULL,
	Room_Number TINYINT Primary Key,
	Room_Type varchar(10) DEFAULT 'Class' CHECK(Room_Type='Class' or Room_Type='Laboratory' or Room_Type='Library') 
)

CREATE TABLE Debate_Match
(
	RoundID INT FOREIGN KEY REFERENCES Debate_Round(RoundID) ON UPDATE CASCADE ON DELETE NO ACTION,
	Adjudicator varchar(50) FOREIGN KEY REFERENCES Adjudicator(Adjudicator_Nickname) ON UPDATE NO ACTION ON DELETE NO ACTION,
	Government_Team varchar(30) FOREIGN KEY REFERENCES Debate_Team(Team_Name) ON UPDATE NO ACTION ON DELETE NO ACTION,
	Opposition_Team varchar(30) FOREIGN KEY REFERENCES Debate_Team(Team_Name) ON UPDATE NO ACTION ON DELETE NO ACTION,
	Room_Number TINYINT FOREIGN KEY REFERENCES Room(Room_Number) ON UPDATE NO ACTION ON DELETE NO ACTION,
)

Use [Debate Competitions]
ALTER TABLE Debate_Match
ADD Constraint Not_Same_Team Check ( Government_Team!=Opposition_Team)

ALTER TABLE Debate_Team
ADD CONSTRAINT Not_Same_Debater CHECK (Speaker1_ID!=Speaker2_ID AND Speaker3_ID!=Speaker2_ID AND Speaker1_ID!=Speaker3_ID ); 

EXEC sp_rename 'C_A_Team_Member.MotionsAdded', 'NumberofMotionsAdded', 'COLUMN';