CREATE DATABASE Project;

GO
CREATE PROC createAllTables
AS 
create table Super_User(
    username varchar(20) primary key,
    password varchar(20)
);

create table System_Admin(
	id int PRIMARY KEY IDENTITY,
	name varchar(20),
    username varchar(20) Foreign KEY references Super_User 
);

create table Association_Manager(
    id int primary key identity,
	name varchar(20),
    username varchar(20) references Super_User 
);


CREATE TABLE Club(
	id INT PRIMARY KEY IDENTITY,
	name VARCHAR(20),
	location VARCHAR(20)
);

create table Representative(
    id int primary key identity,
	username varchar(20) Foreign KEY references Super_User,
	name varchar(20),
	club_id int Foreign KEY references Club
);

CREATE TABLE Stadium(
	id INT PRIMARY KEY IDENTITY,
	name VARCHAR(20),
	capacity INT ,
	location VARCHAR(20),
	status bit
);

create table Manager(
    id int primary key IDENTITY,
    name varchar(20),
    username varchar(20) Foreign KEY references Super_User ,
	stadium_id int Foreign KEY references Stadium
);

CREATE TABLE Match(
	id INT PRIMARY KEY IDENTITY,
	starting_time date,
	ending_time date,
	host_club INT references Club, 
	guest_club INT references Club,
	stadium_id INT references Stadium 
);

CREATE TABLE Fan(
	national_id VARCHAR(20) PRIMARY KEY,
	name varchar(20),
	birth_date datetime,
	address varchar(20),
	phone_number varchar(20),
	status bit,
	username varchar(20) Foreign KEY references Super_User 
);



CREATE TABLE Ticket(
	id int PRIMARY KEY IDENTITY,
	status varchar(20),
	match_id int references Match
);

CREATE TABLE Ticket_Buying_Transactions(
	fan_id VARCHAR(20) Foreign KEY references Fan,
	ticket_id int Foreign KEY references Ticket
);

CREATE TABLE Host_Request(
	id int PRIMARY KEY IDENTITY,
	representative_id int Foreign KEY references Representative,
	manager_id int Foreign KEY references Manager,
	match_id int Foreign KEY references Match,
	status bit default NULL
);
GO

CREATE PROCEDURE dropAllTables 
AS
DROP TABLE Host_Request;
DROP TABLE Ticket_Buying_Transactions;
DROP TABLE Ticket;
DROP TABLE Fan;
DROP TABLE Match;
DROP TABLE Representative;
DROP TABLE Club;
DROP TABLE Association_Manager;
DROP TABLE System_Admin;
DROP TABLE Manager;
DROP TABLE Super_User;
DROP TABLE Stadium;
GO


CREATE PROC clearAllTables
AS
EXEC dropAllTables;
EXEC createAllTables;
GO

-------------------------------HELPER_Functions-------------------------------------------------
CREATE FUNCTION getClubID (@name varchar(20))
RETURNS INT
BEGIN
DECLARE @ret int
SELECT @ret = c.id 
FROM Club c
WHERE c.name = @name
RETURN @ret
END
GO


CREATE FUNCTION getMatchID(@hname varchar(20) , @gname varchar(20), @date datetime) 
RETURNS INT
BEGIN
DECLARE @res int
SELECT @res = m.id
FROM Match m, Club c1, Club c2
WHERE c1.name = @hname AND C2.name = @gname AND c1.id = m.host_club AND c2.id = m.guest_club AND m.starting_time = @date
RETURN @res
END
GO

CREATE FUNCTION getMatchID1(@name varchar(20), @date datetime) 
RETURNS INT
BEGIN
DECLARE @res int
SELECT @res = m.id
FROM Match m, Club c1
WHERE c1.name = @name AND c1.id = m.host_club AND m.starting_time = @date
RETURN @res
END
GO

CREATE FUNCTION getManagerID(@name VARCHAR(20))
RETURNS INT
BEGIN
DECLARE @res int
SELECT @res = m.id
FROM Manager m, Stadium s
WHERE s.name = @name AND m.stadium_id = s.id
RETURN @res
END
GO

