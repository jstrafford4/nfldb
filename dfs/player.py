import nfldb
import psycopg2.extras

class Player(object):
    def __init__(self, *args, **kwargs):
        self.player_id = 0
        self.name = ''
        self.position = ''
        self.fanduel_salary = 0
        self.draftkings_salary = 0
        self.game = None
        self.team = ''
        self.fd_projected = 0.0
        self.fd_points = 0.0
        self.fd_variance = 0.0
        self.fd_correlations = {}
        self.dk_projected = 0.0
        self.dk_points = 0.0
        self.dk_variance = 0.0
        self.dk_correlations = {}
        for k, v in kwargs.items():
            self.__setattr__(k, v)

    def __repr__(self):
        return 'Player(%2s %s %s FD:$%s proj:%2.2f DK:$%s proj:%2.2f)' % (self.name, self.position, self.team, self.fanduel_salary, self.fd_projected, self.draftkings_salary, self.dk_projected)

def LoadPlayers(week, year):
    db = nfldb.connect()
    cur1 = db.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur1.callproc('get_players', ['curname', 17, 2017])
    cur2 = db.cursor('curname', cursor_factory=psycopg2.extras.NamedTupleCursor) 

    playerList = []
    for rec in cur2:
        p = Player()
        p.player_id = rec.player_id
        p.name = rec.full_name
        p.position = rec.position
        p.fanduel_salary = rec.fanduel_salary
        p.draftkings_salary = rec.draftkings_salary
        p.game = None
        p.team = rec.team
        p.fd_projected = -1
        p.fd_variance = rec.fd_variance
        p.fd_points = rec.fanduel_points
        p.fd_correlations = {}
        p.dk_projected = -1
        p.dk_variance = rec.dk_variance
        p.dk_points = rec.draftkings_points
        p.dk_correlations = {}
        playerList.append(p)
    cur2.close()
    cur1.close()
    db.close()
    return playerList



