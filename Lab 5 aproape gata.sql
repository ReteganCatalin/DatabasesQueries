USE master
GO
IF NOT EXISTS (
   SELECT name
   FROM sys.databases
   WHERE name = N'Test Tables'
)
CREATE DATABASE [Test Tables]
GO
use [Test]
CREATE TABLE Genre
(
	GID int Primary Key,
	GenreName varchar(30),
)

CREATE TABLE Book
(
	BID int Primary Key,
	Title varchar(40),
	AuthorFullName varchar(40),
	Price int,
	Genre int FOREIGN KEY references Genre(GID)
)

Create Table Basket
(
	BasketID int,
	BasketOwner varchar(30),
	Size int
	Constraint PK_Constaint Primary Key (BasketID,BasketOwner)
)
USE [Test]

Go
CREATE or Alter View View1Table as
	Select * 
	From [Test].dbo.Book
Go
CREATE or Alter View View2Table as
	Select * 
	From [Test].dbo.Book Full Join [Test].dbo.Genre on Genre=GID

Go 
Create or Alter View View2TableGroupBy as 
	Select GID ,Count(*) NoofBooksofGenre
	From [Test].dbo.Book inner Join [Test].dbo.Genre on Genre=GID
	Group By GID

Go


go
CREATE or Alter Procedure Insert_Rows
	@nr_of_rows varchar(30),
	@table_name varchar(30)
As
	SET NOCOUNT ON
	if ISNUMERIC(@nr_of_rows) != 1
	BEGIN
		print('Not a number')
		return 1
	END

	SET @nr_of_rows=cast(@nr_of_rows as INT)

	declare @inserted int
	set @inserted=1

	declare @BasketOwner varchar(30)
	declare @Size int

	declare @Title varchar(40)
	declare @AuthorFullName varchar(40)
	declare @Price int
	declare @GID int

	declare @GenreName varchar(30)

	declare @minicontor int
	set @minicontor=1
	
	while @inserted<=@nr_of_rows
	BEGIN
		if @table_name= 'Genre'
		begin
			set @GenreName= 'Genre'+convert(varchar(7),((@inserted*2+3)*2+4))
			insert into Genre(GID,GenreName) values (@inserted,@GenreName)
					
		end

		if @table_name = 'Book'
		begin
			set @Title='title'+CONVERT(varchar(7),((@inserted*3+3)*4+14))
			set @AuthorFullName='IonCatarama'+CONVERT(varchar(7),((@minicontor*2+4)*2+11))
			set @Price=@minicontor+@inserted+3
			set @GID=@minicontor
			insert into Book(BID,Title,AuthorFullName,Price,Genre) values(@inserted,@Title,@AuthorFullName,@Price,@GID) 
		end

		if @table_name ='Basket'
		begin
			set @BasketOwner='user'+CONVERT(varchar(7),((@minicontor*2+1)*2+1))
			set @Size=30
			insert into Basket(BasketID,BasketOwner,Size) values (@inserted,@BasketOwner,@Size)
		end

		set @inserted=@inserted+1

		if @inserted%10 = 0
		begin
			set @minicontor=@minicontor+1
		end

	END

go

CREATE or Alter Procedure Delete_Rows
	@nr_of_rows varchar(30),
	@table_name varchar(30)
As
	SET NOCOUNT ON
	if ISNUMERIC(@nr_of_rows) != 1
	BEGIN
		print('Not a number')
		return 1
	END

	SET @nr_of_rows=cast(@nr_of_rows as INT)
	declare @min_val int
	BEGIN
		if @table_name= 'Genre'
		begin
			set @min_val=(Select MAX(GID) From Genre)-@nr_of_rows
			Delete from Book
			where Genre > =@min_val
			Delete from Genre
			where GID >= @min_val 	
		end
		if @table_name = 'Book'
		begin
			set @min_val=(Select MAX(BID) From Book)-@nr_of_rows
			Delete from Book
			where BID >= @min_val
		end

		if @table_name ='Basket'
		begin
			set @min_val=(Select MAX(BasketID) From Basket) - @nr_of_rows
			Delete from Basket
			where BasketID>=@min_val
		end
	END

go
USE [Test]
go
CREATE or Alter Procedure Select_Views
	@view_name varchar(30)
AS
	if @view_name='View1Table'
	begin 
			Select * From View1Table 
	end
	if @view_name='View2Table'
	begin 
			Select * From View2Table 
	end
	if @view_name='View2TableGroupBy'
	begin 
			Select * From View2TableGroupBy 
	end


