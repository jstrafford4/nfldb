import nfldb

class Player(object):
    def __init__(self, *args, **kwargs):
        self.player_id = 0
        self.name = ''
        self.position = ''
        self.fanduel_salary = 0
        self.draftkings_salary = 0
        self.game = None
        self.team = ''
        self.projected_fanduel = 0.0
        self.fd_variance = 0.0
        self.fd_correlations = {}
        self.projected_draftkings = 0.0
        self.dk_variance = 0.0
        self.dk_correlations = {}
        for k, v in kwargs.items():
            self.__setattr__(k, v)

    def __repr__(self):
        return 'Player(%2s %s %s FD:$%d proj:%2.2f DK:$%d proj:%2.2f)' % (self.name, self.position, self.team, self.fanduel_salary, self.projected_fanduel, self.draftkings_salary, self.projected_draftkings)

db = nfldb.connect()
cur1 = db.cursor()
cur1.callproc('get_players', ['curname', 17, 2017])
cur2 = db.cursor('curname')
for record in cur2:
    print(record)
cur1.close()
db.close()


