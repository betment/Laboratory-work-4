/* Видалення таблиць з каскадним видаленням можливих описів цілісності */
DROP TABLE IF EXISTS CompositionInstrumentUsage CASCADE;
DROP TABLE IF EXISTS UserInstrumentSelection CASCADE;
DROP TABLE IF EXISTS FinancialGoals CASCADE;
DROP TABLE IF EXISTS FinancialRecommendations CASCADE;
DROP TABLE IF EXISTS FinancialData CASCADE;
DROP TABLE IF EXISTS PotentialProfit CASCADE;
DROP TABLE IF EXISTS Budget CASCADE;
DROP TABLE IF EXISTS MusicalComposition CASCADE;
DROP TABLE IF EXISTS MusicalInstrument CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;

/* Створення ENUM типів для PostgreSQL */
CREATE TYPE priority_level AS ENUM ('High', 'Medium', 'Low');
CREATE TYPE goal_status AS ENUM ('Active', 'Achieved', 'Cancelled', 'Suspended');

/* Створення таблиці User */
CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    useremail VARCHAR(255) NOT NULL UNIQUE,
    userregistration_date DATE NOT NULL,
    
    -- Обмеження довжини для username
    CONSTRAINT user_username_length CHECK (LENGTH(username) <= 100 AND LENGTH(username) > 0),
    
    -- Обмеження формату email (регулярний вираз)
    CONSTRAINT user_email_format CHECK (
        useremail ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ),
    
    -- Обмеження дати реєстрації
    CONSTRAINT user_registration_date_check CHECK (userregistration_date <= CURRENT_DATE)
);

/* Створення таблиці MusicalInstrument */
CREATE TABLE MusicalInstrument (
    instrument_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(30) NOT NULL,
    sound_characteristics TEXT,
    
    -- Обмеження довжини
    CONSTRAINT instrument_name_length CHECK (LENGTH(name) <= 50 AND LENGTH(name) > 0),
    CONSTRAINT instrument_type_length CHECK (LENGTH(type) <= 30 AND LENGTH(type) > 0),
    CONSTRAINT instrument_sound_length CHECK (sound_characteristics IS NULL OR LENGTH(sound_characteristics) <= 500),
    
    -- Обмеження типу інструменту (регулярний вираз)
    CONSTRAINT instrument_type_format CHECK (
        type ~* '^[a-zA-Zа-яА-ЯіІїЇєЄ ]+$'
    )
);

/* Створення таблиці MusicalComposition */
CREATE TABLE MusicalComposition (
    composition_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    duration INTEGER NOT NULL,
    creation_date DATE NOT NULL,
    genre VARCHAR(50) NOT NULL,
    
    -- Обмеження довжини
    CONSTRAINT composition_title_length CHECK (LENGTH(title) <= 100 AND LENGTH(title) > 0),
    CONSTRAINT composition_genre_length CHECK (LENGTH(genre) <= 50 AND LENGTH(genre) > 0),
    
    -- Обмеження тривалості
    CONSTRAINT composition_duration_range CHECK (duration > 0 AND duration <= 7200),
    
    -- Обмеження дати створення
    CONSTRAINT composition_creation_date_check CHECK (creation_date <= CURRENT_DATE)
);

