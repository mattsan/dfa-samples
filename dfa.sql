-- $ psql some-database < dfa.sql
-- CREATE TABLE
-- INSERT 0 6
-- CREATE TABLE
-- INSERT 0 3
-- CREATE TABLE
-- INSERT 0 3
--  source | accepted 
-- --------+----------
--  baa    | f
--  a      | f
--  baba   | t
-- (3 rows)
--
-- DROP TABLE
-- DROP TABLE
-- DROP TABLE

CREATE TABLE rules (state INTEGER, chr VARCHAR(10), next_state INTEGER);
INSERT INTO rules VALUES
  (1, 'a', 2), (1, 'b', 1),
  (2, 'a', 2), (2, 'b', 3),
  (3, 'a', 3), (3, 'b', 3);

CREATE TABLE accept_states (state INTEGER, accepted BOOLEAN);
INSERT INTO accept_states VALUES (1, false), (2, false), (3, true);

CREATE TABLE inputs (str TEXT);
INSERT INTO inputs VALUES ('a'), ('baa'), ('baba');

WITH RECURSIVE dfa(source, state, work) AS (
  SELECT
    inputs.str, 1, inputs.str
  FROM
    inputs
  UNION ALL
  SELECT
    source,
    next_rules.next_state,
    SUBSTR(dfa.work, 2, 10)
  FROM
    dfa JOIN (SELECT * FROM rules) AS next_rules ON dfa.state = next_rules.state
  WHERE
    chr = SUBSTR(dfa.work, 1, 1)
)
SELECT
  source,
  accepted
FROM
  dfa JOIN accept_states ON dfa.state = accept_states.state
WHERE
  work = '';

DROP TABLE rules;
DROP TABLE accept_states;
DROP TABLE inputs;
