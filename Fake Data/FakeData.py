from faker import Faker
from datetime import datetime, timedelta
import random
import os

# This is so the generated files are saved in the same directory as this script, not in the project root
# Get the directory of the current script
script_dir = os.path.dirname(os.path.realpath(__file__))
# Change the working directory to the script's directory
os.chdir(script_dir)

fake = Faker()

# function to generate a list of dictionaries containing team data
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

# function to generate synthetic player data
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
with open('player_data.sql', 'w') as f:
    for player in players_data:
        f.write(f"INSERT INTO Player (PlayerID, TeamID, FirstName, LastName, Position, HeightInches, Weight, HighSchool) "
                f"VALUES ({player['PlayerID']}, {player['TeamID']}, '{player['FirstName']}', '{player['LastName']}', "
                f"'{player['Position']}', {player['HeightInches']}, {player['Weight']}, '{player['HighSchool']}');\n")

# function to generatie game pairings
def generate_unique_game_pairings(team_ids, number_of_games_per_year, years=4):
    games_data = []
    current_year = datetime.now().year

    for year in range(current_year - years, current_year + 1):
        for _ in range(number_of_games_per_year):
            home_team = random.choice(team_ids)
            away_team = home_team
            while away_team == home_team:
                away_team = random.choice(team_ids)

            # Generate month within the academic year (August to May)
            month = random.choice([8, 9, 10, 11, 12, 1, 2, 3, 4, 5])
            if month > 7:  # For months August to December, the year is current
                game_year = year
            else:  # For months January to May, the year should increment
                game_year = year + 1

            day = random.randint(1, 28)
            game_date = datetime(game_year, month, day)

            game_id = len(games_data) + 1
            game_data = {
                'GameID': game_id,
                'HomeTeamID': home_team,
                'AwayTeamID': away_team,
                'GameDate': game_date.strftime('%Y-%m-%d'),
            }
            
            games_data.append(game_data)
    
    return games_data

games = generate_unique_game_pairings(team_ids=team_ids, number_of_games_per_year=6, years=4)
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
            field_goals_made = random.randint(0, 12)
            field_goals_attempted = random.randint(field_goals_made, 20)
            three_pointers_made = random.randint(0, 7)
            three_pointers_attempted = random.randint(three_pointers_made, 15)
            free_throws_made = random.randint(0, 8)
            free_throws_attempted = random.randint(free_throws_made, 10)
            personal_fouls = random.randint(0, 6)
            rebounds = random.randint(0, 15)
            offensive_rebounds = random.randint(0, rebounds)
            defensive_rebounds = rebounds - offensive_rebounds
            assists = random.randint(0, 10)
            steals = random.randint(0, 5)
            blocks = random.randint(0, 5)
            turnovers = random.randint(0, 7)
            points = field_goals_made * 2 + three_pointers_made * 3 + free_throws_made
            minutes_played = random.randint(5, 40)

            stat = {
                'PlayerID': player['PlayerID'],
                'GameID': game['GameID'],
                'FieldGoalsMade': field_goals_made,
                'FieldGoalsAttempted': field_goals_attempted,
                'ThreePointersMade': three_pointers_made,
                'ThreePointersAttempted': three_pointers_attempted,
                'FreeThrowsMade': free_throws_made,
                'FreeThrowsAttempted': free_throws_attempted,
                'PersonalFouls': personal_fouls,
                'Rebounds': rebounds,
                'OffensiveRebounds': offensive_rebounds,
                'DefensiveRebounds': defensive_rebounds,
                'Assists': assists,
                'Steals': steals,
                'Blocks': blocks,
                'Turnovers': turnovers,
                'Points': points,
                'MinutesPlayed': minutes_played
            }
            player_game_stats.append(stat)

    return player_game_stats


