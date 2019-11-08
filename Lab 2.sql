/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [CompetitionID]
      ,[NumofRounds]
      ,[NumofTeams]
      ,[LocationName]
      ,[StartingDate]
  FROM [Debate Competitions].[dbo].[Debate_Competition]