CREATE FUNCTION getRepresentativeID(@club_name VARCHAR(20))
RETURNS INT
BEGIN
DECLARE @res int
SELECT @res = r.id
FROM Representative r, Club c
WHERE c.name = @club_name AND r.club_id = c.id
RETURN @res
END
GO

CREATE FUNCTION getStadiumID(@stadium_name VARCHAR(20))
RETURNS INT
BEGIN
DECLARE @id INT
SELECT @id = id
FROM Stadium 
WHERE name = @stadium_name
RETURN @id
END
GO

CREATE FUNCTION getManagerID2(@username VARCHAR(20))
RETURNS INT
BEGIN
DECLARE @id INT
SELECT @id = id
FROM Manager 
WHERE username = @username
RETURN @id
END
GO

CREATE FUNCTION getClubName(@id int)
RETURNS VARCHAR(20)
BEGIN 
DECLARE @res VARCHAR(20)
SELECT @res = name 
From Club
where id = @id
return @res
END
GO

CREATE FUNCTION getStadiumName(@id int)
RETURNS VARCHAR(20)
BEGIN 
DECLARE @res VARCHAR(20)
SELECT @res = name 
From Stadium
where id = @id
return @res
END
GO

CREATE FUNCTION getTicketId(@match_id int)
RETURNS INT
BEGIN
DECLARE @id INT
SELECT TOP 1 @id = id
FROM Ticket 
WHERE match_id = @match_id AND status = 1
RETURN @id
END
Go

--------------------------------------------------------------------------------------------------

Go
CREATE VIEW allAssocManagers AS
Select a.username, s.password , a.name
From Association_Manager a INNER JOIN Super_User s ON s.username = a.username;
Go


CREATE VIEW allClubRepresentatives AS
Select r.username,  s.password ,  r.name as Representative_Name , c.name as Club_Name
From Representative r , Club c , Super_User s
where c.id = r.id AND s.username = r.username;
Go

CREATE VIEW allStadiumManagers AS
Select m.username , su.password , m.name, s.name as Stadium_Name
From Manager m , Stadium s , Super_User su
where s.id = m.stadium_id AND m.username = su.username;
GO

CREATE VIEW allFans AS
Select f.username , s.password , f.name, f.national_id, f.birth_date, f.status
From Fan f , Super_User s 
WHERE f.username = s.username;
GO

CREATE VIEW allMatches AS 
SELECT c1.name as Host_Club , c2.name as Guest_Club , m.starting_time
FROM Club c1 , Club c2 , Match m 
where c1.id = m.host_club AND c2.id = m.guest_club;
GO

CREATE VIEW allTickets AS
SELECT c1.name as Host_Club , c2.name as Guest_Club , s.name as Stadium_Name , m.starting_time
FROM Club c1 , Club c2 , Stadium s , Match m , Ticket t
where m.id = t.match_id AND c1.id = m.host_club AND c2.id = m.guest_club AND m.stadium_id = s.id;
GO

CREATE VIEW allClubs AS
Select name, location
From Club;
GO

create view allStadiums as
Select name, location, capacity, status 
From Stadium;
GO

CREATE VIEW allRequests AS
SELECT r.username AS Representative_Username , m.username As Manager_Username , h.status
From Representative r , Manager m , Host_Request h
where r.id = h.representative_id AND m.id = h.manager_id;
GO


CREATE PROC addAssociationManager 
@name VARCHAR(20),
@user_name VARCHAR(20),
@password VARCHAR(20)
AS
INSERT INTO Super_User VALUES(@user_name, @password)
INSERT INTO Association_Manager VALUES(@name, @user_name);
GO

CREATE PROC addNewMatch 
@host_name VARCHAR(20),
@guest_name VARCHAR(20),
@start_time datetime,
@end_time datetime
AS
INSERT INTO Match (starting_time, ending_time, host_club, guest_club) 
VALUES(@start_time , @end_time, dbo.getClubID(@host_name), dbo.getClubID(@guest_name)); 
GO

CREATE VIEW clubsWithNoMatches AS
SELECT c.name
FROM Club c
WHERE c.id NOT IN(select host_club from match) and c.id not in (select guest_club from match);
GO

create proc deleteMatchHelper 
@id int
AS
delete from Ticket_Buying_Transactions where ticket_id in (select id from Ticket where match_id = @id);
delete from Ticket where match_id = @id;
delete from Host_Request where match_id = @id;
delete from Match where id = @id;
GO

