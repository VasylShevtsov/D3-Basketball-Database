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
