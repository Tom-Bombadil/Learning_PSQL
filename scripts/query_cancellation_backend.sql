SELECT * FROM pg_stat_activity;

SELECT pg_cancel_backend(pid#);