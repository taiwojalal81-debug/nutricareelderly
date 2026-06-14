-- NutriCare Elderly - Complete Database Schema
-- Paste this into Supabase SQL Editor

-- ============================================================================
-- TABLE: profiles
-- ============================================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  age INT NOT NULL CHECK (age >= 18),
  phone VARCHAR(20),
  gender VARCHAR(10),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_profiles_user_id ON profiles(user_id);

-- ============================================================================
-- TABLE: health_profiles
-- ============================================================================
CREATE TABLE health_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  weight_kg DECIMAL(5,2) NOT NULL CHECK (weight_kg > 0),
  height_cm INT NOT NULL CHECK (height_cm > 0),
  bmi DECIMAL(5,2) GENERATED ALWAYS AS (weight_kg / ((height_cm/100.0) * (height_cm/100.0))) STORED,
  bmi_category VARCHAR(20),
  blood_type VARCHAR(5),
  allergies TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_health_profiles_user_id ON health_profiles(user_id);

-- ============================================================================
-- TABLE: conditions
-- ============================================================================
CREATE TABLE conditions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  condition_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  dietary_restrictions TEXT,
  nutrition_focus TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Seed Data
INSERT INTO conditions (condition_name, description, dietary_restrictions, nutrition_focus) VALUES
('Diabetes Type 2', 'High blood sugar management', 'Reduce refined sugars, control carbs', 'Complex carbs, fiber, lean protein'),
('Hypertension', 'High blood pressure', 'Low sodium, limit processed foods', 'Potassium, magnesium, calcium-rich foods'),
('Osteoarthritis', 'Joint inflammation', 'Avoid inflammatory foods', 'Omega-3s, antioxidants, vitamin D'),
('Obesity', 'Weight management needed', 'Caloric control, reduce fatty foods', 'Protein, whole grains, vegetables'),
('Hyperlipidemia', 'High cholesterol', 'Low saturated fats, no trans fats', 'Fiber, plant sterols, omega-3s');

-- ============================================================================
-- TABLE: user_conditions
-- ============================================================================
CREATE TABLE user_conditions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  condition_id UUID NOT NULL REFERENCES conditions(id),
  diagnosed_date DATE,
  severity VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, condition_id)
);

CREATE INDEX idx_user_conditions_user_id ON user_conditions(user_id);

-- ============================================================================
-- TABLE: medications
-- ============================================================================
CREATE TABLE medications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  medication_name VARCHAR(200) NOT NULL,
  dosage VARCHAR(100),
  frequency VARCHAR(100),
  prescribed_date DATE,
  reason VARCHAR(200),
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_medications_user_id ON medications(user_id);
CREATE INDEX idx_medications_active ON medications(active);

-- ============================================================================
-- TABLE: drug_interactions
-- ============================================================================
CREATE TABLE drug_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_name_1 VARCHAR(200) NOT NULL,
  medication_name_2 VARCHAR(200) NOT NULL,
  interaction_type VARCHAR(50),
  description TEXT,
  recommendation TEXT,
  severity INT DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(medication_name_1, medication_name_2)
);

INSERT INTO drug_interactions (medication_name_1, medication_name_2, interaction_type, description, recommendation, severity) VALUES
('Metformin', 'Lisinopril', 'moderate', 'May affect kidney function', 'Monitor renal function regularly', 2),
('Aspirin', 'Warfarin', 'contraindicated', 'Increased bleeding risk', 'Use alternative antiplatelet if possible', 3),
('Ibuprofen', 'Lisinopril', 'moderate', 'Reduces antihypertensive effect', 'Consider paracetamol instead', 2);

-- ============================================================================
-- TABLE: food_drug_interactions
-- ============================================================================
CREATE TABLE food_drug_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_name VARCHAR(200) NOT NULL,
  food_name VARCHAR(200) NOT NULL,
  interaction_type VARCHAR(50),
  description TEXT,
  recommendation TEXT,
  severity INT DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(medication_name, food_name)
);

INSERT INTO food_drug_interactions (medication_name, food_name, interaction_type, description, recommendation, severity) VALUES
('Warfarin', 'Spinach', 'monitor', 'High vitamin K reduces warfarin effectiveness', 'Maintain consistent intake', 2),
('Metformin', 'Alcohol', 'avoid', 'Increases lactic acidosis risk', 'Avoid alcohol', 3),
('Lisinopril', 'Bananas', 'monitor', 'May cause hyperkalemia', 'Moderate consumption', 2),
('Lisinopril', 'Salt substitutes', 'reduce', 'High potassium content', 'Use regular salt', 2);

-- ============================================================================
-- TABLE: nigerian_foods
-- ============================================================================
CREATE TABLE nigerian_foods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  food_name VARCHAR(200) NOT NULL UNIQUE,
  description TEXT,
  portion_size_grams INT,
  calories_per_portion DECIMAL(8,2),
  protein_g DECIMAL(5,2),
  carbs_g DECIMAL(5,2),
  fat_g DECIMAL(5,2),
  fiber_g DECIMAL(5,2),
  potassium_mg INT,
  sodium_mg INT,
  suitable_for_conditions TEXT,
  meal_category VARCHAR(50),
  image_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO nigerian_foods (food_name, description, portion_size_grams, calories_per_portion, protein_g, carbs_g, fat_g, fiber_g, potassium_mg, sodium_mg, suitable_for_conditions, meal_category) VALUES