CREATE PROC deleteMatch
@host_club VARCHAR(20) , @guest_club VARCHAR(20)
AS
Declare @id int;
Select top 1 @id = id from Match where dbo.getClubID(@host_club) = host_club and dbo.getClubID(@guest_club) = guest_club;
exec deleteMatchHelper @id;
GO


CREATE PROC deleteMatchesOnStadium
@stadium_name VARCHAR(20)
As
delete from Ticket_Buying_Transactions where ticket_id in (select id from Ticket where match_id in (select id from Match where stadium_id in (select id from Stadium where name = @stadium_name) and starting_time > CURRENT_TIMESTAMP));
delete from Ticket where match_id in (select id from Match where stadium_id in (select id from Stadium where name = @stadium_name) and starting_time > CURRENT_TIMESTAMP);
delete from Host_Request where match_id in (select id from Match where stadium_id in (select id from Stadium where name = @stadium_name) and starting_time > CURRENT_TIMESTAMP);
delete from Match 
where stadium_id in 
(Select id from Stadium where
name = @stadium_name) and starting_time > CURRENT_TIMESTAMP;
GO


CREATE PROC addClub
@name VARCHAR(20) , @location VARCHAR(20)
AS
INSERT INTO Club Values(@name , @location);
GO

CREATE PROC addTicket
@host_club VARCHAR(20) , @guest_club VARCHAR(20) , @date_time datetime
AS
INSERT INTO Ticket VALUES (1 , dbo.getMatchID(@host_club, @guest_club, @date_time));
go

create proc deleteClubHelper
@id INT
as
delete from Ticket_Buying_Transactions where ticket_id in (select id from Ticket where match_id in (select id from Match where host_club = @id or guest_club = @id));
delete from Ticket where match_id in (select id from Match where host_club = @id or guest_club = @id);
delete from Host_Request where match_id in (select id from Match where host_club = @id or guest_club = @id);
delete from Match where host_club = @id or guest_club = @id;
delete from Representative where club_id = @id;
delete from Club where id = @id;
go

CREATE PROC deleteClub
@name VARCHAR(20)
AS
declare @id int;
select top 1 @id = id from Club where @name = name;
exec deleteClubHelper @id;
GO

CREATE PROC addStadium
@name VARCHAR(20) , @location VARCHAR(20) , @capacity INT
AS
INSERT INTO Stadium values(@name , @capacity  , @location , 1);
GO

create proc deleteStadiumHelper
@id INT
as
delete from Ticket_Buying_Transactions where ticket_id in (select id from Ticket where match_id in (select id from Match where stadium_id = @id));
delete from Ticket where match_id in (select id from Match where stadium_id = @id);
delete from Host_Request where match_id in (select id from Match where stadium_id = @id);
delete from Match where stadium_id = @id;
delete from Manager where stadium_id = @id;
delete from Stadium where id = @id;
go

CREATE PROC deleteStadium
@name VARCHAR(20)
AS
declare @id int;
select top 1 @id = id from Stadium where id = @id;
exec deleteStadiumHelper @id;
GO

CREATE PROC blockFan 
@national_id VARCHAR(20)
AS
UPDATE Fan
SET status = 0 WHERE @national_id = national_id;
GO

CREATE PROC unblockFan 
@national_id VARCHAR(20)
AS
UPDATE Fan
SET status = 1 WHERE @national_id = national_id;
GO

CREATE PROC addRepresentative
@name VARCHAR(20),
@club_name VARCHAR(20),
@representative_username VARCHAR(20),
@password VARCHAR(20)
AS
INSERT INTO Super_User VALUES(@representative_username, @password)
INSERT INTO Representative VALUES(@representative_username, @name, dbo.getClubID(@club_name))
GO

CREATE FUNCTION viewAvailableStadiumsOn
(@date datetime)
RETURNS TABLE
AS
RETURN
(
SELECT s.name, s.location, s.capacity
FROM Stadium s
WHERE s.id NOT IN
(SELECT m.stadium_id
FROM Match m
WHERE m.starting_time = @date)
)
GO