/* Створення таблиці PotentialProfit */
CREATE TABLE PotentialProfit (
    profit_id SERIAL PRIMARY KEY,
    composition_id INTEGER NOT NULL REFERENCES MusicalComposition(composition_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    distribution_channels VARCHAR(200) NOT NULL,
    calculation_date DATE NOT NULL,
    
    -- Обмеження суми
    CONSTRAINT profit_amount_check CHECK (amount >= 0),
    
    -- Обмеження валюти
    CONSTRAINT profit_currency_format CHECK (LENGTH(currency) = 3 AND currency ~ '^[A-Z]{3}$'),
    
    -- Обмеження довжини каналів розподілу
    CONSTRAINT profit_channels_length CHECK (LENGTH(distribution_channels) <= 200 AND LENGTH(distribution_channels) > 0),
    
    -- Обмеження дати розрахунку
    CONSTRAINT profit_calculation_date_check CHECK (calculation_date <= CURRENT_DATE)
);

/* Створення таблиці Budget */
CREATE TABLE Budget (
    budget_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    total_amount DECIMAL(12,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    update_date DATE NOT NULL,
    
    -- Обмеження суми
    CONSTRAINT budget_amount_check CHECK (total_amount >= 0),
    
    -- Обмеження валюти
    CONSTRAINT budget_currency_format CHECK (LENGTH(currency) = 3 AND currency ~ '^[A-Z]{3}$'),
    
    -- Обмеження дати оновлення
    CONSTRAINT budget_update_date_check CHECK (update_date <= CURRENT_DATE)
);

/* Створення таблиці FinancialData */
CREATE TABLE FinancialData (
    financial_data_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    budget_id INTEGER NOT NULL REFERENCES Budget(budget_id) ON DELETE CASCADE,
    income DECIMAL(12,2) NOT NULL,
    expenses DECIMAL(12,2) NOT NULL,
    balance DECIMAL(12,2) NOT NULL,
    period VARCHAR(20) NOT NULL,
    
    -- Обмеження сум
    CONSTRAINT financial_data_income_check CHECK (income >= 0),
    CONSTRAINT financial_data_expenses_check CHECK (expenses >= 0),
    
    -- Обмеження довжини періоду
    CONSTRAINT financial_data_period_length CHECK (LENGTH(period) <= 20 AND LENGTH(period) > 0)
);

/* Створення таблиці FinancialRecommendations */
CREATE TABLE FinancialRecommendations (
    recommendation_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    financial_data_id INTEGER NOT NULL REFERENCES FinancialData(financial_data_id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority priority_level NOT NULL,
    creation_date DATE NOT NULL,
    
    -- Обмеження довжини
    CONSTRAINT recommendations_description_length CHECK (LENGTH(description) <= 1000 AND LENGTH(description) > 0),
    CONSTRAINT recommendations_type_length CHECK (LENGTH(type) <= 50 AND LENGTH(type) > 0),
    
    -- Обмеження дати створення
    CONSTRAINT recommendations_creation_date_check CHECK (creation_date <= CURRENT_DATE)
);

/* Створення таблиці FinancialGoals */
CREATE TABLE FinancialGoals (
    goal_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    description VARCHAR(200) NOT NULL,
    target_amount DECIMAL(12,2) NOT NULL,
    deadline DATE NOT NULL,
    status goal_status NOT NULL,
    
    -- Обмеження довжини опису
    CONSTRAINT goals_description_length CHECK (LENGTH(description) <= 200 AND LENGTH(description) > 0),
    
    -- Обмеження суми
    CONSTRAINT goals_target_amount_check CHECK (target_amount > 0),
    
    -- Обмеження дедлайну
    CONSTRAINT goals_deadline_check CHECK (deadline > CURRENT_DATE)
);

/* Створення таблиці UserInstrumentSelection */
CREATE TABLE UserInstrumentSelection (
    selection_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    instrument_id INTEGER NOT NULL REFERENCES MusicalInstrument(instrument_id) ON DELETE CASCADE,
    selection_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Унікальне обмеження для комбінації користувач-інструмент
    CONSTRAINT user_instrument_unique UNIQUE (user_id, instrument_id)
);

/* Створення таблиці CompositionInstrumentUsage */
CREATE TABLE CompositionInstrumentUsage (
    usage_id SERIAL PRIMARY KEY,
    composition_id INTEGER NOT NULL REFERENCES MusicalComposition(composition_id) ON DELETE CASCADE,
    instrument_id INTEGER NOT NULL REFERENCES MusicalInstrument(instrument_id) ON DELETE CASCADE,
    usage_details TEXT,
    
    -- Обмеження довжини деталей використання
    CONSTRAINT composition_instrument_details_length CHECK (usage_details IS NULL OR LENGTH(usage_details) <= 500),
    
    -- Унікальне обмеження для комбінації композиція-інструмент
    CONSTRAINT composition_instrument_unique UNIQUE (composition_id, instrument_id)
);

/* Створення індексів для поліпшення продуктивності */
CREATE INDEX idx_user_email ON "User"(useremail);
CREATE INDEX idx_composition_user ON MusicalComposition(user_id);
CREATE INDEX idx_composition_creation_date ON MusicalComposition(creation_date);
CREATE INDEX idx_budget_user ON Budget(user_id);
CREATE INDEX idx_financial_data_user ON FinancialData(user_id);
CREATE INDEX idx_financial_data_budget ON FinancialData(budget_id);
CREATE INDEX idx_recommendations_user ON FinancialRecommendations(user_id);
CREATE INDEX idx_goals_user ON FinancialGoals(user_id);
CREATE INDEX idx_goals_deadline ON FinancialGoals(deadline);

/* Коментарі до таблиць */
COMMENT ON TABLE "User" IS 'Таблиця користувачів системи';
COMMENT ON TABLE MusicalInstrument IS 'Таблиця музичних інструментів';
COMMENT ON TABLE MusicalComposition IS 'Таблиця музичних композицій';
COMMENT ON TABLE PotentialProfit IS 'Таблиця потенційного прибутку від композицій';
COMMENT ON TABLE Budget IS 'Таблиця бюджетів користувачів';
COMMENT ON TABLE FinancialData IS 'Таблиця фінансових даних';
COMMENT ON TABLE FinancialRecommendations IS 'Таблиця фінансових рекомендацій';
COMMENT ON TABLE FinancialGoals IS 'Таблиця фінансових цілей';
COMMENT ON TABLE UserInstrumentSelection IS 'Таблиця вибору інструментів користувачами';
COMMENT ON TABLE CompositionInstrumentUsage IS 'Таблиця використання інструментів у композиціях';
