-- FUNCTION: public.compute_team_stats(integer, integer, integer)

-- DROP FUNCTION public.compute_team_stats(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.compute_team_stats(
	p_week integer,
	p_year integer,
	p_last_n_weeks integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

DECLARE 
 game_row game%rowtype;
BEGIN

	FOR game_row in (SELECT g.* FROM game g
                    	WHERE g.week = p_week
                    			AND g.season_year = p_year
								AND g.season_type = 'Regular'::season_phase) LOOP

		
		DROP TABLE IF EXISTS stats_against;
        CREATE TEMP TABLE stats_against ON COMMIT DROP AS
        	SELECT p.position pos,
			SUM(gp.fanduel_points) total_fd_pts, 
            SUM(gp.draftkings_points) total_dk_pts, 
            AVG(gp.fd_5wk_standard_units) fd_avg_std_units,
            AVG(gp.dk_5wk_standard_units) dk_avg_std_units
            FROM game_player gp
                INNER JOIN game g
                	ON gp.gsis_id = g.gsis_id
				INNER JOIN player p
                    ON p.player_id = gp.player_id
            WHERE g.home_team = game_row.home_team
			   OR g.away_team = game_row.home_team
				AND p.team <> game_row.home_team
                AND gp.fanduel_points IS NOT NULL
				AND gp.draftkings_points IS NOT NULL
                AND g.season_year = p_year
                AND g.week <= p_week
				-- really should select p_last_n_weeks and use a contains or something
				AND g.week > p_week - p_last_n_weeks
                AND g.season_type = 'Regular'::season_phase
				AND p.position IN ('QB', 'RB', 'WR', 'TE', 'DST')
                GROUP BY pos;

		
		INSERT INTO team_stats (team, week, season_year, season_type, "position", last_n_weeks,
                                total_fd_pts, total_dk_pts, fd_avg_std_units, dk_avg_std_units)
			SELECT game_row.home_team, p_week, p_year, 'Regular'::season_phase, sa.pos, p_last_n_weeks,
            		sa.total_fd_pts, sa.total_dk_pts, sa.fd_avg_std_units, sa.dk_avg_std_units
			FROM stats_against sa
		ON CONFLICT (team, week, season_year, season_type, "position", last_n_weeks)
			DO UPDATE SET 
				(total_fd_pts, total_dk_pts, fd_avg_std_units, dk_avg_std_units)
			= (EXCLUDED.total_fd_pts, EXCLUDED.total_dk_pts, EXCLUDED.fd_avg_std_units, EXCLUDED.dk_avg_std_units);

		DROP TABLE stats_against;

		-- repeat for away team.  sloppy, I know.
		DROP TABLE IF EXISTS stats_against;
        CREATE TEMP TABLE stats_against ON COMMIT DROP AS
        	SELECT p.position pos,
			SUM(gp.fanduel_points) total_fd_pts, 
            SUM(gp.draftkings_points) total_dk_pts, 
            AVG(gp.fd_5wk_standard_units) fd_avg_std_units,
            AVG(gp.dk_5wk_standard_units) dk_avg_std_units
            FROM game_player gp
                INNER JOIN game g
                	ON gp.gsis_id = g.gsis_id
				INNER JOIN player p
                    ON p.player_id = gp.player_id
            WHERE g.home_team = game_row.away_team
			   OR g.away_team = game_row.away_team
				AND p.team <> game_row.away_team
                AND gp.fanduel_points IS NOT NULL
				AND gp.draftkings_points IS NOT NULL
                AND g.season_year = p_year
                AND g.week <= p_week
				AND g.week > p_week - p_last_n_weeks
                AND g.season_type = 'Regular'::season_phase
				AND p.position IN ('QB', 'RB', 'WR', 'TE', 'DST')
                GROUP BY pos;

		
		INSERT INTO team_stats (team, week, season_year, season_type, "position", last_n_weeks,
                                total_fd_pts, total_dk_pts, fd_avg_std_units, dk_avg_std_units)
			SELECT game_row.home_team, p_week, p_year, 'Regular'::season_phase, sa.pos, p_last_n_weeks,
            		sa.total_fd_pts, sa.total_dk_pts, sa.fd_avg_std_units, sa.dk_avg_std_units
			FROM stats_against sa
		ON CONFLICT (team, week, season_year, season_type, "position", last_n_weeks)
			DO UPDATE SET 
				(total_fd_pts, total_dk_pts, fd_avg_std_units, dk_avg_std_units)
			= (EXCLUDED.total_fd_pts, EXCLUDED.total_dk_pts, EXCLUDED.fd_avg_std_units, EXCLUDED.dk_avg_std_units);
            
		DROP TABLE stats_against;

    END LOOP;
        
            
 
 RETURN;
END; 

$BODY$;

ALTER FUNCTION public.compute_team_stats(integer, integer, integer)
    OWNER TO postgres;