('Jollof Rice', 'Tomato-based rice dish', 250, 285, 5, 42, 8, 2, 180, 450, 'Obesity,Diabetes', 'lunch'),
('Beans and Plantain', 'Boiled beans with fried plantain', 300, 320, 9, 48, 10, 7, 380, 200, 'Diabetes,Hypertension', 'lunch'),
('Vegetable Soup', 'Leafy green soup with herbs', 200, 85, 4, 8, 3, 3, 420, 250, 'Hypertension,Osteoarthritis', 'lunch'),
('Pounded Yam', 'Boiled yam pounded smooth', 200, 220, 3, 50, 0.5, 3, 350, 50, 'Obesity', 'lunch'),
('Egg Fried Rice', 'Rice with scrambled eggs', 250, 305, 10, 38, 12, 2, 150, 380, 'Diabetes', 'lunch'),
('Akamu', 'Traditional breakfast porridge', 200, 165, 2, 35, 2, 1, 100, 400, 'Obesity,Diabetes', 'breakfast'),
('Moi Moi', 'Steamed bean pudding', 150, 195, 12, 15, 8, 4, 290, 350, 'Hypertension', 'lunch'),
('Coleslaw', 'Shredded cabbage salad', 100, 45, 1, 8, 1.5, 2, 180, 120, 'Obesity,Hypertension', 'snack'),
('Fish Pepper Soup', 'Light fish soup with spices', 250, 120, 18, 5, 2, 1, 280, 380, 'Hypertension,Osteoarthritis', 'lunch'),
('Sweet Potato', 'Boiled orange sweet potato', 150, 130, 2, 29, 0.1, 4, 240, 55, 'Obesity,Diabetes', 'snack'),
('Fufu', 'Pounded cassava and plantain', 200, 260, 2, 58, 0.5, 4, 320, 80, 'Obesity', 'lunch'),
('Okra Soup', 'Okra with tomatoes and peppers', 220, 95, 3, 12, 4, 3, 350, 220, 'Diabetes,Hypertension', 'lunch'),
('Egusi Soup', 'Melon seed soup with vegetables', 250, 180, 8, 10, 12, 2, 280, 350, 'Hypertension', 'lunch'),
('Gari and Soup', 'Cassava granules with light soup', 280, 195, 5, 38, 3, 2, 200, 300, 'Obesity,Diabetes', 'lunch'),
('Fried Plantain', 'Golden fried plantain slices', 150, 210, 1, 45, 8, 2, 280, 100, 'Obesity', 'snack'),
('Boiled Corn', 'Whole corn kernels boiled', 150, 155, 5, 30, 2, 4, 190, 40, 'Diabetes,Obesity', 'snack'),
('Tomato Stew', 'Tomato-based stew', 200, 110, 4, 8, 6, 2, 220, 280, 'Hypertension', 'lunch'),
('Yam Porridge', 'Boiled yam in light broth', 250, 185, 3, 40, 1, 3, 310, 180, 'Diabetes', 'lunch'),
('Waterleaf Soup', 'Leafy soup with lean meat', 220, 75, 6, 5, 3, 2, 380, 150, 'Hypertension,Osteoarthritis', 'lunch'),
('Brown Rice', 'Whole grain brown rice', 150, 145, 3, 30, 1.5, 4, 160, 5, 'Diabetes,Obesity', 'lunch');

CREATE INDEX idx_nigerian_foods_meal_category ON nigerian_foods(meal_category);

-- ============================================================================
-- TABLE: dietary_advice_rules
-- ============================================================================
CREATE TABLE dietary_advice_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  condition_id UUID NOT NULL REFERENCES conditions(id),
  rule_name VARCHAR(200) NOT NULL,
  rule_description TEXT,
  nutrition_advice TEXT,
  foods_to_avoid TEXT,
  foods_to_include TEXT,
  daily_calorie_target INT,
  max_sodium_mg INT,
  max_sugar_g INT,
  min_fiber_g INT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- TABLE: meals
-- ============================================================================
CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meal_date DATE NOT NULL,
  meal_type VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, meal_date, meal_type)
);

CREATE INDEX idx_meals_user_id_date ON meals(user_id, meal_date);

-- ============================================================================
-- TABLE: meal_items
-- ============================================================================
CREATE TABLE meal_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
  food_id UUID NOT NULL REFERENCES nigerian_foods(id),
  quantity_grams INT DEFAULT 100,
  calories DECIMAL(8,2),
  protein_g DECIMAL(5,2),
  carbs_g DECIMAL(5,2),
  fat_g DECIMAL(5,2),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_meal_items_meal_id ON meal_items(meal_id);

