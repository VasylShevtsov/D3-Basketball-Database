-- Title: D3 Basketball Database
-- Authors: Aidan Von Buchwaldt, Basil Shevtsov, and Jai Deshpande
-- Sources:
    -- MySQL Error Handling: 
        -- https://www.mysqltutorial.org/mysql-stored-procedure/mysql-declare-handler/
        -- https://www.tutorialspoint.com/mysql/mysql_declare_handler_statement.htm
    -- MySQL SIGNAL statement:
        -- https://www.tutorialspoint.com/How-can-we-use-SIGNAL-statement-with-MySQL-triggers
    -- Basketball efficiency rating: https://en.wikipedia.org/wiki/Efficiency_(basketball)


-- Verify Points Procedure
-- Finds if there is a discrepancy between the total points scored by players on a team and the total points recorded for the team in a game
DROP PROCEDURE IF EXISTS VerifyPoints;
CREATE PROCEDURE VerifyPoints(IN p_GameID SMALLINT, IN p_TeamID SMALLINT)
BEGIN
    DECLARE PlayerTotalPoints INT;
    DECLARE TeamTotalPoints INT;
    DECLARE ErrorMsg VARCHAR(255);

    -- Calculate the total points scored by players in the given game
    SELECT SUM(COALESCE(FieldGoalsMade * 2 + ThreePointersMade * 3 + FreeThrowsMade, 0)) INTO PlayerPoints
    FROM PlayerGameStatistic
    WHERE GameID = p_GameID AND PlayerID IN (SELECT PlayerID FROM Player WHERE TeamID = p_TeamID);

    -- Fetch the team's recorded total points from the game's stats
    SELECT TotalPoints INTO TeamTotalPoints
    FROM TeamGameStatistic
    WHERE GameID = p_GameID AND TeamID = p_TeamID;

    -- Compare the points
    IF PlayerPoints IS NULL THEN
        SET ErrorMsg = CONCAT('Error: Player points total returns null for TeamID: ', p_TeamID, ' and GameID: ', p_GameID);
        SELECT ErrorMsg AS Error;
    END IF;

    IF TeamTotalPoints IS NULL THEN
        SET ErrorMsg = CONCAT('Error: TeamTotalPoints returns null for TeamID: ', p_TeamID, ' and GameID: ', p_GameID);
        SELECT ErrorMsg AS Error;
    ELSE
        IF PlayerPoints != TeamTotalPoints THEN
            SET ErrorMsg = CONCAT('Error: Mismatch in points! Player total: ', PlayerPoints, ' vs Team total: ', TeamTotalPoints);
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
    -- Error handling to manage cases where the insert might fail
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- Get error details
        GET DIAGNOSTICS CONDITION 1 
            @sql_state = RETURNED_SQLSTATE, @err_no = MYSQL_ERRNO, @msg_text = MESSAGE_TEXT;
        -- Make the error message
        SET @full_error = CONCAT('Error ', @err_no, ' (SQLState ', @sql_state, '): ', @msg_text);
        -- Return the error message
        SELECT @full_error AS Error_Message;
    END;

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
    DECLARE affected_rows INT;

    UPDATE Player
    SET FirstName = p_FirstName,
        LastName = p_LastName,
        TeamID = p_TeamID,
        Position = p_Position,
        HeightInches = p_HeightInches,
        Weight = p_Weight,
        HighSchool = p_HighSchool
    WHERE PlayerID = p_PlayerID;

    -- Check for the number of rows affected by the update, and give feedback on the result of the operation
    SET affected_rows = ROW_COUNT(); -- ROW_COUNT() returns the number of rows affected by the last statement (it should be just one row in this case)

    IF affected_rows = 0 THEN
        SELECT 'No player updated. Check if PlayerID exists.' AS Message;
    ELSE
        SELECT CONCAT('Updated ', affected_rows, ' player(s).') AS Message;
    END IF;
END;


-- Get Player Stats From Specific Game Procedure
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


-- Get Team Stats From Specific Game Procedure
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


