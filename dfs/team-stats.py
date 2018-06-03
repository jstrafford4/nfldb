import nfldb
import psycopg2.extras
from pprint import pprint

class TeamStats(object):
    def __init__(self, *args, **kwargs):
        self.team = ''
        self.week = 0
        self.year = 0
        self.num_prev_weeks = 0
        self.position_stats_against = {
            'QB': None,
            'RB': None,
            'WR': None,
            'TE': None,
            'DST': None,
        }
        for k, v in kwargs.items():
            self.__setattr__(k, v)

def LoadAllTeams(week, year, num_weeks=5):
    sql = """
            SELECT * FROM team_stats ts
            WHERE ts.week = %(week)s
                AND ts.season_year = %(year)s
                AND ts.last_n_weeks = %(past_n)s;
        """

    db = nfldb.connect()
    cur1 = db.cursor(cursor_factory=psycopg2.extras.DictCursor)

    cur1.execute(sql, {'week': week, 'year': year, 'past_n': num_weeks})

    allRecords = cur1.fetchall()

    allTeams = {}

    for record in allRecords:
        if record['team'] not in allTeams:
            allTeams[record['team']] = TeamStats({
                'team': record['team'],
                'week': week,
                'year': year,
                'num_prev_weeks': num_weeks
            })
        allTeams[record['team']].position_stats_against[str(record['position'])] = {
                'total_fd_pts': record['total_fd_pts'],
                'total_dk_pts': record['total_dk_pts'],
                'fd_avg_std_units': record['fd_avg_std_units'],
                'dk_avg_std_units': record['dk_avg_std_units']
            }
        
    cur1.close()
    db.close()

    pprint(allTeams['OAK'].position_stats_against)

    return allTeams

LoadAllTeams(7, 2017)