-- ============================================================================
-- TABLE: meal_recommendations
-- ============================================================================
CREATE TABLE meal_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meal_date DATE NOT NULL,
  breakfast_recommendation TEXT,
  lunch_recommendation TEXT,
  dinner_recommendation TEXT,
  daily_advice TEXT,
  warnings TEXT,
  bmi_advice TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, meal_date)
);

CREATE INDEX idx_meal_recommendations_user_id_date ON meal_recommendations(user_id, meal_date);

-- ============================================================================
-- TABLE: weight_records
-- ============================================================================
CREATE TABLE weight_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  weight_kg DECIMAL(5,2) NOT NULL,
  recorded_date DATE NOT NULL DEFAULT CURRENT_DATE,
  bmi DECIMAL(5,2),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, recorded_date)
);

CREATE INDEX idx_weight_records_user_id_date ON weight_records(user_id, recorded_date);

-- ============================================================================
-- ROW-LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_conditions ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE weight_records ENABLE ROW LEVEL SECURITY;

-- Profiles RLS
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Health Profiles RLS
CREATE POLICY "Users can view own health profile" ON health_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own health profile" ON health_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own health profile" ON health_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User Conditions RLS
CREATE POLICY "Users can view own conditions" ON user_conditions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own conditions" ON user_conditions
  FOR ALL USING (auth.uid() = user_id);

-- Medications RLS
CREATE POLICY "Users can view own medications" ON medications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own medications" ON medications
  FOR ALL USING (auth.uid() = user_id);

-- Weight Records RLS
CREATE POLICY "Users can view own weight records" ON weight_records
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own weight records" ON weight_records
  FOR ALL USING (auth.uid() = user_id);

-- Meal Recommendations RLS
CREATE POLICY "Users can view own meal recommendations" ON meal_recommendations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own meal recommendations" ON meal_recommendations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Meals RLS
CREATE POLICY "Users can view own meals" ON meals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own meals" ON meals
  FOR ALL USING (auth.uid() = user_id);

-- Meal Items RLS (through meal relationship)
CREATE POLICY "Users can view own meal items" ON meal_items
  FOR SELECT USING (
    meal_id IN (SELECT id FROM meals WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can manage own meal items" ON meal_items
  FOR ALL USING (
    meal_id IN (SELECT id FROM meals WHERE user_id = auth.uid())
  );

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Function: Update BMI category
CREATE OR REPLACE FUNCTION update_bmi_category()
RETURNS TRIGGER AS $$
BEGIN
  NEW.bmi_category := CASE
    WHEN NEW.bmi < 18.5 THEN 'Underweight'
    WHEN NEW.bmi < 25 THEN 'Normal'
    WHEN NEW.bmi < 30 THEN 'Overweight'
    ELSE 'Obese'
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_bmi_category
  BEFORE INSERT OR UPDATE ON health_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_bmi_category();

-- Function: Update timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_profiles_timestamp
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_health_profiles_timestamp
  BEFORE UPDATE ON health_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_update_medications_timestamp
  BEFORE UPDATE ON medications
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: User health summary
CREATE OR REPLACE VIEW user_health_summary AS
SELECT
  p.user_id,
  p.first_name,
  p.last_name,
  hp.weight_kg,
  hp.height_cm,
  hp.bmi,
  hp.bmi_category,
  ARRAY_AGG(DISTINCT c.condition_name) as conditions,
  (SELECT COUNT(*) FROM medications WHERE user_id = p.user_id AND active = TRUE) as active_medications
FROM profiles p
LEFT JOIN health_profiles hp ON p.user_id = hp.user_id
LEFT JOIN user_conditions uc ON p.user_id = uc.user_id
LEFT JOIN conditions c ON uc.condition_id = c.id
GROUP BY p.user_id, p.first_name, p.last_name, hp.weight_kg, hp.height_cm, hp.bmi, hp.bmi_category;

-- View: User medication interactions
CREATE OR REPLACE VIEW user_medication_interactions AS
SELECT DISTINCT
  m.user_id,
  m.medication_name,
  di.medication_name_2 as interacting_medication,
  di.interaction_type,
  di.description,
  di.recommendation,
  di.severity
FROM medications m
LEFT JOIN drug_interactions di ON m.medication_name = di.medication_name_1
WHERE m.active = TRUE;

-- View: User food-drug interactions
CREATE OR REPLACE VIEW user_food_interactions AS
SELECT DISTINCT
  m.user_id,
  m.medication_name,
  fdi.food_name,
  fdi.interaction_type,
  fdi.description,
  fdi.recommendation,
  fdi.severity
FROM medications m
LEFT JOIN food_drug_interactions fdi ON m.medication_name = fdi.medication_name
WHERE m.active = TRUE;

-- ============================================================================
-- ADDITIONAL INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_conditions_name ON conditions(condition_name);
CREATE INDEX idx_medications_name ON medications(medication_name);
CREATE INDEX idx_drug_interactions_med1_med2 ON drug_interactions(medication_name_1, medication_name_2);
CREATE INDEX idx_food_interactions_med_food ON food_drug_interactions(medication_name, food_name);
CREATE INDEX idx_weight_records_date ON weight_records(recorded_date);
CREATE INDEX idx_meals_date ON meals(meal_date);
