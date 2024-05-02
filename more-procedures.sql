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