CREATE PROC addHostRequest
@club_name VARCHAR(20),
@stadium_name VARCHAR(20),
@date_time datetime
AS
INSERT INTO Host_Request VALUES(dbo.getRepresentativeID(@club_name), dbo.getManagerID(@stadium_name), dbo.getMatchID1(@club_name, @date_time), NULL)
GO

CREATE FUNCTION allUnassignedMatches(@club_name VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
SELECT c2.name as Guest_Club, m.starting_time
FROM Match m, Club c1, Club c2
WHERE m.host_club = c1.id AND m.guest_club = c2.id AND m.stadium_id IS NULL AND c1.name = @club_name
)
GO

CREATE PROC addStadiumManager
@name VARCHAR(20),
@stadium_name VARCHAR(20),
@username VARCHAR(20),
@password VARCHAR(20)
AS
INSERT INTO Super_User values(@username, @password)
INSERT INTO Manager values(@name, @username, dbo.getStadiumID(@stadium_name))
GO



CREATE FUNCTION allPendingRequests (@username VARCHAR(20))
RETURNS TABLE 
AS
RETURN
(
SELECT R.name AS Representative_name, C.name AS Guest_Club, M.starting_time
FROM Representative R , Club C, Match M, Host_Request H
WHERE H.representative_id = R.id AND H.manager_id = dbo.getManagerID2(@username) AND H.match_id = M.id AND C.id = M.guest_club AND R.club_id = M.host_club
) 
GO

CREATE PROC acceptRequest
@managerUserName VARCHAR(20),
@hostClub VARCHAR(20),
@guestClub VARCHAR(20),
@startTime datetime
AS
update host_request
set status = 1
where manager_id = dbo.getManagerID2(@managerUserName) and representative_ID = dbo.getRepresentativeID(@hostClub) and match_ID = dbo.getMatchID(@hostClub, @guestClub, @startTime)
update Match	
set stadium_id = (SELECT stadium_id FROM Manager where username = @managerUserName)
where id = dbo.getMatchID(@hostClub , @guestClub , @startTime)
GO

CREATE PROC rejectRequest
@managerUserName VARCHAR(20),
@hostClub VARCHAR(20),
@guestClub VARCHAR(20),
@startTime datetime
AS
update host_request
set status = 0
where manager_id = dbo.getManagerID2(@managerUserName) and representative_ID = dbo.getRepresentativeID(@hostClub) and match_ID = dbo.getMatchID(@hostClub, @guestClub, @startTime)
GO

CREATE PROC addFan 
@name VARCHAR(20),
@username VARCHAR(20),
@password VARCHAR(20),
@national_id VARCHAR(20),
@birth_date datetime,
@address VARCHAR(20),
@phone_num VARCHAR(20)
AS
INSERT INTO Super_User VALUES(@username, @password)
INSERT INTO Fan VALUES(@national_id, @name, @birth_date, @address, @phone_num, 1, @username)
GO


CREATE FUNCTION upcomingMatchesOfClub(@clubName VARCHAR(20))
RETURNS @res Table(Host_Club VARCHAR(20), Guest_Club VARCHAR(20), start datetime, Stadium VARCHAR(20))
AS
BEGIN
declare @inputClubID int = dbo.getClubID(@clubName)
declare @temp Table(id int, startTime datetime, endingTime datetime, hostClub int, guestClub int, stadiumId int)
INSERT INTO @temp(id, startTime, endingTime, hostClub, guestClub, stadiumID) 
SELECT * FROM Match 
WHERE starting_time > current_TimeStamp AND (host_club = @inputClubID OR guest_club = @inputClubID)
INSERT INTO @res(Host_Club, Guest_Club, start, Stadium)
SELECT dbo.getClubName(hostClub), dbo.getClubName(guestClub), startTime, dbo.getStadiumName(stadiumID)
FROM @temp
return
END
GO

Create FUNCTION availableMatchesToAttend(@date_time datetime)
RETURNS TABLE
AS
RETURN
(   
SELECT Distinct c1.name as Host_club, c2.name Guest_Club, m.starting_time, s.name stadium_Name
FROM Match m, Club c1, Club c2, Stadium s , Ticket t
WHERE t.match_id = m.id And t.status = 1 AND  m.host_club = c1.id AND m.guest_club = c2.id AND m.stadium_id = s.id AND m.starting_time > @date_time
)
GO

