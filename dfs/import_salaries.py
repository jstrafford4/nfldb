import nfldb;


def try_num(n):
    try:
        return float(n)
    except:
        return n

class SalaryImporter(object):
    def __init__(self, file_name='', db=None):
        self.file_name = file_name
        self.insert_sql = ""
        if db is None:
            self.db = nfldb.connect()
        else:
            self.db = db

    def load_data(self, fn=None, db=None):
        pass

class DraftkingsSalaryImporter(SalaryImporter):
    def __init__(self, file_name='', db=None):
        self.file_name = file_name
        if db is None:
            self.db = nfldb.connect()
        else:
            self.db = db
        self.insert_sql = '''
            UPDATE game_player gp SET draftkings_salary = %(salary)s
                               FROM game g
                               WHERE gp.gsis_id = g.gsis_id
                               AND g.week = %(week)s
                               AND g.season_year = %(year)s
                               AND g.season_type = 'Regular'::season_phase
                               AND gp.player_id = %(player_id)s;

        '''

    def load_data(self, week_num, season_year, fn=None, db=None, header=None):
        
        if fn is None:
            fn = self.file_name
        if db is None:
            db = self.db
        cur = db.cursor()
        players = []
        with open(fn, 'r') as f:
            if header is None:
                header = f.readline().strip().split(',')
                header = map(lambda h:h.lower().replace(' ', '_').replace('"', ''), header)
            for line in f:
                vals = line.rstrip().replace('"', '').split(',')
                vals = map(lambda v: try_num(v), vals)
                kwargs = dict([(h, vals[i] if i < len(vals) else 0.0) for i,h in enumerate(header)])
                if (kwargs.get('name') is not None and kwargs.get('salary') is not None and kwargs.get('position') != 'DST'):
                    players.append(kwargs)
                    print(kwargs)
        print(self.insert_sql)
        for player in players:
            player_match = nfldb.player_search(self.db, player['name'])
            if player_match[0] is not None:
                print(player_match[0], player_match[0].player_id)
                cur.execute(self.insert_sql, {'player_id': player_match[0].player_id, 'salary': player['salary'], 'week': week_num, 'year': season_year})
        db.commit()
        cur.close()
        return players

    def close_db(self):
        self.db.close()


importer = DraftkingsSalaryImporter('data/draftkings/week12.csv')
importer.load_data(12, 2017)
importer.close_db()
