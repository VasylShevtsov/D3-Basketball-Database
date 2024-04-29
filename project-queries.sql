-- VerifyPoints Procedure
CREATE PROCEDURE VerifyPoints()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE playerIdVar SMALLINT;
    DECLARE gameIdVar SMALLINT;
    DECLARE teamIdVar SMALLINT;
    DECLARE teamPointsVar SMALLINT;
    DECLARE playerPointsVar SMALLINT;
    
    -- Declare cursor to iterate through PlayerGameStatistic
    DECLARE cur CURSOR FOR 
        SELECT pg.PlayerID, pg.GameID, p.TeamID
        FROM PlayerGameStatistic pg
        INNER JOIN Player p ON pg.PlayerID = p.PlayerID;
    
    -- Declare handler for cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Open cursor
    OPEN cur;
    
    -- Loop through PlayerGameStatistic
    read_loop: LOOP
        -- Fetch values from cursor
        FETCH cur INTO playerIdVar, gameIdVar, teamIdVar;
        IF done THEN
            LEAVE read_loop;
        END IF;
    END LOOP read_loop;
    
    CLOSE cur;
END;


-- Insert Player Procedure
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
CREATE PROCEDURE DeletePlayer(
    IN p_PlayerID SMALLINT
)
BEGIN
    DELETE FROM Player
    WHERE PlayerID = p_PlayerID;
END;


-- Update Player Procedure
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
CREATE PROCEDURE GetTeamStats(
    IN p_TeamID SMALLINT,
    IN p_GameID SMALLINT
)
BEGIN
    SELECT *
    FROM TeamGameStatistic
    WHERE TeamID = p_TeamID AND GameID = p_GameID;
END;