CREATE PROC purchaseTicket
@fan_national_id VARCHAR(20),
@host_club VARCHAR(20),
@guest_club VARCHAR(20),
@date_time datetime
AS
Insert into Ticket_Buying_Transactions values(@fan_national_id, dbo.getTicketId(dbo.getMatchID(@host_club, @guest_club, @date_time)))
UPDATE Ticket
SET status = 0
WHERE id = dbo.getTicketId(dbo.getMatchID(@host_club, @guest_club, @date_time))
GO

CREATE PROC updateMatchHost
@host_club VARCHAR(20),
@guest_club VARCHAR(20),
@date_time datetime
AS
UPDATE Match
SET host_club = dbo.getClubID(@guest_club) , guest_club = dbo.getClubID(@host_club)
WHERE id = dbo.getMatchID(@host_club, @guest_club, @date_time)
GO

CREATE view matchesPerTeam
AS
SELECT c.name, COUNT(m.id) AS matches
FROM Club c, Match m
WHERE m.starting_time < current_TimeStamp AND c.id = m.host_club OR c.id = m.guest_club 
GROUP BY c.name
GO

CREATE view clubsNeverMatched
AS
SELECT c1.name AS First_Club, c2.name AS Second_Club
FROM Club c1, Club c2
WHERE c1.id <> c2.id AND NOT EXISTS 
(SELECT * FROM Match m WHERE (m.host_club = c1.id AND m.guest_club = c2.id) OR (m.host_club = c2.id AND m.guest_club = c1.id))
GO

CREATE Function clubsNeverPlayed(@clubName VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
SELECT c.name
FROM Club c
WHERE c.id <> dbo.getClubID(@clubName) AND NOT EXISTS
(SELECT * FROM Match m 
    WHERE (m.host_club = dbo.getClubID(@clubName) AND m.guest_club = c.id) OR (m.host_club = c.id AND m.guest_club = dbo.getClubID(@clubName)))
)
GO

CREATE FUNCTION matchWithHighestAttendance()
RETURNS TABLE
AS
RETURN
(
SELECT c1.name AS hostClub, c2.name AS guestClub
FROM Match m, Club c1, Club c2
WHERE m.host_club = c1.id AND m.guest_club = c2.id AND m.id =
(SELECT TOP 1 t.match_id
FROM Ticket_Buying_Transactions tbt , Ticket t
where t.id = tbt.ticket_id
GROUP BY t.match_id
ORDER BY COUNT(t.match_id) DESC)
)
GO

CREATE FUNCTION matchesRankedByAttendance()
RETURNS @res Table(hostClub VARCHAR(20), guestClub VARCHAR(20), ticketsSold int)
AS
BEGIN
INSERT INTO @res(hostClub , guestClub , ticketsSold)
SELECT c1.name AS hostClub, c2.name AS guestClub, COUNT(t.match_id) AS ticketsSold
FROM Match m, Club c1, Club c2, Ticket_Buying_Transactions tbt , Ticket t
WHERE m.host_club = c1.id AND m.guest_club = c2.id AND m.id = t.match_id AND t.id = tbt.ticket_id
GROUP BY c1.name, c2.name
ORDER BY COUNT(t.match_id) DESC
RETURN
END
GO

Create Function requestsFromClub(@stadiumName VARCHAR(20) , @clubName VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
SELECT dbo.getClubName(m.host_club) AS Host_Club, dbo.getClubName(m.guest_club) AS Guest_Club
FROM Match m,  Host_Request h
WHERE h.representative_ID = dbo.getRepresentativeID(@clubName) AND h.manager_id = dbo.getManagerID(@stadiumName) AND h.match_id = m.id
)
GO


Create PROC deleteAllProcs
AS
declare @procName varchar(500)
declare cur cursor 
for select [name] from sys.objects where type = 'p'
open cur
fetch next from cur into @procName
while @@fetch_status = 0
begin
	IF @procName <> 'dropAllProceduresFunctionsViews' AND 
	@procName <> 'deleteAllProcs'AND @procName <> 'deleteAllFunctions' AND @procName <> 'deleteAllViews'
	BEGIN
		exec('drop procedure [' + @procName + ']')
	END
	fetch next from cur into @procName
