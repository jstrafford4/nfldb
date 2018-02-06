-- FUNCTION: public.same_team_correlations(integer, integer, integer)

-- DROP FUNCTION public.same_team_correlations(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.same_team_correlations(
	p_week integer,
	p_year integer,
	p_past_n_weeks integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

DECLARE 
 player_pair record;
 fanduel_corr double precision;
 draftkings_corr double precision;
BEGIN

	DROP TABLE IF EXISTS player_pairs;
    CREATE TEMP TABLE player_pairs ON COMMIT DROP AS
    	SELECT gp1.player_id player1_id, gp2.player_id player2_id, p1.position p1_pos, p2.position p2_pos
        FROM game_player gp1 INNER JOIN game_player gp2 ON gp1.gsis_id = gp2.gsis_id AND gp1.team = gp2.team 
    					     INNER JOIN game gm ON gp1.gsis_id = gm.gsis_id
                             INNER JOIN player p1 ON p1.player_id = gp1.player_id
                             INNER JOIN player p2 ON p2.player_id = gp2.player_id
    	WHERE gp1.player_id != gp2.player_id
          AND gm.week = p_week
          AND gm.season_year = p_year
          AND gm.season_type = 'Regular'::season_phase
          AND p1.position IN ('QB', 'RB', 'WR', 'TE')
          AND p2.position IN ('QB', 'RB', 'WR', 'TE');
                                
                                
  	FOR player_pair in (SELECT * FROM player_pairs) LOOP
  
  		DROP TABLE IF EXISTS pairs_last_n_games;
        CREATE TEMP TABLE pairs_last_n_games ON COMMIT DROP AS
          SELECT gp1.player_id player1_id, gp2.player_id player2_id, gp1.fanduel_points fdp1, gp2.fanduel_points fdp2,
        	   gp1.draftkings_points dkp1, gp2.draftkings_points dkp2, gp1.team team
          FROM game_player gp1 INNER JOIN game_player gp2 ON gp1.gsis_id = gp2.gsis_id
    					       INNER JOIN game gm ON gp1.gsis_id = gm.gsis_id
    	  WHERE gp1.player_id = player_pair.player1_id
       	    AND gp2.player_id = player_pair.player2_id
            AND gp1.fanduel_points IS NOT NULL
            AND gp2.fanduel_points IS NOT NULL
            AND gp1.draftkings_points IS NOT NULL
            AND gp2.draftkings_points IS NOT NULL
            AND gm.season_year <= p_year
            AND (gm.week <= p_week OR gm.season_year < p_year)
            AND gm.season_type = 'Regular'::season_phase
         ORDER BY gm.season_year DESC, gm.week DESC
         LIMIT p_past_n_weeks;
          
         SELECT INTO fanduel_corr, draftkings_corr 
         			 corr(fdp1, fdp2), corr(dkp1, dkp2)
         FROM pairs_last_n_games;
         
         INSERT INTO correlation (player1_id, player2_id, opp_pos, fd_coefficient, dk_coefficient, past_n_weeks, week, season_year)
         	    VALUES (player_pair.player1_id, player_pair.player2_id, player_pair.p2_pos, fanduel_corr, draftkings_corr, p_past_n_weeks, p_week, p_year)
                ON CONFLICT (player1_id, player2_id, opp_pos, past_n_weeks, week, season_year)
                DO UPDATE SET
                	(fd_coefficient, dk_coefficient)
                  = (EXCLUDED.fd_coefficient, EXCLUDED.dk_coefficient);
    
  	END LOOP;
  
 RETURN;
END; 
$BODY$;

ALTER FUNCTION public.same_team_correlations(integer, integer, integer)
    OWNER TO postgres;

