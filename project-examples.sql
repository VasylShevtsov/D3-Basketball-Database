-- Title: D3 Basketball Database
-- File: Project Examples
-- Authors: Aidan Von Buchwaldt, Basil Shevtsov, and Jai Deshpande


-- Testing the NewPlayer stored procedure
SELECT *
FROM Player
WHERE PlayerID = 1;

CALL NewPlayer(1, 'John', 'Doe', 1, 'Guard', 72, 180, 'Central High');

SELECT *
FROM Player
WHERE PlayerID = 1;

-- Testing the UpdatePlayer stored procedure
CALL UpdatePlayer(1, 'Jane', 'Doe', 1, 'Guard', 72, 180, 'Central High');

SELECT *
FROM Player
WHERE PlayerID = 1;

-- Testing the DeletePlayer stored procedure
-- Note, this will also delete the player's game statistics
CALL DeletePlayer(1);

SELECT *
FROM Player
WHERE PlayerID = 1;

-- Testing the GetPlayerStats stored procedure
CALL GetPlayerStats(9237, 1);

-- Testing the GetTeamStats stored procedure
CALL GetTeamStats(14, 1);

-- Testing the GetBothTeamsStats stored procedure
CALL GetBothTeamStats(10);

-- Testing the GetPlayerSeasonAverages stored procedure
CALL GetPlayerSeasonAverages(3799, 2023);

-- Testing the GetPlayerAveragesBetweenDates stored procedure
CALL GetPlayerAveragesBetweenDates(3799, '2021-03-08', '2022-06-09');

-- Testing the GetTeamGameHistory stored procedure
CALL GetTeamGameHistory(14);

-- Testing the GetTeamSeasonStatistics stored procedure
CALL GetTeamSeasonStatistics(14, 2023);

-- Testing the GetTeamStatisticsBetweenDates stored procedure
CALL GetTeamStatisticsBetweenDates(14, '2021-03-08', '2022-06-09');

-- Testing the ComparePlayersSeasonAverages stored procedure
CALL ComparePlayersSeasonAverages(3799, 2409, 2023);

-- Testing the MPofTheSeason stored procedure
CALL MVPofTheSeason(2023);

-- Testing the TrackPlayerEfficiency stored procedure
CALL TrackPlayerEfficiency(3799, 2023);

-- Testing the CalculatePlayerPIE stored procedure
CALL CalculatePlayerPIE(2653, 8);

-- Testing the CalculateSeasonPlayerPIE stored procedure
CALL CalculateSeasonPlayerPIE(2653, 2023);

-- Testing the GetPlayerSuccessImpact stored procedure
CALL GetPlayerSuccessImpact(2653, 2023);

-- Testing the GetTopScorersInGame stored procedure
CALL GetTopScorersInGame(1);

-- Testing the GetPlayerGameLog stored procedure
CALL GetPlayerGameLog(3799);

-- Testing the SeasonalTeamRanking stored procedure
CALL SeasonalTeamRanking(2023);

-- Testing the VerifyPoints stored procedure
CALL VerifyPoints(255, 18);

-- Testing the VerifyAllStats stored procedure
CALL VerifyAllStats(255, 18);

-- Testing the triggers for logging player deletions, team deletions, and game deletions
-- Note, this will also delete all the statistics related to the deleted player, team, and game
CALL DeletePlayer(1630);
CALL DeleteTeam(25);
CALL DeleteGame(750);

SELECT *
FROM DeletionLog;