-- Type: feature_type

-- DROP TYPE public.feature_type;

CREATE TYPE public.feature_type AS ENUM
    ('Average', 'Median', 'Total', 'Max', 'Min', 'Vegas', 'Home', 'Away', 'Injury');

ALTER TYPE public.feature_type
    OWNER TO nfldb;