player_game_stats = generate_player_game_statistics(players_data, games, num_players_per_game=10)
with open('player_game_stats_data.sql', 'w') as f:
    for stat in player_game_stats:
        f.write(f"INSERT INTO PlayerGameStatistic (PlayerID, GameID, FieldGoalsMade, FieldGoalsAttempted, "
                f"ThreePointersMade, ThreePointersAttempted, FreeThrowsMade, FreeThrowsAttempted, PersonalFouls, "
                f"Rebounds, OffensiveRebounds, DefensiveRebounds, Assists, Steals, Blocks, Turnovers, Points, "
                f"MinutesPlayed) VALUES ({stat['PlayerID']}, {stat['GameID']}, {stat['FieldGoalsMade']}, "
                f"{stat['FieldGoalsAttempted']}, {stat['ThreePointersMade']}, {stat['ThreePointersAttempted']}, "
                f"{stat['FreeThrowsMade']}, {stat['FreeThrowsAttempted']}, {stat['PersonalFouls']}, "
                f"{stat['Rebounds']}, {stat['OffensiveRebounds']}, {stat['DefensiveRebounds']}, {stat['Assists']}, {stat['Steals']}, "
                f"{stat['Blocks']}, {stat['Turnovers']}, {stat['Points']}, {stat['MinutesPlayed']});\n")

# Function to generate team game statistics
def generate_team_game_statistics(games, player_game_stats):
    team_game_stats = []
    for game in games:
        # Filter player stats by home and away teams based on the current game
        home_team_stats = [stat for stat in player_game_stats if stat['GameID'] == game['GameID'] and stat['PlayerID'] in [player['PlayerID'] for player in players_data if player['TeamID'] == game['HomeTeamID']]]
        away_team_stats = [stat for stat in player_game_stats if stat['GameID'] == game['GameID'] and stat['PlayerID'] in [player['PlayerID'] for player in players_data if player['TeamID'] == game['AwayTeamID']]]

        # Function to aggregate statistics
        def aggregate_stats(team_stats):
            aggregated = {
                'FreeThrowsMade': sum(stat['FreeThrowsMade'] for stat in team_stats),
                'FreeThrowsAttempted': sum(stat['FreeThrowsAttempted'] for stat in team_stats),
                'FieldGoalsMade': sum(stat['FieldGoalsMade'] for stat in team_stats),
                'FieldGoalsAttempted': sum(stat['FieldGoalsAttempted'] for stat in team_stats),
                'ThreePointersMade': sum(stat['ThreePointersMade'] for stat in team_stats),
                'ThreePointersAttempted': sum(stat['ThreePointersAttempted'] for stat in team_stats),
                'PersonalFouls': sum(stat['PersonalFouls'] for stat in team_stats),
                'Rebounds': sum(stat['Rebounds'] for stat in team_stats),
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

        # Append aggregated data for each team
        team_game_stats.append({
            'TeamID': game['HomeTeamID'],
            'GameID': game['GameID'],
            'HomeOrAway': 'Home',
            **home_aggregated_stats
        })

        team_game_stats.append({
            'TeamID': game['AwayTeamID'],
            'GameID': game['GameID'],
            'HomeOrAway': 'Away',
            **away_aggregated_stats
        })

    return team_game_stats


team_game_stats = generate_team_game_statistics(games, player_game_stats)
with open('team_game_stats_data.sql', 'w') as f:
    for stat in team_game_stats:
        f.write(f"INSERT INTO TeamGameStatistic (TeamID, GameID, HomeOrAway, FieldGoalsMade, "
                f"FieldGoalsAttempted, ThreePointersMade, ThreePointersAttempted, FreeThrowsMade, FreeThrowsAttempted, "
                f"PersonalFouls, Rebounds, OffensiveRebounds, DefensiveRebounds, Assists, Steals, Blocks, Turnovers, TotalPoints) "
                f"VALUES ({stat['TeamID']}, {stat['GameID']}, '{stat['HomeOrAway']}', {stat['FieldGoalsMade']}, "
                f"{stat['FieldGoalsAttempted']}, {stat['ThreePointersMade']}, {stat['ThreePointersAttempted']}, {stat['FreeThrowsMade']}, "
                f"{stat['FreeThrowsAttempted']}, {stat['PersonalFouls']}, {stat['Rebounds']}, {stat['OffensiveRebounds']}, {stat['DefensiveRebounds']}, "
                f"{stat['Assists']}, {stat['Steals']}, {stat['Blocks']}, {stat['Turnovers']}, {stat['TotalPoints']});\n")