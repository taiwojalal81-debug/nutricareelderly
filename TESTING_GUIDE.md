# 🚀 NutriCare Testing Guide - Phase 1 Complete

## Current Status
- ✅ **Backend**: Fully built (9 database tables, Supabase integration)
- ✅ **Frontend**: 5 screens + ProfileScreen complete, 0 compilation errors
- ✅ **Android Setup**: SDK 16.0 installed, phone connected (SM N986U1)
- ⏳ **App Build**: Currently compiling to phone (first build)

---

## 📋 CRITICAL: Before Testing

### 1. Add Medical Conditions to Supabase (MUST DO FIRST!)

**File:** `supabase_insert_conditions.sql` (already in your project)

Steps:
1. Go to https://supabase.com
2. Login to your NutriCare project
3. Click **SQL Editor** (left sidebar)
4. Click **New Query**
5. Copy entire content from `supabase_insert_conditions.sql`
6. Paste into Supabase SQL Editor
7. Click **Run**
8. Verify: Should show **"10 rows inserted"**

**Why?** Without this, ProfileScreen will show empty condition list.

---

## 🎮 Testing Workflow

### Phase 1: Authentication
1. **Launch App**
   - Should see Splash screen with fade animation
   - After 3 seconds → Login screen

2. **Test Registration**
   - Click "Don't have an account? Register"
   - Fill form:
     ```
     First Name: Chukwu
     Last Name: Okafor
     Age: 65
     Email: test@nutricare.com
     Password: Test123456
     Confirm: Test123456
     ```
   - Click Register
   - ✅ Should navigate to Login screen
   - ✅ Check Supabase: users table should have new user

3. **Test Login**
   - Use credentials from above
   - Click Login
   - ✅ Should navigate to Home screen

### Phase 2: Home Screen
1. **Greeting Card**
   - ✅ Should show "Good Morning, Chukwu! 👋"
   - ✅ Message: "Let's take care of your health today"

2. **Health Status Cards**
   - ✅ Should show 4 cards: BMI, Blood Type, Weight, Allergies
   - ✅ Values should be "N/A" or default (first login)

3. **Navigation Icons**
   - ✅ Notifications icon → "No new notifications"
   - ✅ **Person icon** → Opens ProfileScreen
   - ✅ Logout icon → Returns to Login

4. **Pull to Refresh**
   - ✅ Drag down on home screen
   - ✅ Should refresh all providers

### Phase 3: Profile Screen (NEW!)
1. **Conditions List**
   - ✅ Should show all 10 conditions:
     - Diabetes Type 2
     - Hypertension
     - Arthritis & Joint Pain
     - Heart Disease
     - High Cholesterol
     - Kidney Disease
     - Anemia
     - Asthma & Respiratory Issues
     - Stroke/CVA Risk
     - Thyroid Disease

2. **Select Conditions**
   - ✅ Tap 2-3 conditions (checkboxes should highlight)
   - ✅ Each shows dietary restrictions + nutrition focus

3. **Save Conditions**
   - ✅ Tap "Save Health Conditions"
   - ✅ Should show "Health conditions saved successfully!"
   - ✅ Should return to Home screen
   - ✅ Check Supabase: user_conditions table should have entries

### Phase 4: Weight Screen
1. **Log Weight**
   - Navigate to Weight (bottom nav)
   - Click "Log Weight"
   - Enter: 75 kg
   - Note: "Morning weight"
   - Click Save
   - ✅ Should show weight saved
   - ✅ Latest weight card should update
   - ✅ Check Supabase: weight_records table

2. **View History**
   - ✅ Should show past weights in list
   - ✅ Can scroll through history

### Phase 5: Meals Screen
1. **View Recommendations**
   - Navigate to Meals (bottom nav)
   - ✅ Should show meals customized for your conditions
   - ✅ Meals should reflect dietary restrictions
   - Example: If you selected Diabetes, meals should have low sugar

2. **Filter Meals**
   - ✅ Click "All" / "Breakfast" / "Lunch" / etc.
   - ✅ Should filter meals by type

3. **Nutrition Summary**
   - ✅ Should show total calories, protein, carbs, fat
   - ✅ Values should change based on selected meals

---

## 🧪 Data Verification in Supabase

After each test, verify data in Supabase:

### Check Users Table
```sql
SELECT * FROM users WHERE email = 'test@nutricare.com';
```
- ✅ Should have 1 row with your user

### Check User Conditions
```sql
SELECT * FROM user_conditions WHERE user_id = '[your_user_id]';
```
- ✅ Should have 2-3 rows (conditions you selected)

### Check Weight Records
```sql
SELECT * FROM weight_records WHERE user_id = '[your_user_id]' ORDER BY created_at DESC LIMIT 5;
```
- ✅ Should have weight entries you logged

### Check Health Profile
```sql
SELECT * FROM health_profiles WHERE user_id = '[your_user_id]';
```
- ✅ Should have 1 row with your profile data

---

## 🐛 Troubleshooting

### Issue: "App crashes on startup"
**Solution:**
- Check logs: `flutter logs`
- Likely: Supabase credentials missing or invalid
- Fix: Verify .env or constants have correct Supabase URL/key

### Issue: "Empty condition list in ProfileScreen"
**Solution:**
- **Supabase conditions table is empty**
- Run the SQL file immediately!
- Verify in Supabase: SELECT COUNT(*) FROM conditions;

### Issue: "Login fails with 'Invalid credentials'"
**Solution:**
- Email/password incorrect
- Or Supabase authentication not configured
- Check Supabase Auth settings

### Issue: "White screen after registration"
**Solution:**
- App waiting for Supabase connection
- Wait 10 seconds
- Or check internet connection

### Issue: "Profile data not showing"
**Solution:**
- Health profile not created during registration
- Restart app and register again

---

## 📊 Testing Checklist

- [ ] Conditions added to Supabase (SQL run)
- [ ] App launches on phone
- [ ] Registration works
- [ ] Login works
- [ ] Home screen shows greeting
- [ ] Health cards display
- [ ] Profile screen shows 10 conditions
- [ ] Can select conditions and save
- [ ] Weight logging works
- [ ] Meals screen shows recommendations
- [ ] Data persists in Supabase

---

## 🎯 After Phase 1 Testing Complete

Once all tests pass:

1. **Report Results**
   - Tell me which tests passed/failed
   - Screenshot of app running

2. **Phase 2 Features** (Ready to build)
   - ReportsScreen (analytics & trends)
   - Medication tracking
   - Drug-food interaction warnings
   - More medical conditions (50+)

3. **Phase 3 Features** (Future)
   - External APIs (symptom recognition)
   - Offline caching
   - Dark mode
   - User customization

---

## 📞 Support

**If app won't launch:**
1. Check terminal output for errors
2. Run: `flutter logs`
3. Report error message

**If features don't work:**
1. Check Supabase dashboard
2. Verify row-level security policies
3. Check network connectivity

---

## ✨ You're All Set!

Your app is ready for real-world testing. Once it launches:
1. Follow testing workflow
2. Report any bugs or issues
3. We'll iterate and improve

Good luck! 🚀
