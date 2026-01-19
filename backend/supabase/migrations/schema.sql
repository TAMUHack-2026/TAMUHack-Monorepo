-- Initial database schema setup
-- All tables are created in the default public schema
-- This is to reduce friction when migrating to Supabase

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}$'),
    password_hash TEXT NOT NULL,
);

CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age SMALLINT NOT NULL CHECK (age >= 0 AND age <= 150),
    sex TEXT NOT NULL CHECK (sex IN ('male', 'female')),
    gender_identity TEXT,
    height_in NUMERIC(4, 2) NOT NULL,
    weight_lbs NUMERIC(5, 2) NOT NULL CHECK (weight_lbs > 0),
);
