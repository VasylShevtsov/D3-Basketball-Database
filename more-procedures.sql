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
