CREATE TABLE Team (
  TeamID SMALLINT PRIMARY KEY,
  TeamName VARCHAR(40) UNIQUE,
  Location VARCHAR(100)
);

CREATE TABLE Player (
  PlayerID SMALLINT PRIMARY KEY,
  TeamID SMALLINT,
  FirstName VARCHAR(40),
  LastName VARCHAR(40),
  Position VARCHAR(30),
  HeightInches TINYINT,
  Weight SMALLINT,
  HighSchool VARCHAR(40),
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE SET NULL ON UPDATE RESTRICT
);

CREATE TABLE Game (
  GameID SMALLINT PRIMARY KEY,
  HomeTeamID SMALLINT,
  AwayTeamID SMALLINT,
  Date DATE,
  HomeScore SMALLINT,
  AwayScore SMALLINT,
  UNIQUE (HomeTeamID, AwayTeamID, Date),
  FOREIGN KEY (HomeTeamID) REFERENCES Team(TeamID)ON DELETE CASCADE ON UPDATE RESTRICT,
  FOREIGN KEY (AwayTeamID) REFERENCES Team(TeamID) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE TeamGameStatistic (
  TeamID SMALLINT,
  GameID SMALLINT,
  HomeOrAway ENUM('Home', 'Away'),
  FreeThrowsMade SMALLINT,
  FieldGoals SMALLINT,
  FieldGoalsAttempted SMALLINT,
  ThreePointersMade SMALLINT,
  ThreePointersAttempted SMALLINT,
  FreeThrowsAttempted SMALLINT,
  PersonalFouls SMALLINT,
  OffensiveRebounds SMALLINT,
  DefensiveRebounds SMALLINT,
  Assists SMALLINT,
  Steals SMALLINT,
  Blocks SMALLINT,
  Turnovers SMALLINT,
  TotalPoints SMALLINT,
  PRIMARY KEY (TeamID, GameID),
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE ON UPDATE RESTRICT,
  FOREIGN KEY (GameID) REFERENCES Game(GameID) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE PlayerGameStatistic (
  PlayerID SMALLINT,
  GameID SMALLINT,
  Points SMALLINT,
  Assists SMALLINT,
  Rebounds SMALLINT,
  OffensiveRebounds SMALLINT,
  DefensiveRebounds SMALLINT,
  FieldGoalsMade SMALLINT,
  FieldGoalsAttempted SMALLINT,
  ThreePointersMade SMALLINT,
  ThreePointersAttempted SMALLINT,
  FreeThrowsMade SMALLINT,
  FreeThrowsAttempted SMALLINT,
  Steals SMALLINT,
  Blocks SMALLINT,
  Turnovers SMALLINT,
  PersonalFouls SMALLINT,
  MinutesPlayed SMALLINT,
  PRIMARY KEY (PlayerID, GameID),
  FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID) ON DELETE CASCADE,
  FOREIGN KEY (GameID) REFERENCES Game(GameID) ON DELETE CASCADE ON UPDATE RESTRICT
);

