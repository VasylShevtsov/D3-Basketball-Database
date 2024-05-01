-- Title: D3 Basketball Database
-- Authors: Aidan Von Buchwaldt, Basil Shevtsov, and Jai Deshpande

-- VerifyPoints Procedure
DROP PROCEDURE IF EXISTS VerifyPoints;
CREATE PROCEDURE VerifyPoints(IN GameID SMALLINT, IN TeamID SMALLINT)
BEGIN
  DECLARE PlayerPoints INT;
  DECLARE TeamTotalPoints INT;
  DECLARE ErrorMsg VARCHAR(255);

  -- Calculate the total points scored by players in the given game
  SELECT SUM(FieldGoalsMade * 2 + ThreePointersMade * 3 + FreeThrowsMade) INTO PlayerPoints
  FROM PlayerGameStatistic
  WHERE GameID = GameID AND PlayerID IN (SELECT PlayerID FROM Player WHERE TeamID = TeamID) LIMIT 1;

  -- Fetch the team's recorded total points from the game's stats
  SELECT TotalPoints INTO TeamTotalPoints
  FROM TeamGameStatistic
  WHERE GameID = GameID AND TeamID = TeamID LIMIT 1;

  -- Compare the points
  IF PlayerPoints IS NULL THEN
    SET PlayerPoints = 0;
  END IF;

  IF TeamTotalPoints IS NULL THEN
    SET ErrorMsg = CONCAT('No team total points found for TeamID: ', TeamID, ' and GameID: ', GameID);
    SELECT ErrorMsg AS Error;
  ELSE
    IF PlayerPoints != TeamTotalPoints THEN
      SET ErrorMsg = CONCAT('Mismatch in points! Player total: ', PlayerPoints, ' vs Team total: ', TeamTotalPoints);
      SELECT ErrorMsg AS Error;
    ELSE
      SELECT 'Points are consistent!' AS Message;
    END IF;
  END IF;
END;


-- Insert Player Procedure
DROP PROCEDURE IF EXISTS NewPlayer;
CREATE PROCEDURE NewPlayer(
    IN p_FirstName VARCHAR(40),
    IN p_LastName VARCHAR(40),
    IN p_TeamID SMALLINT,
    IN p_Position VARCHAR(30),
    IN p_HeightInches TINYINT,
    IN p_Weight SMALLINT,
    IN p_HighSchool VARCHAR(40)
)
BEGIN
    INSERT INTO Player (FirstName, LastName, TeamID, Position, HeightInches, Weight, HighSchool)
    VALUES (p_FirstName, p_LastName, p_TeamID, p_Position, p_HeightInches, p_Weight, p_HighSchool);
END;


-- Delete Player Procedure
DROP PROCEDURE IF EXISTS DeletePlayer;
CREATE PROCEDURE DeletePlayer(
    IN p_PlayerID SMALLINT
)
BEGIN
    DELETE FROM Player
    WHERE PlayerID = p_PlayerID;
END;


-- Update Player Procedure
DROP PROCEDURE IF EXISTS UpdatePlayer;
CREATE PROCEDURE UpdatePlayer(
    IN p_PlayerID SMALLINT,
    IN p_FirstName VARCHAR(40),
    IN p_LastName VARCHAR(40),
    IN p_TeamID SMALLINT,
    IN p_Position VARCHAR(30),
    IN p_HeightInches TINYINT,
    IN p_Weight SMALLINT,
    IN p_HighSchool VARCHAR(40)
)
BEGIN
    UPDATE Player
    SET FirstName = p_FirstName,
        LastName = p_LastName,
        TeamID = p_TeamID,
        Position = p_Position,
        HeightInches = p_HeightInches,
        Weight = p_Weight,
        HighSchool = p_HighSchool
    WHERE PlayerID = p_PlayerID;
END;

-- Get Player Stats Procedure
DROP PROCEDURE IF EXISTS GetPlayerStats;
CREATE PROCEDURE GetPlayerStats(
    IN p_PlayerID SMALLINT,
    IN p_GameID SMALLINT
)
BEGIN
    SELECT *
    FROM PlayerGameStatistic
    WHERE PlayerID = p_PlayerID AND GameID = p_GameID;
END;


-- Get Team Stats Procedure
DROP PROCEDURE IF EXISTS GetTeamStats;
CREATE PROCEDURE GetTeamStats(
    IN p_TeamID SMALLINT,
    IN p_GameID SMALLINT
)
BEGIN
    SELECT *
    FROM TeamGameStatistic
    WHERE TeamID = p_TeamID AND GameID = p_GameID;
END;

