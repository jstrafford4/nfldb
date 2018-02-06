-- FUNCTION: public.get_correlations(refcursor, character varying, integer, integer, integer)

-- DROP FUNCTION public.get_correlations(refcursor, character varying, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.get_correlations(
	refcursor,
	p_player_id character varying,
	p_week integer,
	p_year integer,
	p_past_n_weeks integer DEFAULT 5)
    RETURNS refcursor
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

BEGIN
    OPEN $1 FOR
    	SELECT * FROM correlation c
        		WHERE c.week = p_week
                AND c.season_year = p_season_year
                AND c.past_n_weeks = p_past_n_weeks
                AND c.player1_id = p_player_id;
    RETURN $1;
END;

$BODY$;

ALTER FUNCTION public.get_correlations(refcursor, character varying, integer, integer, integer)
    OWNER TO postgres;