go

CREATE or Alter Procedure DoTest
	@nr_of_rows varchar(30)
As
	if ISNUMERIC(@nr_of_rows) != 1
	BEGIN
		print('Not a number')
		return 1 
	END

	insert into Tests
	values('insert in all delete in all select all')

	declare @lastTestID int; 
	set @lastTestID = (select max(TestId) from Tests);

	insert into TestTables
	values
	(@lastTestID,1,cast(@nr_of_rows as INT),1),
	(@lastTestID,2,cast(@nr_of_rows as INT),2),
	(@lastTestID,3,cast(@nr_of_rows as INT),3);

	insert into TestViews
	values
	(@lastTestID,1),
	(@lastTestID,2),
	(@lastTestID,3);

	declare @all_start datetime 
	set @all_start = getdate() 

	declare @starttimeinsertInGenre datetime
	Set @starttimeinsertInGenre=GETDATE()
	execute Insert_Rows @nr_of_rows, 'Genre'
	declare @endtimeinsertInGenre datetime
	Set @endtimeinsertInGenre=GETDATE()

	declare @starttimeinsertInBook datetime
	Set @starttimeinsertInBook=GETDATE()
	execute Insert_Rows @nr_of_rows, 'Book'
	declare @endtimeinsertInBook datetime
	Set @endtimeinsertInBook=GETDATE()

	declare @starttimeinsertInBasket datetime
	Set @starttimeinsertInBasket=GETDATE()
	execute Insert_Rows @nr_of_rows, 'Basket'
	declare @endtimeinsertInBasket datetime
	Set @endtimeinsertInBasket=GETDATE()

	declare @starttimeView1 datetime
	Set @starttimeView1=GETDATE()
	execute Select_Views 'View1Table'
	declare @endtimeView1 datetime
	Set @endtimeView1=GETDATE()

	declare @starttimeView2 datetime
	Set @starttimeView2=GETDATE()
	execute Select_Views 'View2Table'
	declare @endtimeView2 datetime
	Set @endtimeView2=GETDATE()

	declare @starttimeView3 datetime
	Set @starttimeView3=GETDATE()
	execute Select_Views 'View2TableGroupBy'
	declare @endtimeView3 datetime
	Set @endtimeView3=GETDATE()

	declare @starttimedeleteInBook datetime
	Set @starttimedeleteInBook=GETDATE()
	execute Delete_Rows @nr_of_rows, 'Book'
	declare @endtimedeleteInBook datetime
	Set @endtimedeleteInBook=GETDATE()

	declare @starttimedeleteInGenre datetime
	Set @starttimedeleteInGenre=GETDATE()
	execute Delete_Rows @nr_of_rows, 'Genre'
	declare @endtimedeleteInGenre datetime
	Set @endtimedeleteInGenre=GETDATE()

	declare @starttimedeteleInBasket datetime
	Set @starttimedeteleInBasket=GETDATE()
	execute Delete_Rows @nr_of_rows, 'Basket'
	declare @endtimedeleteInBasket datetime
	Set @endtimedeleteInBasket=GETDATE()

	declare @all_stop datetime 
	set @all_stop = getdate() 

	declare @description varchar(100)
	set @description = 'TestRun' + convert(varchar(7), (select max(TestRunID) from TestRuns)) + 'insert, delete ' + @nr_of_rows + ' rows, select all views'

	insert into TestRuns(Description, StartAt, EndAt)
	values(@description, @all_start, @all_stop);

	declare @lastTestRunID int; 
	set @lastTestRunID = (select max(TestRunID) from TestRuns)

	insert into TestRunTables
	values(@lastTestRunID, 1, @starttimeinsertInGenre, @endtimeinsertInGenre)

	insert into TestRunTables
	values(@lastTestRunID, 2, @starttimeinsertInBook, @endtimeinsertInBook)

	insert into TestRunTables
	values(@lastTestRunID, 3, @starttimeinsertInBasket, @endtimeinsertInBasket)

	insert into TestRunViews
	values(@lastTestRunID, 1, @starttimeView1, @endtimeView1)
	
	insert into TestRunViews
	values(@lastTestRunID, 2, @starttimeView2, @endtimeView2)

	insert into TestRunViews
	values(@lastTestRunID,3, @starttimeView3, @endtimeView3)


go
exec DoTest 10000