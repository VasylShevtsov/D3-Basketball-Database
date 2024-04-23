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
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

CREATE TABLE Game (
  GameID SMALLINT PRIMARY KEY,
  HomeTeamID SMALLINT,
  AwayTeamID SMALLINT,
  Date DATE,
  HomeScore SMALLINT,
  AwayScore SMALLINT,
  UNIQUE (HomeTeamID, AwayTeamID, Date),
  FOREIGN KEY (HomeTeamID) REFERENCES Team(TeamID),
  FOREIGN KEY (AwayTeamID) REFERENCES Team(TeamID)
);

CREATE TABLE TeamGameStatistic (
  TeamID SMALLINT,
  GameID SMALLINT,
  HomeOrAway ENUM('Home', 'Away'),
  FreeThrowsMade SMALLINT,
  Opponent VARCHAR(40),
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
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID),
  FOREIGN KEY (GameID) REFERENCES Game(GameID)
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
  FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
  FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