-- Get Both Teams Stats From Specific Game Procedure
DROP PROCEDURE IF EXISTS GetBothTeamStats;
CREATE PROCEDURE GetBothTeamStats(
    IN p_GameID SMALLINT
)
BEGIN
    SELECT t.TeamName, tg.*
    FROM TeamGameStatistic tg
    JOIN Team t ON tg.TeamID = t.TeamID
    WHERE tg.GameID = p_GameID;
END;


-- Get Player's Season Averages Procedure for Academic Year (using the start year)
DROP PROCEDURE IF EXISTS GetPlayerSeasonAverages;
CREATE PROCEDURE GetPlayerSeasonAverages(
    IN p_StartYear INT,
    IN p_PlayerID SMALLINT
)
BEGIN
    SELECT 
        ROUND(AVG(FieldGoalsMade), 2) AS AvgFieldGoalsMade,
        ROUND(AVG(FieldGoalsAttempted), 2) AS AvgFieldGoalsAttempted,
        ROUND(AVG(ThreePointersMade), 2) AS AvgThreePointersMade,
        ROUND(AVG(ThreePointersAttempted), 2) AS AvgThreePointersAttempted,
        ROUND(AVG(FreeThrowsMade), 2) AS AvgFreeThrowsMade,
        ROUND(AVG(FreeThrowsAttempted), 2) AS AvgFreeThrowsAttempted,
        ROUND(AVG(PersonalFouls), 2) AS AvgPersonalFouls,
        ROUND(AVG(Rebounds), 2) AS AvgRebounds,
        ROUND(AVG(OffensiveRebounds), 2) AS AvgOffensiveRebounds,
        ROUND(AVG(DefensiveRebounds), 2) AS AvgDefensiveRebounds,
        ROUND(AVG(Assists), 2) AS AvgAssists,
        ROUND(AVG(Steals), 2) AS AvgSteals,
        ROUND(AVG(Blocks), 2) AS AvgBlocks,
        ROUND(AVG(Turnovers), 2) AS AvgTurnovers,
        ROUND(AVG(Points), 2) AS AvgPoints,
        ROUND(AVG(MinutesPlayed), 2) AS AvgMinutesPlayed
    FROM PlayerGameStatistic
    JOIN Game ON PlayerGameStatistic.GameID = Game.GameID
    WHERE PlayerID = p_PlayerID 
        AND (
            (MONTH(Game.Date) >= 9 AND YEAR(Game.Date) = p_StartYear) 
            OR 
            (MONTH(Game.Date) <= 5 AND YEAR(Game.Date) = p_StartYear + 1)
        );
END;