end
close cur
deallocate cur
GO

Create Proc deleteAllFunctions
AS
Declare @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + N' DROP FUNCTION ' 
                   + QUOTENAME(SCHEMA_NAME(schema_id)) 
                   + N'.' + QUOTENAME(name)
FROM sys.objects
WHERE type_desc LIKE '%FUNCTION%';
Exec sp_executesql @sql
GO

Create Proc deleteAllViews
AS
Declare @viewName varchar(500) 
Declare cur Cursor For Select [name] From sys.objects where type = 'v' 
Open cur 
Fetch Next From cur Into @viewName 
While @@fetch_status = 0 
Begin 
 Exec('drop view ' + @viewName) 
 Fetch Next From cur Into @viewName 
End
Close cur 
Deallocate cur
GO

Create Proc dropAllProceduresFunctionsViews
AS
BEGIN
EXEC deleteAllFunctions
EXEC deleteAllViews
EXEC deleteAllProcs
END
GO

EXEC dropAllProceduresFunctionsViews

--Create clubs using addclub procedure
EXEC addClub 'Al Ahly', 'Cairo', 'Egypt'
EXEC addClub 'Al Zamalek', 'Cairo', 'Egypt'
EXEC addClub 'Al Masry', 'Alexandria', 'Egypt'
EXEC addClub 'Al Ittihad', 'Alexandria', 'Egypt'

--Create stadiums using addStadium procedure
EXEC addStadium 'Cairo Stadium', 'Cairo', 10000
EXEC addStadium 'Alexandria Stadium', 'Alexandria', 5000

--Create managers using addStadiumManager procedure
EXEC addStadiumManager 'Ahmed', 'Ahmed', 'Cairo Stadium'
EXEC addStadiumManager 'Mohamed', 'Mohamed', 'Alexandria Stadium'

--Create representatives using addRepresentative procedure
EXEC addRepresentative 'Ahmed', 'Ahmed', 'Al Ahly'
EXEC addRepresentative 'Mohamed', 'Mohamed', 'Al Zamalek'
EXEC addRepresentative 'Ali', 'Ali', 'Al Masry'
EXEC addRepresentative 'Khaled', 'Khaled', 'Al Ittihad'

--Create matches using addMatch procedure
EXEC addMatch 'Al Ahly', 'Al Zamalek', '2019-12-12 12:00:00'
EXEC addMatch 'Al Ahly', 'Al Ittihad', '2019-12-12 12:00:00'
EXEC addMatch 'Al Zamalek', 'Al Masry', '2019-12-12 12:00:00'
EXEC addMatch 'Al Ittihad', 'Al Mas', '2019-12-12 12:00:00'

--Create tickets using addTicket procedure
EXEC addTicket 'Al Ahly', 'Al Zamalek', '2019-12-12 12:00:00' 
EXEC addTicket 'Al Ahly', 'Al Ittihad', '2019-12-12 12:00:00'
EXEC addTicket 'Al Zamalek', 'Al Masry', '2019-12-12 12:00:00'
EXEC addTicket 'Al Ittihad', 'Al Mas', '2019-12-12 12:00:00'

--Create host requests using addHostRequest procedure
EXEC addHostRequest 'Al Ahly', 'Cairo Stadium', 'Al Ahly', 'Al Zamalek', '2019-12-12 12:00:00'
EXEC addHostRequest 'Al Zamalek', 'Alexandria Stadium', 'Al Zamalek', 'Al Masry', '2019-12-12 12:00:00'
EXEC addHostRequest 'Al Ittihad', 'Alexandria Stadium', 'Al Ittihad', 'Al Mas', '2019-12-12 12:00:00'

--Create Association_Manager using addAssociationManager procedure
EXEC addAssociationManager 'Ahmed', 'Ahmed', 'ahmedadmin'

--Create Fans using addFan procedure
EXEC addFan 'Ahmed', 'Ahmed', 'ahmedfan', '3650', '2019-12-12 12:00:00', '0100000000', 'Cairo'
EXEC addFan 'Mohamed', 'Mohamed', 'mohamedfan', '3651', '2019-12-12 12:00:00', '0101200000', 'Alexandria'