import nfldb


def fantasy_points(year, week_number):
    execute_stored_proc = "SELECT calc_fantasy_points(%(week)s, %(year)s, 'Regular'::season_phase);"
    db = nfldb.connect()
    cur = db.cursor()
    cur.execute(execute_stored_proc, {'week': week_number, 'year': year})
    db.commit()
    cur.close()
    db.close()

def variance(year, week_number, last_n_weeks=5):
    execute_stored_proc = "SELECT compute_variance(%(week)s, %(year)s, %(past_n)s);"
    db = nfldb.connect()
    cur = db.cursor()
    cur.execute(execute_stored_proc, {'week': week_number, 'year': year, 'past_n': last_n_weeks})
    db.commit()
    cur.close()
    db.close()

def same_team_correlations(year, week_number, last_n_weeks=5):
    execute_stored_proc = "SELECT same_team_correlations(%(week)s, %(year)s, %(past_n)s);"
    db = nfldb.connect()
    cur = db.cursor()
    cur.execute(execute_stored_proc, {'week': week_number, 'year': year, 'past_n': last_n_weeks})
    db.commit()
    cur.close()
    db.close()