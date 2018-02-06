import sys
import db_computations as db_compute

def getopts(argv):
    opts = {}  # Empty dictionary to store key-value pairs.
    while argv:  # While there are arguments left to parse...
        if argv[0][0] == '-':  # Found a "-name value" pair.
            opts[argv[0]] = argv[1]  # Add key and value to the dictionary.
        argv = argv[1:]  # Reduce the argument list by copying it starting from index 1.
    return opts



opts = getopts(sys.argv)
if '-y' not in opts:
    print 'Please enter a year argument with -y.  Also optionally a week with -w, and past n weeks with -n'
    exit()
year = int(opts['-y'])

past_n_weeks = 5
if '-n' in opts:
    past_n_weeks = int(opts['-n'])



if '-w' in opts:
    week = int(opts['-w'])
    start_week = max(week - past_n_weeks + 1, 1)
    for cur_week in range(start_week, week+1):
        db_compute.fantasy_points(year, cur_week)
    db_compute.variance(year, week, past_n_weeks)
    db_compute.same_team_correlations(year, week, past_n_weeks)

