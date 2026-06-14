-- ============================================================================
-- NutriCare: Insert 10 Most Common Elderly Health Conditions
-- For: Supabase SQL Editor
-- Date: May 8, 2026
-- ============================================================================

-- Step 1: Clear existing conditions (optional - remove if you want to keep old data)
DELETE FROM conditions WHERE condition_name IN (
  'Diabetes Type 2',
  'Hypertension',
  'Arthritis & Joint Pain',
  'Heart Disease',
  'High Cholesterol',
  'Kidney Disease',
  'Anemia',
  'Asthma & Respiratory Issues',
  'Stroke/CVA Risk',
  'Thyroid Disease'
);

-- Step 2: Insert the 10 conditions
INSERT INTO conditions (condition_name, description, dietary_restrictions, nutrition_focus) VALUES

('Diabetes Type 2', 
 'Type 2 diabetes requiring dietary management and blood sugar control', 
 'Avoid refined sugars, limit simple carbohydrates, reduce sodium',
 'Complex carbs, whole grains, high fiber, lean proteins'),

('Hypertension', 
 'High blood pressure requiring sodium reduction and heart-healthy diet', 
 'Limit salt/sodium, reduce processed foods, limit saturated fats',
 'Potassium-rich foods, whole grains, lean proteins, fruits'),

('Arthritis & Joint Pain', 
 'Osteoarthritis requiring anti-inflammatory diet management', 
 'Limit inflammatory foods, reduce red meat, avoid fried foods',
 'Omega-3 fatty acids, fruits, vegetables, whole grains'),

('Heart Disease', 
 'Cardiovascular disease requiring heart-healthy dietary approach', 
 'Limit saturated fats, sodium, trans fats, red meat',
 'Lean proteins, whole grains, fruits, vegetables, omega-3s'),

('High Cholesterol', 
 'Hyperlipidemia requiring dietary lipid management', 
 'Limit saturated fats, trans fats, high-cholesterol foods',
 'Soluble fiber, lean proteins, whole grains, vegetable oils'),

('Kidney Disease', 
 'Chronic kidney disease requiring controlled nutrients', 
 'Limit sodium, potassium, phosphorus, protein (if advanced)',
 'Low sodium foods, limited potassium, lean proteins'),

('Anemia', 
 'Iron-deficiency anemia requiring iron and B12-rich foods', 
 'Limit foods that reduce iron absorption (too much tea/coffee)',
 'Iron-rich foods, leafy greens, lean meats, whole grains, citrus'),

('Asthma & Respiratory Issues', 
 'Asthma and COPD requiring anti-inflammatory diet support', 
 'Avoid food allergens, limit inflammatory foods',
 'Anti-inflammatory foods, omega-3s, fruits, vegetables, whole grains'),

('Stroke/CVA Risk', 
 'High stroke risk requiring cardiovascular health management', 
 'Limit sodium, saturated fats, cholesterol, processed foods',
 'Potassium-rich foods, whole grains, lean proteins, fruits, vegetables'),

('Thyroid Disease', 
 'Thyroid disorders requiring iodine and selenium management', 
 'Limit foods that interfere with thyroid (goitrogenic foods)',
 'Iodine-rich foods, selenium sources, lean proteins, whole grains');

-- ============================================================================
-- INSTRUCTIONS:
-- ============================================================================
-- 1. Go to Supabase Dashboard: https://supabase.com
-- 2. Select your NutriCare project
-- 3. Go to SQL Editor (left sidebar)
-- 4. Create new query
-- 5. Copy and paste this entire file content
-- 6. Click "Run" button
-- 7. You should see: "10 rows inserted successfully"
-- ============================================================================
