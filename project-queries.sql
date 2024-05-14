-- Title: D3 Basketball Database
-- File: Project Queries
-- Authors: Aidan Von Buchwaldt, Basil Shevtsov, and Jai Deshpande
-- Sources:
    -- MySQL Error Handling: 
        -- https://www.mysqltutorial.org/mysql-stored-procedure/mysql-declare-handler/
        -- https://www.tutorialspoint.com/mysql/mysql_declare_handler_statement.htm
    -- MySQL SIGNAL statement:
        -- https://www.tutorialspoint.com/How-can-we-use-SIGNAL-statement-with-MySQL-triggers
    -- Basketball efficiency rating: https://en.wikipedia.org/wiki/Efficiency_(basketball)
    -- Player Impact Estimate (PIE): https://www.nbastuffer.com/analytics101/player-impact-estimate-pie/
    -- NBA terminology glossary: https://www.nba.com/stats/help/glossary

DELIMITER $$

-- Insert Player Procedure
DROP PROCEDURE IF EXISTS NewPlayer$$
CREATE PROCEDURE NewPlayer(
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
    INSERT INTO Player (PlayerID, FirstName, LastName, TeamID, Position, HeightInches, Weight, HighSchool)
    VALUES (p_PlayerID, p_FirstName, p_LastName, p_TeamID, p_Position, p_HeightInches, p_Weight, p_HighSchool);
END $$ 


-- Delete Player Procedure
DROP PROCEDURE IF EXISTS DeletePlayer$$
CREATE PROCEDURE DeletePlayer(
    IN p_PlayerID SMALLINT
)
BEGIN
    DELETE FROM Player
    WHERE PlayerID = p_PlayerID;
END $$ 

-- Delete Team Procedure
DROP PROCEDURE IF EXISTS DeleteTeam$$
CREATE PROCEDURE DeleteTeam(
    IN p_TeamID SMALLINT
)
BEGIN
    DELETE FROM Team
    WHERE TeamID = p_TeamID;
END $$

-- Delete Game Procedure
DROP PROCEDURE IF EXISTS DeleteGame$$
CREATE PROCEDURE DeleteGame(
    IN p_GameID SMALLINT
)
BEGIN
    DELETE FROM Game
    WHERE GameID = p_GameID;
END $$

-- Update Player Procedure
DROP PROCEDURE IF EXISTS UpdatePlayer$$
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
END $$ 


-- Get Player Stats From Specific Game Procedure
DROP PROCEDURE IF EXISTS GetPlayerStats$$
CREATE PROCEDURE GetPlayerStats(
    IN p_PlayerID SMALLINT,
    IN p_GameID SMALLINT
)
BEGIN
    SELECT *
    FROM PlayerGameStatistic
    WHERE PlayerID = p_PlayerID AND GameID = p_GameID;
END $$ 


-- Get Team Stats From Specific Game Procedure
DROP PROCEDURE IF EXISTS GetTeamStats$$
CREATE PROCEDURE GetTeamStats(
    IN p_TeamID SMALLINT,
    IN p_GameID SMALLINT
)
BEGIN
    SELECT *
    FROM TeamGameStatistic
    WHERE TeamID = p_TeamID AND GameID = p_GameID;
END $$ 


-- Get Both Teams Stats From Specific Game Procedure
DROP PROCEDURE IF EXISTS GetBothTeamStats$$
CREATE PROCEDURE GetBothTeamStats(
    IN p_GameID SMALLINT
)
BEGIN
    SELECT t.TeamName, tg.*
    FROM TeamGameStatistic tg
    JOIN Team t ON tg.TeamID = t.TeamID
    WHERE tg.GameID = p_GameID;
END $$ 


-- Get Player's Season Averages Procedure for Academic Year (using the start year)
DROP PROCEDURE IF EXISTS GetPlayerSeasonAverages$$
CREATE PROCEDURE GetPlayerSeasonAverages(
    IN p_PlayerID SMALLINT,
    IN p_StartYear INT
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
END $$ 


-- Get Player's Averages Between Specific Dates Procedure
DROP PROCEDURE IF EXISTS GetPlayerAveragesBetweenDates$$
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
    END IF;
END $$ 


-- Get All Games Played By a Team Procedure
DROP PROCEDURE IF EXISTS GetTeamGameHistory$$
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
END $$ 

-- Get Team Season Statistics Procedure
DROP PROCEDURE IF EXISTS GetTeamSeasonStatistics$$
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
    FROM TeamGameStatistic
    JOIN Game ON TeamGameStatistic.GameID = Game.GameID
    WHERE TeamID = p_TeamID AND (
        (MONTH(Game.Date) >= 9 AND YEAR(Game.Date) = p_StartYear) OR
        (MONTH(Game.Date) <= 5 AND YEAR(Game.Date) = p_StartYear + 1)
    );
END $$

-- Get Team Statistics Between Dates 
DROP PROCEDURE IF EXISTS GetTeamStatisticsBetweenDates$$
CREATE PROCEDURE GetTeamStatisticsBetweenDates(
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
END $$ 

-- Get Two Player's Season Averages for Academic Year (using the start year)
DROP PROCEDURE IF EXISTS ComparePlayersSeasonAverages$$
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
END $$ 


-- Finds the MVP of the Season for the Academic Year (using start year)
DROP PROCEDURE IF EXISTS MVPofTheSeason$$
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
END $$ 

-- Find the efficiency rating of a player for an academic year
-- Formula: (PTS + REB + AST + STL + BLK − Missed FG − Missed FT - TO) / GP
-- See Wikipedia page for efficiency ratings: https://en.wikipedia.org/wiki/Efficiency_(basketball)
DROP PROCEDURE IF EXISTS TrackPlayerEfficiency$$
CREATE PROCEDURE TrackPlayerEfficiency(IN p_PlayerID SMALLINT, IN p_StartYear INT)
BEGIN
    SELECT 
        CONCAT(p_StartYear, '-', p_StartYear + 1) AS Season,
        SUM(
            pgs.Points + pgs.Rebounds + pgs.Assists + pgs.Steals + pgs.Blocks 
            - (pgs.FieldGoalsAttempted - pgs.FieldGoalsMade)
            - (pgs.FreeThrowsAttempted - pgs.FreeThrowsMade)
            - pgs.Turnovers
        ) / COUNT(pgs.GameID) AS EfficiencyRating
    FROM PlayerGameStatistic pgs
    JOIN Game g ON pgs.GameID = g.GameID
    WHERE pgs.PlayerID = p_PlayerID AND (
        (MONTH(g.Date) >= 9 AND YEAR(g.Date) = p_StartYear) OR
        (MONTH(g.Date) <= 5 AND YEAR(g.Date) = p_StartYear + 1)
    )
    GROUP BY CONCAT(p_StartYear, '-', p_StartYear + 1);
END $$ 


-- Calculate Player Impact Estimate (PIE) for a given game
-- Formula: (PTS + FGM + FTM - FGA - FTA + DREB + (.5 * OREB) + AST + STL + (.5 * BLK) - PF - TO) / 
-- (GmPTS + GmFGM + GmFTM - GmFGA - GmFTA + GmDREB + (.5 * GmOREB) + GmAST + GmSTL + (.5 * GmBLK) - GmPF - GmTO)
-- See NBAstuffer for PIE description: https://www.nbastuffer.com/analytics101/player-impact-estimate-pie/
-- To clarify the abbreviations, paste into ChatGPT and ask for the full terms, it's too long to include here
DROP PROCEDURE IF EXISTS CalculatePlayerPIE$$
CREATE PROCEDURE CalculatePlayerPIE(IN player_id SMALLINT, IN game_id SMALLINT)
BEGIN
    DECLARE total_game_stats DOUBLE;
    DECLARE player_stats DOUBLE;

    -- Calculate player's statistics
    SELECT 
        (Points + FieldGoalsMade + FreeThrowsMade - FieldGoalsAttempted - FreeThrowsAttempted +
        DefensiveRebounds + (OffensiveRebounds/2) + Assists + Steals + (Blocks/2) - 
        PersonalFouls - Turnovers) INTO player_stats
    FROM PlayerGameStatistic
    WHERE PlayerID = player_id AND GameID = game_id;
    
    -- Calculate total game statistics (summing stats from both teams)
    SELECT 
        (SUM(TotalPoints) + SUM(FieldGoalsMade) + SUM(FreeThrowsMade) - SUM(FieldGoalsAttempted) - SUM(FreeThrowsAttempted) +
        SUM(DefensiveRebounds) + (SUM(OffensiveRebounds)/2) + SUM(Assists) + SUM(Steals) + 
        (SUM(Blocks)/2) - SUM(PersonalFouls) - SUM(Turnovers)) INTO total_game_stats
    FROM TeamGameStatistic
    WHERE GameID = game_id;

    IF total_game_stats = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game statistics cannot be zero.';
    ELSE
        SELECT player_stats / total_game_stats AS PlayerImpactEstimate;
    END IF;
END $$



-- Calculate Player Impact Estimate (PIE) for a given season
DROP PROCEDURE IF EXISTS CalculateSeasonPlayerPIE$$
CREATE PROCEDURE CalculateSeasonPlayerPIE(
    IN p_PlayerID SMALLINT,
    IN p_StartYear INT
)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS TempPIE;
    CREATE TEMPORARY TABLE TempPIE (GamePIE DOUBLE);

    INSERT INTO TempPIE (GamePIE)
    SELECT player_stats / total_game_stats AS PlayerImpactEstimate
    FROM (
        SELECT 
            pgs.GameID,
            (pgs.Points + pgs.FieldGoalsMade + pgs.FreeThrowsMade - pgs.FieldGoalsAttempted - pgs.FreeThrowsAttempted +
            pgs.DefensiveRebounds + (pgs.OffensiveRebounds / 2) + pgs.Assists + pgs.Steals + (pgs.Blocks / 2) - 
            pgs.PersonalFouls - pgs.Turnovers) AS player_stats,
            (SUM(tgs.TotalPoints) + SUM(tgs.FieldGoalsMade) + SUM(tgs.FreeThrowsMade) - SUM(tgs.FieldGoalsAttempted) - SUM(tgs.FreeThrowsAttempted) +
            SUM(tgs.DefensiveRebounds) + (SUM(tgs.OffensiveRebounds) / 2) + SUM(tgs.Assists) + SUM(tgs.Steals) + 
            (SUM(tgs.Blocks) / 2) - SUM(tgs.PersonalFouls) - SUM(tgs.Turnovers)) AS total_game_stats
        FROM PlayerGameStatistic pgs
        JOIN TeamGameStatistic tgs USING (GameID)
        JOIN Game g ON pgs.GameID = g.GameID
        WHERE pgs.PlayerID = p_PlayerID AND (
            (MONTH(g.Date) >= 9 AND YEAR(g.Date) = p_StartYear) OR
            (MONTH(g.Date) <= 5 AND YEAR(g.Date) = p_StartYear + 1)
        )
        GROUP BY pgs.GameID
    ) AS GameStats
    WHERE total_game_stats != 0;

    SELECT AVG(GamePIE) AS SeasonPlayerImpactEstimate FROM TempPIE;
    DROP TEMPORARY TABLE IF EXISTS TempPIE;
END $$


-- Custom formula to find the impact of a player on their team's performance in a given season
-- The impact is measured by the player's scoring performance in games where the team won
-- We are looking at how often the team wins when a player scores above their average.
-- Returns the winning percentage when the player scores above their average for the season
DROP PROCEDURE IF EXISTS GetPlayerSuccessImpact$$
CREATE PROCEDURE GetPlayerSuccessImpact(
    IN p_PlayerID SMALLINT,
    IN p_StartYear INT
)
BEGIN
    DECLARE avg_points DECIMAL(5,2);
    DECLARE games_played INT;
    DECLARE games_won INT;

    -- Calculate average points scored by the player for the given season and the number of games played
    SELECT 
        AVG(Points), COUNT(*) 
        INTO avg_points, games_played
    FROM PlayerGameStatistic
    JOIN Game ON PlayerGameStatistic.GameID = Game.GameID
    WHERE PlayerID = p_PlayerID
        AND (
            (MONTH(Game.Date) >= 9 AND YEAR(Game.Date) = p_StartYear) 
            OR 
            (MONTH(Game.Date) <= 5 AND YEAR(Game.Date) = p_StartYear + 1)
        );

    -- Count games where the player scored above their average and the team won during the season
    SELECT COUNT(*) INTO games_won
    FROM PlayerGameStatistic AS pgs
    JOIN Game AS g ON pgs.GameID = g.GameID
    JOIN TeamGameStatistic AS tgs ON g.GameID = tgs.GameID
    WHERE pgs.PlayerID = p_PlayerID AND pgs.Points > avg_points
            -- check if the player's team won the game
          AND (
              (tgs.TeamID = g.HomeTeamID AND g.HomeTeamID = (SELECT TeamID FROM Player WHERE PlayerID = p_PlayerID) AND tgs.TotalPoints > (SELECT TotalPoints FROM TeamGameStatistic WHERE GameID = g.GameID AND TeamID = g.AwayTeamID))
              OR
              (tgs.TeamID = g.AwayTeamID AND g.AwayTeamID = (SELECT TeamID FROM Player WHERE PlayerID = p_PlayerID) AND tgs.TotalPoints > (SELECT TotalPoints FROM TeamGameStatistic WHERE GameID = g.GameID AND TeamID = g.HomeTeamID))
          )
        AND (
            (MONTH(g.Date) >= 9 AND YEAR(g.Date) = p_StartYear) 
            OR 
            (MONTH(g.Date) <= 5 AND YEAR(g.Date) = p_StartYear + 1)
        );

    -- Calculate the winning percentage when the player scores above their average for the season
    SELECT IF(games_played = 0, NULL, (games_won / games_played) * 100) AS WinningImpactPercentage;
END $$

-- Get Top Scorers From a Specific Game Procedure
DROP PROCEDURE IF EXISTS GetTopScorersInGame$$
CREATE PROCEDURE GetTopScorersInGame(
    IN p_GameID SMALLINT
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
    ORDER BY ps.Points DESC;
END $$ 

-- Retrieve a log of all games played by a specific player
DROP PROCEDURE IF EXISTS GetPlayerGameLog$$
CREATE PROCEDURE GetPlayerGameLog(IN p_PlayerID SMALLINT)
BEGIN
    SELECT 
        p.FirstName,
        p.LastName,
        p.Position,
        g.Date AS GameDate,
        IF(t.TeamID = g.HomeTeamID, 'Home', 'Away') AS HomeOrAway,
        t.TeamName AS TeamPlayedFor,
        pg.FieldGoalsMade,
        pg.FieldGoalsAttempted,
        pg.ThreePointersMade,
        pg.ThreePointersAttempted,
        pg.FreeThrowsMade,
        pg.FreeThrowsAttempted,
        pg.PersonalFouls,
        pg.Rebounds,
        pg.OffensiveRebounds,
        pg.DefensiveRebounds,
        pg.Assists,
        pg.Steals,
        pg.Blocks,
        pg.Turnovers,
        pg.Points AS TotalPoints,
        pg.MinutesPlayed
    FROM PlayerGameStatistic pg
    JOIN Player p ON pg.PlayerID = p.PlayerID
    JOIN Game g ON pg.GameID = g.GameID
    JOIN Team t ON p.TeamID = t.TeamID
    WHERE pg.PlayerID = p_PlayerID
    ORDER BY g.Date DESC;
END $$ 

-- Ranks teams for a given season based on their win-loss record and point differential
DROP PROCEDURE IF EXISTS SeasonalTeamRankingsProcedure$$
CREATE PROCEDURE SeasonalTeamRankingsProcedure(IN p_StartYear INT)
BEGIN
    SELECT 
        t.TeamName,
        COUNT(CASE WHEN (g.HomeTeamID = t.TeamID AND tgs.TotalPoints > ogs.TotalPoints) OR (g.AwayTeamID = t.TeamID AND tgs.TotalPoints > ogs.TotalPoints) THEN 1 END) AS Wins,
        COUNT(CASE WHEN (g.HomeTeamID = t.TeamID AND tgs.TotalPoints < ogs.TotalPoints) OR (g.AwayTeamID = t.TeamID AND tgs.TotalPoints < ogs.TotalPoints) THEN 1 END) AS Losses,
        SUM(tgs.TotalPoints) - SUM(ogs.TotalPoints) AS PointDifferential,
        SUM(tgs.TotalPoints) AS PointsScored,
        SUM(ogs.TotalPoints) AS PointsAllowed
    FROM Team t
    JOIN Game g ON t.TeamID = g.HomeTeamID OR t.TeamID = g.AwayTeamID
    JOIN TeamGameStatistic tgs ON g.GameID = tgs.GameID AND tgs.TeamID = t.TeamID
    JOIN TeamGameStatistic ogs ON g.GameID = ogs.GameID AND ogs.TeamID <> t.TeamID
    WHERE (
            (MONTH(g.Date) >= 9 AND YEAR(g.Date) = p_StartYear) 
            OR 
            (MONTH(g.Date) <= 5 AND YEAR(g.Date) = p_StartYear + 1)
        )
    GROUP BY t.TeamID
    ORDER BY Wins DESC, PointDifferential DESC;
END $$ 

-- Verify Points Procedure
-- Finds if there is a discrepancy between the total points scored by players on a team and the total points recorded for the team in a game
DROP PROCEDURE IF EXISTS VerifyPoints$$
CREATE PROCEDURE VerifyPoints(IN p_GameID SMALLINT, IN p_TeamID SMALLINT)
BEGIN
    DECLARE PlayerPoints INT;
    DECLARE TeamTotalPoints INT;
    DECLARE ErrorMessage VARCHAR(255);

    -- Calculate the total points scored by players in the given game
    SELECT SUM(COALESCE(FieldGoalsMade * 2 + ThreePointersMade * 3 + FreeThrowsMade, 0)) INTO PlayerPoints
    FROM PlayerGameStatistic
    WHERE GameID = p_GameID AND PlayerID IN (SELECT PlayerID FROM Player WHERE TeamID = p_TeamID);

    -- Fetch the team's recorded total points from the game's stats
    SELECT COALESCE(TotalPoints, 0) INTO TeamTotalPoints
    FROM TeamGameStatistic
    WHERE GameID = p_GameID AND TeamID = p_TeamID;

    -- Check for nulls and mismatch
    IF PlayerPoints = 0 THEN
        SET ErrorMessage = CONCAT('Error: Player points total returns zero or null for TeamID: ', p_TeamID, ', GameID: ', p_GameID);
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = ErrorMessage;
    ELSEIF TeamTotalPoints = 0 THEN
        SET ErrorMessage = CONCAT('Error: Team total points return zero or null for TeamID: ', p_TeamID, ', GameID: ', p_GameID);
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = ErrorMessage;
    ELSEIF PlayerPoints != TeamTotalPoints THEN
        SET ErrorMessage = CONCAT('Error: Mismatch in points! Player total: ', PlayerPoints, ' vs Team total: ', TeamTotalPoints);
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = ErrorMessage;
    ELSE
        SELECT 'Points are consistent!' AS Message;
    END IF;
END$$

-- Verify All Stats Procedure
-- Finds discrepancies between all major statistical totals recorded for players and those recorded for their teams in a game
DROP PROCEDURE IF EXISTS VerifyAllStats$$
CREATE PROCEDURE VerifyAllStats(IN p_GameID SMALLINT, IN p_TeamID SMALLINT)
BEGIN
    DECLARE PlayerFGMade, PlayerFGAttempted, Player3PMade, Player3PAttempted, PlayerFTMade, PlayerFTAttempted,
            PlayerFouls, PlayerRebounds, PlayerOffRebounds, PlayerDefRebounds, PlayerAssists, PlayerSteals,
            PlayerBlocks, PlayerTurnovers, PlayerPoints INT DEFAULT 0;

    DECLARE TeamFGMade, TeamFGAttempted, Team3PMade, Team3PAttempted, TeamFTMade, TeamFTAttempted,
            TeamFouls, TeamRebounds, TeamOffRebounds, TeamDefRebounds, TeamAssists, TeamSteals,
            TeamBlocks, TeamTurnovers, TeamPoints INT DEFAULT 0;

    -- Calculate all player stats totals in the given game for the specified team
    SELECT
        SUM(COALESCE(FieldGoalsMade, 0)), SUM(COALESCE(FieldGoalsAttempted, 0)),
        SUM(COALESCE(ThreePointersMade, 0)), SUM(COALESCE(ThreePointersAttempted, 0)),
        SUM(COALESCE(FreeThrowsMade, 0)), SUM(COALESCE(FreeThrowsAttempted, 0)),
        SUM(COALESCE(PersonalFouls, 0)), SUM(COALESCE(Rebounds, 0)),
        SUM(COALESCE(OffensiveRebounds, 0)), SUM(COALESCE(DefensiveRebounds, 0)),
        SUM(COALESCE(Assists, 0)), SUM(COALESCE(Steals, 0)),
        SUM(COALESCE(Blocks, 0)), SUM(COALESCE(Turnovers, 0)),
        SUM(COALESCE(Points, 0))
    INTO
        PlayerFGMade, PlayerFGAttempted, Player3PMade, Player3PAttempted, PlayerFTMade, PlayerFTAttempted,
        PlayerFouls, PlayerRebounds, PlayerOffRebounds, PlayerDefRebounds, PlayerAssists, PlayerSteals,
        PlayerBlocks, PlayerTurnovers, PlayerPoints
    FROM PlayerGameStatistic
    WHERE GameID = p_GameID AND PlayerID IN (SELECT PlayerID FROM Player WHERE TeamID = p_TeamID);

    -- Fetch all team stats totals from the game's statistics
    SELECT
        COALESCE(FieldGoalsMade, 0), COALESCE(FieldGoalsAttempted, 0),
        COALESCE(ThreePointersMade, 0), COALESCE(ThreePointersAttempted, 0),
        COALESCE(FreeThrowsMade, 0), COALESCE(FreeThrowsAttempted, 0),
        COALESCE(PersonalFouls, 0), COALESCE(Rebounds, 0),
        COALESCE(OffensiveRebounds, 0), COALESCE(DefensiveRebounds, 0),
        COALESCE(Assists, 0), COALESCE(Steals, 0),
        COALESCE(Blocks, 0), COALESCE(Turnovers, 0),
        COALESCE(TotalPoints, 0)
    INTO
        TeamFGMade, TeamFGAttempted, Team3PMade, Team3PAttempted, TeamFTMade, TeamFTAttempted,
        TeamFouls, TeamRebounds, TeamOffRebounds, TeamDefRebounds, TeamAssists, TeamSteals,
        TeamBlocks, TeamTurnovers, TeamPoints
    FROM TeamGameStatistic
    WHERE GameID = p_GameID AND TeamID = p_TeamID;

    IF PlayerFGMade != TeamFGMade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Field Goals Made';
    ELSEIF PlayerFGAttempted != TeamFGAttempted THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Field Goals Attempted';
    ELSEIF Player3PMade != Team3PMade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Three Pointers Made';
    ELSEIF Player3PAttempted != Team3PAttempted THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Three Pointers Attempted';
    ELSEIF PlayerFTMade != TeamFTMade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Free Throws Made';
    ELSEIF PlayerFTAttempted != TeamFTAttempted THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Free Throws Attempted';
    ELSEIF PlayerFouls != TeamFouls THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Personal Fouls';
    ELSEIF PlayerRebounds != TeamRebounds THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Total Rebounds';
    ELSEIF PlayerOffRebounds != TeamOffRebounds THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Offensive Rebounds';
    ELSEIF PlayerDefRebounds != TeamDefRebounds THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Defensive Rebounds';
    ELSEIF PlayerAssists != TeamAssists THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Assists';
    ELSEIF PlayerSteals != TeamSteals THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Steals';
    ELSEIF PlayerBlocks != TeamBlocks THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Blocks';
    ELSEIF PlayerTurnovers != TeamTurnovers THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Turnovers';
    ELSEIF PlayerPoints != TeamPoints THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mismatch in Total Points';
    ELSE
        SELECT 'All statistics are consistent!' AS Message;
    END IF;
END $$ 


-- Trigger to log player deletions
DROP TRIGGER IF EXISTS LogDeletePlayer$$
CREATE TRIGGER LogDeletePlayer
AFTER DELETE ON Player
FOR EACH ROW
BEGIN
    INSERT INTO DeletionLog (EntityType, EntityID, DeletedAt, DeletedBy)
    VALUES ('Player', OLD.PlayerID, NOW(), CURRENT_USER());
END $$ 

-- Trigger to log team deletions
DROP TRIGGER IF EXISTS LogDeleteTeam$$
CREATE TRIGGER LogDeleteTeam
AFTER DELETE ON Team
FOR EACH ROW
BEGIN
    INSERT INTO DeletionLog (EntityType, EntityID, DeletedAt, DeletedBy)
    VALUES ('Team', OLD.TeamID, NOW(), CURRENT_USER());
END $$ 

-- Trigger to log game deletions
DROP TRIGGER IF EXISTS LogDeleteGame$$
CREATE TRIGGER LogDeleteGame
AFTER DELETE ON Game
FOR EACH ROW
BEGIN
    INSERT INTO DeletionLog (EntityType, EntityID, DeletedAt, DeletedBy)
    VALUES ('Game', OLD.GameID, NOW(), CURRENT_USER());
END $$ 

-- Trigger to check for any stat discrepancy upon insert of a team game statistic entry
DROP TRIGGER IF EXISTS trg_VerifyStatsAfterInsert$$
CREATE TRIGGER trg_VerifyStatsAfterInsert
AFTER INSERT ON TeamGameStatistic
FOR EACH ROW
BEGIN
    CALL VerifyAllStats(NEW.GameID, NEW.TeamID);
END $$ 

DELIMITER ;