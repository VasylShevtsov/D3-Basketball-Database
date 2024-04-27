DELIMITER $$

CREATE PROCEDURE VerifyPlayerPoints()
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
        
        -- Calculate total points for player in the game
        SELECT SUM(Points) INTO playerPointsVar
        FROM PlayerGameStatistic
        WHERE PlayerID = playerIdVar AND GameID = gameIdVar;
        
        -- Get total points for the team in the game
        SELECT TotalPoints INTO teamPointsVar
        FROM TeamGameStatistic
        WHERE TeamID = teamIdVar AND GameID = gameIdVar;
        
        -- Compare total points for player and team
        IF playerPointsVar != teamPointsVar THEN
            -- Handle the discrepancy (e.g., log or raise error)
            -- For example, you can print the details of the discrepancy
            SELECT CONCAT('Discrepancy found for PlayerID: ', playerIdVar, ', GameID: ', gameIdVar) AS Message;
            SELECT CONCAT('Player Points: ', playerPointsVar, ', Team Points: ', teamPointsVar) AS Points_Info;
        END IF;
    END LOOP;
    
    -- Close cursor
    CLOSE cur;
    
END$$

DELIMITER ;
