from faker import Faker
import random

fake = Faker()

# generate a list of dictionaries containing team data
def generate_teams_data(number_of_teams):
    teams_data = []
    for i in range(number_of_teams):
        team_data = {
            'TeamID': i + 1,
            'TeamName': fake.company(),
            'Location': fake.city()
        }
        teams_data.append(team_data)
    return teams_data


num_of_teams = 100
teams = generate_teams_data(num_of_teams)
team_ids = [team['TeamID'] for team in teams]

with open('teams_data.sql', 'w') as f:
    for team in teams:
        f.write(f"INSERT INTO Team (TeamID, TeamName, Location) VALUES ({team['TeamID']}, '{team['TeamName']}', '{team['Location']}');\n")

# Function to generate synthetic player data
def generate_players_data(number_of_players, team_ids):
    players_data = []
    for _ in range(number_of_players):
        players_data.append({
            'PlayerID': fake.unique.random_int(min=1, max=9999),
            'TeamID': random.choice(team_ids), 
            'FirstName': fake.first_name(),
            'LastName': fake.last_name(),
            'Position': random.choice(['Guard', 'Forward', 'Center']),
            'HeightInches': random.randint(65, 85),  # Heights in inches
            'Weight': random.randint(150, 250),  # Weight in pounds
            'HighSchool': fake.company()
        })
    return players_data

num_of_players = num_of_teams * 15 # 15 players per team
players_data = generate_players_data(num_of_players, team_ids)

# Output to a SQL file
with open('player_data.sql', 'w') as f:
    for player in players_data:
        f.write(f"INSERT INTO Player (PlayerID, TeamID, FirstName, LastName, Position, HeightInches, Weight, HighSchool) "
                f"VALUES ({player['PlayerID']}, {player['TeamID']}, '{player['FirstName']}', '{player['LastName']}', "
                f"'{player['Position']}', {player['HeightInches']}, {player['Weight']}, '{player['HighSchool']}');\n")


# Function to generate unique game pairings with GameID included
def generate_unique_game_pairings(team_ids, number_of_games):
    games_data = []
    
    for game_id in range(1, number_of_games + 1):  # Start GameID at 1 and increment within the loop
        home_team = random.choice(team_ids)
        away_team = home_team
        while away_team == home_team:
            away_team = random.choice(team_ids)
        
        game_date = fake.date_between(start_date='-2y', end_date='today')

        game_data = {
            'GameID': game_id,  # Assign the GameID here
            'HomeTeamID': home_team,
            'AwayTeamID': away_team,
            'GameDate': game_date,
        }
        
        games_data.append(game_data)
    
    return games_data

# Generate synthetic games data
number_of_games = 100  # Number of games you want to generate
games = generate_unique_game_pairings(team_ids, number_of_games)

# Output to a SQL file
with open('games_data.sql', 'w') as f:
    for game in games:
        f.write(f"INSERT INTO Game (GameID, HomeTeamID, AwayTeamID, Date) VALUES ({game['GameID']}, {game['HomeTeamID']}, {game['AwayTeamID']}, '{game['GameDate']}');\n")

        
# Function to generate player game statistics
def generate_player_game_statistics(players_data, games, num_players_per_game=10):
    player_game_stats = []
    for game in games:
        # Select players for each team in the game
        home_team_players = [player for player in players_data if player['TeamID'] == game['HomeTeamID']]
        away_team_players = [player for player in players_data if player['TeamID'] == game['AwayTeamID']]
        
        # Randomly choose players to participate in the game
        participating_home_players = random.sample(home_team_players, min(num_players_per_game, len(home_team_players)))
        participating_away_players = random.sample(away_team_players, min(num_players_per_game, len(away_team_players)))
        
        # Generate statistics for each participating player
        for player in participating_home_players + participating_away_players:
            points = random.randint(0, 30)
            assists = random.randint(0, 10)
            rebounds = random.randint(0, 15)
            offensive_rebounds = random.randint(0, rebounds)
            defensive_rebounds = rebounds - offensive_rebounds
            field_goals_made = random.randint(0, 12)
            field_goals_attempted = random.randint(field_goals_made, 20)
            three_pointers_made = random.randint(0, 7)
            three_pointers_attempted = random.randint(three_pointers_made, 15)
            free_throws_made = random.randint(0, 8)
            free_throws_attempted = random.randint(free_throws_made, 10)
            steals = random.randint(0, 5)
            blocks = random.randint(0, 5)
            turnovers = random.randint(0, 7)
            personal_fouls = random.randint(0, 6)
            minutes_played = random.randint(5, 40)

            stat = {
                'PlayerID': player['PlayerID'],
                'GameID': game['GameID'],
                'Points': points,
                'Assists': assists,
                'Rebounds': rebounds,
                'OffensiveRebounds': offensive_rebounds,
                'DefensiveRebounds': defensive_rebounds,
                'FieldGoalsMade': field_goals_made,
                'FieldGoalsAttempted': field_goals_attempted,
                'ThreePointersMade': three_pointers_made,
                'ThreePointersAttempted': three_pointers_attempted,
                'FreeThrowsMade': free_throws_made,
                'FreeThrowsAttempted': free_throws_attempted,
                'Steals': steals,
                'Blocks': blocks,
                'Turnovers': turnovers,
                'PersonalFouls': personal_fouls,
                'MinutesPlayed': minutes_played
            }
            player_game_stats.append(stat)

    return player_game_stats

