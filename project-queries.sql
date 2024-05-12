-- Title: D3 Basketball Database
-- Authors: Aidan Von Buchwaldt, Basil Shevtsov, and Jai Deshpande


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
    SELECT 
        tg.TeamID,
        tg.HomeOrAway,
        tg.Opponent,
        tg.FieldGoalsMade,
        tg.FieldGoalsAttempted,
        tg.ThreePointersMade,
        tg.ThreePointersAttempted,
        tg.FreeThrowsMade,
        tg.FreeThrowsAttempted,
        tg.PersonalFouls,
        tg.Rebounds,
        tg.OffensiveRebounds,
        tg.DefensiveRebounds,
        tg.Assists,
        tg.Steals,
        tg.Blocks,
        tg.Turnovers,
        tg.TotalPoints,
        t.TeamName
    FROM TeamGameStatistic tg
    JOIN Team t ON tg.TeamID = t.TeamID
    WHERE tg.GameID = p_GameID;
END;


-- Get Player's Season Averages Procedure
DROP PROCEDURE IF EXISTS GetPlayerSeasonAverages;
CREATE PROCEDURE GetPlayerSeasonAverages(
    IN p_PlayerID SMALLINT
)
BEGIN
    SELECT 
        AVG(FieldGoalsMade) AS AvgFieldGoalsMade,
        AVG(FieldGoalsAttempted) AS AvgFieldGoalsAttempted,
        AVG(ThreePointersMade) AS AvgThreePointersMade,
        AVG(ThreePointersAttempted) AS AvgThreePointersAttempted,
        AVG(FreeThrowsMade) AS AvgFreeThrowsMade,
        AVG(FreeThrowsAttempted) AS AvgFreeThrowsAttempted,
        AVG(PersonalFouls) AS AvgPersonalFouls,
        AVG(Rebounds) AS AvgRebounds,
        AVG(OffensiveRebounds) AS AvgOffensiveRebounds,
        AVG(DefensiveRebounds) AS AvgDefensiveRebounds,
        AVG(Assists) AS AvgAssists,
        AVG(Steals) AS AvgSteals,
        AVG(Blocks) AS AvgBlocks,
        AVG(Turnovers) AS AvgTurnovers,
        AVG(Points) AS AvgPoints,
        AVG(MinutesPlayed) AS AvgMinutesPlayed
    FROM PlayerGameStatistic
    WHERE PlayerID = p_PlayerID;
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
        t.TeamName AS Opponent,
        tg.HomeOrAway,
        tg.TotalPoints
    FROM TeamGameStatistic tg
    JOIN Game g ON tg.GameID = g.GameID
    JOIN Team t ON t.TeamID = CASE WHEN tg.HomeOrAway = 'Away' THEN tg.TeamID ELSE tg.Opponent END
    WHERE tg.TeamID = p_TeamID
    ORDER BY g.Date;
END;


-- Get Team Season Statistics Procedure
DROP PROCEDURE IF EXISTS GetTeamSeasonStatistics;
CREATE PROCEDURE GetTeamSeasonStatistics(IN p_TeamID SMALLINT, IN p_SeasonYear INT)
BEGIN
    SELECT 
        AVG(FieldGoalsMade) AS AvgFieldGoalsMade,
        AVG(FieldGoalsAttempted) AS AvgFieldGoalsAttempted,
        AVG(ThreePointersMade) AS AvgThreePointersMade,
        AVG(ThreePointersAttempted) AS AvgThreePointersAttempted,
        AVG(FreeThrowsMade) AS AvgFreeThrowsMade,
        AVG(FreeThrowsAttempted) AS AvgFreeThrowsAttempted,
        AVG(PersonalFouls) AS AvgPersonalFouls,
        AVG(Rebounds) AS AvgRebounds,
        AVG(OffensiveRebounds) AS AvgOffensiveRebounds,
        AVG(DefensiveRebounds) AS AvgDefensiveRebounds,
        AVG(Assists) AS AvgAssists,
        AVG(Steals) AS AvgSteals,
        AVG(Blocks) AS AvgBlocks,
        AVG(Turnovers) AS AvgTurnovers,
        AVG(TotalPoints) AS AvgTotalPoints
    FROM TeamGameStatistic
    JOIN Game ON TeamGameStatistic.GameID = Game.GameID
    WHERE TeamID = p_TeamID AND YEAR(Game.Date) = p_SeasonYear;
END;


-- Get Two Player's Season Statistics And Compare Procedure
DROP PROCEDURE IF EXISTS ComparePlayers;
CREATE PROCEDURE ComparePlayers(IN p_PlayerID1 SMALLINT, IN p_PlayerID2 SMALLINT)
BEGIN
    SELECT 
        PlayerID,
        AVG(FieldGoalsMade) AS AvgFieldGoalsMade,
        AVG(FieldGoalsAttempted) AS AvgFieldGoalsAttempted,
        AVG(ThreePointersMade) AS AvgThreePointersMade,
        AVG(ThreePointersAttempted) AS AvgThreePointersAttempted,
        AVG(FreeThrowsMade) AS AvgFreeThrowsMade,
        AVG(FreeThrowsAttempted) AS AvgFreeThrowsAttempted,
        AVG(PersonalFouls) AS AvgPersonalFouls,
        AVG(Rebounds) AS AvgRebounds,
        AVG(OffensiveRebounds) AS AvgOffensiveRebounds,
        AVG(DefensiveRebounds) AS AvgDefensiveRebounds,
        AVG(Assists) AS AvgAssists,
        AVG(Steals) AS AvgSteals,
        AVG(Blocks) AS AvgBlocks,
        AVG(Turnovers) AS AvgTurnovers,
        AVG(Points) AS AvgPoints,
        AVG(MinutesPlayed) AS AvgMinutesPlayed
    FROM PlayerGameStatistic
    WHERE PlayerID IN (p_PlayerID1, p_PlayerID2)
    GROUP BY PlayerID;
END;


-- Find MVP of the Season Procedure
DROP PROCEDURE IF EXISTS MVPofTheSeason;   
CREATE PROCEDURE MVPofTheSeason(IN p_SeasonYear INT)
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
    WHERE YEAR(Game.Date) = p_SeasonYear
    GROUP BY PlayerID
    ORDER BY SUM(Points) DESC
    LIMIT 5;
END;

-- Find the efficiency rating of a player
DROP PROCEDURE IF EXISTS TrackPlayerEfficiency;
CREATE PROCEDURE TrackPlayerEfficiency(IN p_PlayerID SMALLINT)
BEGIN
    SELECT 
        YEAR(Game.Date) AS Season,
        AVG((Points + Rebounds + Assists + Steals + Blocks - (FieldGoalsAttempted - FieldGoalsMade) - (FreeThrowsAttempted - FreeThrowsMade) - Turnovers) / MinutesPlayed) AS EfficiencyRating
    FROM PlayerGameStatistic
    JOIN Game ON PlayerGameStatistic.GameID = Game.GameID
    WHERE PlayerID = p_PlayerID
    GROUP BY YEAR(Game.Date);
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