/* Видалення таблиць з каскадним видаленням можливих описів цілісності */
DROP TABLE IF EXISTS composition_instrument_usage CASCADE;
DROP TABLE IF EXISTS user_instrument_selection CASCADE;
DROP TABLE IF EXISTS financial_goals CASCADE;
DROP TABLE IF EXISTS financial_recommendations CASCADE;
DROP TABLE IF EXISTS financial_data CASCADE;
DROP TABLE IF EXISTS potential_profit CASCADE;
DROP TABLE IF EXISTS budget CASCADE;
DROP TABLE IF EXISTS musical_composition CASCADE;
DROP TABLE IF EXISTS musical_instrument CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

/* Створення ENUM типів для PostgreSQL */
CREATE TYPE priority_level AS ENUM ('High', 'Medium', 'Low');
CREATE TYPE goal_status AS ENUM ('Active', 'Achieved', 'Cancelled', 'Suspended');

/* Створення таблиці user */
CREATE TABLE "user" (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    useremail VARCHAR(255) NOT NULL UNIQUE,
    userregistration_date DATE NOT NULL,
    
    CONSTRAINT user_username_length CHECK (LENGTH(username) <= 100 AND LENGTH(username) > 0),
    CONSTRAINT user_email_format CHECK (
        useremail ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ),
    CONSTRAINT user_registration_date_check CHECK (userregistration_date <= CURRENT_DATE)
);

/* Створення таблиці musical_instrument */
CREATE TABLE musical_instrument (
    instrument_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(30) NOT NULL,
    sound_characteristics TEXT,
    
    CONSTRAINT instrument_name_length CHECK (LENGTH(name) <= 50 AND LENGTH(name) > 0),
    CONSTRAINT instrument_type_length CHECK (LENGTH(type) <= 30 AND LENGTH(type) > 0),
    CONSTRAINT instrument_sound_length CHECK (sound_characteristics IS NULL OR LENGTH(sound_characteristics) <= 500),
    CONSTRAINT instrument_type_format CHECK (
        type ~* '^[a-zA-Zа-яА-ЯіІїЇєЄ ]+$'
    )
);

/* Створення таблиці musical_composition */
CREATE TABLE musical_composition (
    composition_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    duration INTEGER NOT NULL,
    creation_date DATE NOT NULL,
    genre VARCHAR(50) NOT NULL,
    
    CONSTRAINT composition_title_length CHECK (LENGTH(title) <= 100 AND LENGTH(title) > 0),
    CONSTRAINT composition_genre_length CHECK (LENGTH(genre) <= 50 AND LENGTH(genre) > 0),
    CONSTRAINT composition_duration_range CHECK (duration > 0 AND duration <= 7200),
    CONSTRAINT composition_creation_date_check CHECK (creation_date <= CURRENT_DATE)
);

/* Створення таблиці potential_profit */
CREATE TABLE potential_profit (
    profit_id SERIAL PRIMARY KEY,
    composition_id INTEGER NOT NULL REFERENCES musical_composition(composition_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    distribution_channels VARCHAR(200) NOT NULL,
    calculation_date DATE NOT NULL,
    
    CONSTRAINT profit_amount_check CHECK (amount >= 0),
    CONSTRAINT profit_currency_format CHECK (LENGTH(currency) = 3 AND currency ~ '^[A-Z]{3}$'),
    CONSTRAINT profit_channels_length CHECK (LENGTH(distribution_channels) <= 200 AND LENGTH(distribution_channels) > 0),
    CONSTRAINT profit_calculation_date_check CHECK (calculation_date <= CURRENT_DATE)
);

/* Створення таблиці budget */
CREATE TABLE budget (
    budget_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    total_amount DECIMAL(12,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    update_date DATE NOT NULL,
    
    CONSTRAINT budget_amount_check CHECK (total_amount >= 0),
    CONSTRAINT budget_currency_format CHECK (LENGTH(currency) = 3 AND currency ~ '^[A-Z]{3}$'),
    CONSTRAINT budget_update_date_check CHECK (update_date <= CURRENT_DATE)
);

/* Створення таблиці financial_data */
CREATE TABLE financial_data (
    financial_data_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    budget_id INTEGER NOT NULL REFERENCES budget(budget_id) ON DELETE CASCADE,
    income DECIMAL(12,2) NOT NULL,
    expenses DECIMAL(12,2) NOT NULL,
    balance DECIMAL(12,2) NOT NULL,
    period VARCHAR(20) NOT NULL,
    
    CONSTRAINT financial_data_income_check CHECK (income >= 0),
    CONSTRAINT financial_data_expenses_check CHECK (expenses >= 0),
    CONSTRAINT financial_data_period_length CHECK (LENGTH(period) <= 20 AND LENGTH(period) > 0)
);

/* Створення таблиці financial_recommendations */
CREATE TABLE financial_recommendations (
    recommendation_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    financial_data_id INTEGER NOT NULL REFERENCES financial_data(financial_data_id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority priority_level NOT NULL,
    creation_date DATE NOT NULL,
    
    CONSTRAINT recommendations_description_length CHECK (LENGTH(description) <= 1000 AND LENGTH(description) > 0),
    CONSTRAINT recommendations_type_length CHECK (LENGTH(type) <= 50 AND LENGTH(type) > 0),
    CONSTRAINT recommendations_creation_date_check CHECK (creation_date <= CURRENT_DATE)
);

/* Створення таблиці financial_goals */
CREATE TABLE financial_goals (
    goal_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    description VARCHAR(200) NOT NULL,
    target_amount DECIMAL(12,2) NOT NULL,
    deadline DATE NOT NULL,
    status goal_status NOT NULL,
    
    CONSTRAINT goals_description_length CHECK (LENGTH(description) <= 200 AND LENGTH(description) > 0),
    CONSTRAINT goals_target_amount_check CHECK (target_amount > 0),
    CONSTRAINT goals_deadline_check CHECK (deadline > CURRENT_DATE)
);

/* Створення таблиці user_instrument_selection */
CREATE TABLE user_instrument_selection (
    selection_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    instrument_id INTEGER NOT NULL REFERENCES musical_instrument(instrument_id) ON DELETE CASCADE,
    selection_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    CONSTRAINT user_instrument_unique UNIQUE (user_id, instrument_id)
);

/* Створення таблиці composition_instrument_usage */
CREATE TABLE composition_instrument_usage (
    usage_id SERIAL PRIMARY KEY,
    composition_id INTEGER NOT NULL REFERENCES musical_composition(composition_id) ON DELETE CASCADE,
    instrument_id INTEGER NOT NULL REFERENCES musical_instrument(instrument_id) ON DELETE CASCADE,
    usage_details TEXT,
    
    CONSTRAINT composition_instrument_details_length CHECK (usage_details IS NULL OR LENGTH(usage_details) <= 500),
    CONSTRAINT composition_instrument_unique UNIQUE (composition_id, instrument_id)
);