# Generate player game statistics
player_game_stats = generate_player_game_statistics(players_data, games, num_players_per_game=10)

# Output to a SQL file
with open('player_game_stats_data.sql', 'w') as f:
    for stat in player_game_stats:
        f.write(f"INSERT INTO PlayerGameStatistic (PlayerID, GameID, Points, Assists, Rebounds, OffensiveRebounds, "
                f"DefensiveRebounds, FieldGoalsMade, FieldGoalsAttempted, ThreePointersMade, ThreePointersAttempted, "
                f"FreeThrowsMade, FreeThrowsAttempted, Steals, Blocks, Turnovers, PersonalFouls, MinutesPlayed) "
                f"VALUES ({stat['PlayerID']}, {stat['GameID']}, {stat['Points']}, {stat['Assists']}, {stat['Rebounds']}, "
                f"{stat['OffensiveRebounds']}, {stat['DefensiveRebounds']}, {stat['FieldGoalsMade']}, "
                f"{stat['FieldGoalsAttempted']}, {stat['ThreePointersMade']}, {stat['ThreePointersAttempted']}, "
                f"{stat['FreeThrowsMade']}, {stat['FreeThrowsAttempted']}, {stat['Steals']}, {stat['Blocks']}, "
                f"{stat['Turnovers']}, {stat['PersonalFouls']}, {stat['MinutesPlayed']});\n")
        
def generate_team_game_statistics(games, player_game_stats):
    team_game_stats = []
    for game in games:
        # Separate player stats by home and away teams
        home_team_stats = [stat for stat in player_game_stats if stat['GameID'] == game['GameID'] and stat['PlayerID'] in [player['PlayerID'] for player in players_data if player['TeamID'] == game['HomeTeamID']]]
        away_team_stats = [stat for stat in player_game_stats if stat['GameID'] == game['GameID'] and stat['PlayerID'] in [player['PlayerID'] for player in players_data if player['TeamID'] == game['AwayTeamID']]]

        # Function to aggregate statistics
        def aggregate_stats(team_stats):
            aggregated = {
                'FreeThrowsMade': sum(stat['FreeThrowsMade'] for stat in team_stats),
                'FieldGoalsMade': sum(stat['FieldGoalsMade'] for stat in team_stats),
                'FieldGoalsAttempted': sum(stat['FieldGoalsAttempted'] for stat in team_stats),
                'ThreePointersMade': sum(stat['ThreePointersMade'] for stat in team_stats),
                'ThreePointersAttempted': sum(stat['ThreePointersAttempted'] for stat in team_stats),
                'PersonalFouls': sum(stat['PersonalFouls'] for stat in team_stats),
                'OffensiveRebounds': sum(stat['OffensiveRebounds'] for stat in team_stats),
                'DefensiveRebounds': sum(stat['DefensiveRebounds'] for stat in team_stats),
                'Assists': sum(stat['Assists'] for stat in team_stats),
                'Steals': sum(stat['Steals'] for stat in team_stats),
                'Blocks': sum(stat['Blocks'] for stat in team_stats),
                'Turnovers': sum(stat['Turnovers'] for stat in team_stats),
                'TotalPoints': sum(stat['Points'] for stat in team_stats)
            }
            return aggregated

        # Aggregate stats for home and away teams
        home_aggregated_stats = aggregate_stats(home_team_stats)
        away_aggregated_stats = aggregate_stats(away_team_stats)

        # Add to the overall list
        team_game_stats.append({
            'TeamID': game['HomeTeamID'],
            'GameID': game['GameID'],
            'HomeOrAway': 'Home',
            'Opponent': game['AwayTeamID'],
            **home_aggregated_stats
        })

        team_game_stats.append({
            'TeamID': game['AwayTeamID'],
            'GameID': game['GameID'],
            'HomeOrAway': 'Away',
            'Opponent': game['HomeTeamID'],
            **away_aggregated_stats
        })

    return team_game_stats

# Generate team game statistics
team_game_stats = generate_team_game_statistics(games, player_game_stats)

# Output to a SQL file
with open('team_game_stats_data.sql', 'w') as f:
    for stat in team_game_stats:
        f.write(f"INSERT INTO TeamGameStats (TeamID, GameID, HomeOrAway, FreeThrowsMade, Opponent, FieldGoalsMade, "
                f"FieldGoalsAttempted, ThreePointersMade, ThreePointersAttempted, PersonalFouls, OffensiveRebounds, "
                f"DefensiveRebounds, Assists, Steals, Blocks, Turnovers, TotalPoints) VALUES "
                f"({stat['TeamID']}, {stat['GameID']}, '{stat['HomeOrAway']}', {stat['FreeThrowsMade']}, '{stat['Opponent']}', "
                f"{stat['FieldGoalsMade']}, {stat['FieldGoalsAttempted']}, {stat['ThreePointersMade']}, {stat['ThreePointersAttempted']}, "
                f"{stat['PersonalFouls']}, {stat['OffensiveRebounds']}, {stat['DefensiveRebounds']}, {stat['Assists']}, "
                f"{stat['Steals']}, {stat['Blocks']}, {stat['Turnovers']}, {stat['TotalPoints']});\n")
