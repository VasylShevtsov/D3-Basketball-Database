-- Title: D3 Basketball Database
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

-- Calculate Player Impact Estimate (PIE) for a given game
-- Formula: (PTS + FGM + FTM - FGA - FTA + DREB + (.5 * OREB) + AST + STL + (.5 * BLK) - PF - TO) / 
-- (GmPTS + GmFGM + GmFTM - GmFGA - GmFTA + GmDREB + (.5 * GmOREB) + GmAST + GmSTL + (.5 * GmBLK) - GmPF - GmTO)
-- See NBAstuffer for PIE description: https://www.nbastuffer.com/analytics101/player-impact-estimate-pie/
-- To clarify the abbreviations, paste into ChatGPT and ask for the full terms, it's too long to include here
DROP PROCEDURE IF EXISTS CalculatePlayerPIE;
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
END



-- Calculate Player Impact Estimate (PIE) for a given season
DROP PROCEDURE IF EXISTS CalculateSeasonPlayerPIE;
CREATE PROCEDURE CalculateSeasonPlayerPIE(
    IN p_PlayerID SMALLINT,
    IN p_StartYear INT
)
BEGIN
    -- Temporary table to store individual game PIE values
    CREATE TEMPORARY TABLE IF NOT EXISTS TempPIE (GamePIE DOUBLE);

    -- Find all relevant games within the academic year
    DECLARE cur CURSOR FOR
        SELECT GameID 
        FROM Game
        WHERE (MONTH(Date) >= 9 AND YEAR(Date) = p_StartYear) OR (MONTH(Date) <= 5 AND YEAR(Date) = p_StartYear + 1);
    
    DECLARE v_GameID SMALLINT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    game_loop: LOOP
        FETCH cur INTO v_GameID;
        IF done THEN
            LEAVE game_loop;
        END IF;

        -- Calculate PIE for each game and store in the temporary table
        INSERT INTO TempPIE (GamePIE)
        SELECT player_stats / total_game_stats AS PlayerImpactEstimate
        FROM (
            SELECT 
                (Points + FieldGoalsMade + FreeThrowsMade - FieldGoalsAttempted - FreeThrowsAttempted +
                DefensiveRebounds + (OffensiveRebounds/2) + Assists + Steals + (Blocks/2) - 
                PersonalFouls - Turnovers) AS player_stats,
                (SUM(TotalPoints) + SUM(FieldGoalsMade) + SUM(FreeThrowsMade) - SUM(FieldGoalsAttempted) - SUM(FreeThrowsAttempted) +
                SUM(DefensiveRebounds) + (SUM(OffensiveRebounds)/2) + SUM(Assists) + SUM(Steals) + 
                (SUM(Blocks)/2) - SUM(PersonalFouls) - SUM(Turnovers)) AS total_game_stats
            FROM PlayerGameStatistic
            JOIN TeamGameStatistic USING (GameID)
            WHERE PlayerID = p_PlayerID AND GameID = v_GameID
            GROUP BY GameID
        ) AS GameStats
        WHERE total_game_stats != 0;

    END LOOP;
    CLOSE cur;

    SELECT AVG(GamePIE) AS SeasonPlayerImpactEstimate FROM TempPIE;
    DROP TABLE TempPIE;
END;


-- Custom formula to find the impact of a player on their team's performance in a given season
-- The impact is measured by the player's scoring performance in games where the team won
-- We are looking at how often the team wins when a player scores above their average.
-- Returns the winning percentage when the player scores above their average for the season
DROP PROCEDURE IF EXISTS GetPlayerSuccessImpact;
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
        AVG(Points) INTO avg_points,
        COUNT(*) INTO games_played
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
END


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