-- Get Player's Averages Between Specific Dates Procedure
DROP PROCEDURE IF EXISTS GetPlayerAveragesBetweenDates;
CREATE PROCEDURE GetPlayerAveragesBetweenDates(
    IN p_PlayerID SMALLINT,
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    IF p_StartDate > p_EndDate THEN
        SIGNAL SQLSTATE '45000' -- custom error handling in case dates are invalid
        SET MESSAGE_TEXT = 'Start date must be before end date.';
    ELSE
    SELECT 
        p_PlayerID AS PlayerID,
        ROUND(AVG(FieldGoalsMade), 2) AS AvgFieldGoalsMade,
        ROUND(AVG(FieldGoalsAttempted), 2) AS AvgFieldGoalsAttempted,
        ROUND(AVG(ThreePointersMade), 2) AS AvgThreePointersMade,
        ROUND(AVG(ThreePointersAttempted), 2) AS AvgThreePointersAttempted,
        ROUND(AVG(FreeThrowsMade), 2) AS AvgFreeThrowsMade,
        ROUND(AVG(FreeThrowsAttempted), 2) AS AvgFreeThrowsAttempted,
        ROUND(AVG(PersonalFouls), 2) AS AvgPersonalFouls,
        ROUND(AVG(Rebounds), 2) AS AvgRebounds,
        ROUND(AVG(OffensiveRebounds), 2) AS AvgOffensiveRebounds,
        ROUND(AVG(DefensiveRebounds), 2) AS AvgDefensiveRebounds,
        ROUND(AVG(Assists), 2) AS AvgAssists,
        ROUND(AVG(Steals), 2) AS AvgSteals,
        ROUND(AVG(Blocks), 2) AS AvgBlocks,
        ROUND(AVG(Turnovers), 2) AS AvgTurnovers,
        ROUND(AVG(Points), 2) AS AvgPoints,
        ROUND(AVG(MinutesPlayed), 2) AS AvgMinutesPlayed
    FROM PlayerGameStatistic
    JOIN Game ON PlayerGameStatistic.GameID = Game.GameID
    WHERE PlayerID = p_PlayerID 
        AND Game.Date BETWEEN p_StartDate AND p_EndDate;
END;


-- Get All Games Played By a Team Procedure
DROP PROCEDURE IF EXISTS GetTeamGameHistory;
CREATE PROCEDURE GetTeamGameHistory(
    IN p_TeamID SMALLINT
)
BEGIN
    SELECT 
        g.GameID,
        g.Date,
        CASE -- conditional to determine the opponent based on whether the team was home or away
            WHEN tg.HomeOrAway = 'Home' THEN at.TeamName
            ELSE ht.TeamName
        END AS Opponent,
        tg.HomeOrAway,
        tg.TotalPoints
    FROM TeamGameStatistic tg
    JOIN Game g ON tg.GameID = g.GameID
    JOIN Team ht ON g.HomeTeamID = ht.TeamID -- Home team
    JOIN Team at ON g.AwayTeamID = at.TeamID -- Away team
    WHERE tg.TeamID = p_TeamID
    ORDER BY g.Date;
END;

-- Get Team Season Statistics Procedure
DROP PROCEDURE IF EXISTS GetTeamSeasonStatistics;
CREATE PROCEDURE GetTeamSeasonStatistics(IN p_TeamID SMALLINT, IN p_StartYear INT)
BEGIN
    SELECT 
        ROUND(AVG(FieldGoalsMade), 2) AS AvgFieldGoalsMade,
        ROUND(AVG(FieldGoalsAttempted), 2) AS AvgFieldGoalsAttempted,
        ROUND(AVG(ThreePointersMade), 2) AS AvgThreePointersMade,
        ROUND(AVG(ThreePointersAttempted), 2) AS AvgThreePointersAttempted,
        ROUND(AVG(FreeThrowsMade), 2) AS AvgFreeThrowsMade,
        ROUND(AVG(FreeThrowsAttempted), 2) AS AvgFreeThrowsAttempted,
        ROUND(AVG(PersonalFouls), 2) AS AvgPersonalFouls,
        ROUND(AVG(Rebounds), 2) AS AvgRebounds,
        ROUND(AVG(OffensiveRebounds), 2) AS AvgOffensiveRebounds,
        ROUND(AVG(DefensiveRebounds), 2) AS AvgDefensiveRebounds,
        ROUND(AVG(Assists), 2) AS AvgAssists,
        ROUND(AVG(Steals), 2) AS AvgSteals,
        ROUND(AVG(Blocks), 2) AS AvgBlocks,
        ROUND(AVG(Turnovers), 2) AS AvgTurnovers,
        ROUND(AVG(TotalPoints), 2) AS AvgTotalPoints
    JOIN Game ON TeamGameStatistic.GameID = Game.GameID
    WHERE TeamID = p_TeamID AND (
        (MONTH(Game.Date) >= 9 AND YEAR(Game.Date) = p_StartYear) OR
        (MONTH(Game.Date) <= 5 AND YEAR(Game.Date) = p_StartYear + 1)
    );
END;

-- Get Team Season Statistics Procedure with Date Range
DROP PROCEDURE IF EXISTS GetTeamSeasonStatisticsBetweenDates;
CREATE PROCEDURE GetTeamSeasonStatisticsBetweenDates(
    IN p_TeamID SMALLINT,
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    -- Error handling for invalid date range
    IF p_StartDate > p_EndDate THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start date must be before end date.';
    ELSE
        SELECT 
            ROUND(AVG(FieldGoalsMade), 2) AS AvgFieldGoalsMade,
            ROUND(AVG(FieldGoalsAttempted), 2) AS AvgFieldGoalsAttempted,
            ROUND(AVG(ThreePointersMade), 2) AS AvgThreePointersMade,
            ROUND(AVG(ThreePointersAttempted), 2) AS AvgThreePointersAttempted,
            ROUND(AVG(FreeThrowsMade), 2) AS AvgFreeThrowsMade,
            ROUND(AVG(FreeThrowsAttempted), 2) AS AvgFreeThrowsAttempted,
            ROUND(AVG(PersonalFouls), 2) AS AvgPersonalFouls,
            ROUND(AVG(Rebounds), 2) AS AvgRebounds,
            ROUND(AVG(OffensiveRebounds), 2) AS AvgOffensiveRebounds,
            ROUND(AVG(DefensiveRebounds), 2) AS AvgDefensiveRebounds,
            ROUND(AVG(Assists), 2) AS AvgAssists,
            ROUND(AVG(Steals), 2) AS AvgSteals,
            ROUND(AVG(Blocks), 2) AS AvgBlocks,
            ROUND(AVG(Turnovers), 2) AS AvgTurnovers,
            ROUND(AVG(TotalPoints), 2) AS AvgTotalPoints
        FROM TeamGameStatistic
        JOIN Game ON TeamGameStatistic.GameID = Game.GameID
        WHERE TeamID = p_TeamID AND Game.Date BETWEEN p_StartDate AND p_EndDate;
    END IF;
END;

-- Get Two Player's Season Averages for Academic Year (using the start year)
DROP PROCEDURE IF EXISTS ComparePlayersSeasonAverages;
CREATE PROCEDURE ComparePlayersSeasonAverages(IN p_PlayerID1 SMALLINT, IN p_PlayerID2 SMALLINT, IN p_StartYear INT)
BEGIN
    SELECT 
        PlayerID,
        ROUND(AVG(FieldGoalsMade), 2) AS AvgFieldGoalsMade,
        ROUND(AVG(FieldGoalsAttempted), 2) AS AvgFieldGoalsAttempted,
        ROUND(AVG(ThreePointersMade), 2) AS AvgThreePointersMade,
        ROUND(AVG(ThreePointersAttempted), 2) AS AvgThreePointersAttempted,
        ROUND(AVG(FreeThrowsMade), 2) AS AvgFreeThrowsMade,
        ROUND(AVG(FreeThrowsAttempted), 2) AS AvgFreeThrowsAttempted,
        ROUND(AVG(PersonalFouls), 2) AS AvgPersonalFouls,
        ROUND(AVG(Rebounds), 2) AS AvgRebounds,
        ROUND(AVG(OffensiveRebounds), 2) AS AvgOffensiveRebounds,
        ROUND(AVG(DefensiveRebounds), 2) AS AvgDefensiveRebounds,
        ROUND(AVG(Assists), 2) AS AvgAssists,
        ROUND(AVG(Steals), 2) AS AvgSteals,
        ROUND(AVG(Blocks), 2) AS AvgBlocks,
        ROUND(AVG(Turnovers), 2) AS AvgTurnovers,
        ROUND(AVG(Points), 2) AS AvgPoints,
        ROUND(AVG(MinutesPlayed), 2) AS AvgMinutesPlayed
    FROM PlayerGameStatistic
    JOIN Game ON PlayerGameStatistic.GameID = Game.GameID
    WHERE PlayerID IN (p_PlayerID1, p_PlayerID2) AND (
        (MONTH(Game.Date) >= 9 AND YEAR(Game.Date) = p_StartYear) OR
        (MONTH(Game.Date) <= 5 AND YEAR(Game.Date) = p_StartYear + 1)
    )
    GROUP BY PlayerID;
END;


-- Finds the MVP of the Season for the Academic Year (using start year)
DROP PROCEDURE IF EXISTS MVPofTheSeason;
CREATE PROCEDURE MVPofTheSeason(IN p_SeasonStartYear INT)
BEGIN
    SELECT 
        PlayerID,
        SUM(Points) AS TotalPoints,
        SUM(Assists) AS TotalAssists,
        SUM(Rebounds) AS TotalRebounds,
        SUM(Steals) AS TotalSteals,
        SUM(Blocks) AS TotalBlocks
    FROM PlayerGameStatistic
    JOIN Game ON PlayerGameStatistic.GameID = Game.GameID
    WHERE 
        (MONTH(Game.Date) >= 9 AND YEAR(Game.Date) = p_SeasonStartYear) OR 
        (MONTH(Game.Date) <= 5 AND YEAR(Game.Date) = p_SeasonStartYear + 1)
    GROUP BY PlayerID
    ORDER BY TotalPoints DESC, TotalAssists DESC, TotalRebounds DESC, TotalSteals DESC, TotalBlocks DESC
    LIMIT 5;
END;

-- Find the efficiency rating of a player for an academic year
-- Formula: (PTS + REB + AST + STL + BLK − Missed FG − Missed FT - TO) / GP
-- See Wikipedia page for efficiency ratings: https://en.wikipedia.org/wiki/Efficiency_(basketball)
DROP PROCEDURE IF EXISTS TrackPlayerEfficiency;
CREATE PROCEDURE TrackPlayerEfficiency(IN p_PlayerID SMALLINT, IN p_StartYear INT)
BEGIN
    SELECT 
        CONCAT(p_StartYear, '-', p_StartYear + 1) AS Season,
        SUM(
            Points + Rebounds + Assists + Steals + Blocks 
            - (FieldGoalsAttempted - FieldGoalsMade)
            - (FreeThrowsAttempted - FreeThrowsMade)
            - Turnovers
        ) / COUNT(GameID) AS EfficiencyRating
    FROM PlayerGameStatistic
    JOIN Game ON PlayerGameStatistic.GameID = Game.GameID
    WHERE PlayerID = p_PlayerID AND (
        (MONTH(Game.Date) >= 9 AND YEAR(Game.Date) = p_StartYear) OR
        (MONTH(Game.Date) <= 5 AND YEAR(Game.Date) = p_StartYear + 1)
    )
    GROUP BY CONCAT(p_StartYear, '-', p_StartYear + 1);
END;




-- Finds the impact of a player on their team's performance
DROP PROCEDURE IF EXISTS AnalyzeTeamImpact;
CREATE PROCEDURE AnalyzeTeamImpact(IN p_PlayerID SMALLINT, IN p_SeasonYear INT)
BEGIN
    SELECT 
        GameID,
        IF(PlayerID = p_PlayerID, 'Played', 'Not Played') AS PlayerParticipation,
        SUM(TotalPoints) OVER (PARTITION BY GameID) AS TeamPointsWithPlayer,
        AVG(TotalPoints) OVER (PARTITION BY PlayerParticipation) AS AvgTeamPoints
    FROM TeamGameStatistic
    JOIN Game ON TeamGameStatistic.GameID = Game.GameID
    LEFT JOIN PlayerGameStatistic ON TeamGameStatistic.GameID = PlayerGameStatistic.GameID AND PlayerGameStatistic.PlayerID = p_PlayerID
    WHERE YEAR(Game.Date) = p_SeasonYear;
END;


-- Finds the optimal roster for a given game
DROP PROCEDURE IF EXISTS OptimizeRoster;
CREATE PROCEDURE OptimizeRoster(IN p_GameID SMALLINT)
BEGIN
    SELECT 
        tg.TeamID,
        p.PlayerID,
        SUM(ps.Points + ps.Assists + ps.Rebounds + ps.Steals + ps.Blocks - ps.Turnovers) AS ContributionScore
    FROM PlayerGameStatistic ps
    JOIN Player p ON ps.PlayerID = p.PlayerID
    JOIN TeamGameStatistic tg ON ps.GameID = tg.GameID AND p.TeamID = tg.TeamID
    WHERE ps.GameID = p_GameID
    GROUP BY tg.TeamID, p.PlayerID
    ORDER BY ContributionScore DESC;
END;

-- Get Top Scorers From a Specific Game Procedure
DROP PROCEDURE IF EXISTS GetTopScorersInGame;
CREATE PROCEDURE GetTopScorersInGame(
    IN p_GameID SMALLINT,
    IN p_Limit INT DEFAULT 5
)
BEGIN
    SELECT 
        p.PlayerID,
        p.FirstName,
        p.LastName,
        ps.Points
    FROM PlayerGameStatistic ps
    JOIN Player p ON ps.PlayerID = p.PlayerID
    WHERE ps.GameID = p_GameID
    ORDER BY ps.Points DESC
    LIMIT p_Limit;
END;