# 365 Potential & Habit Tracker (Flutter + Supabase)

A responsive, cross-platform Daily Potential & Habit Tracking application built with **Flutter 3.x**, **Dart**, **Supabase (PostgreSQL + RLS)**, **Riverpod**, and **fl_chart**.

---

## Features

1. **Retroactive Morning Review (`Current Date - 1`)**:
   - The review date automatically initializes to `DateTime.now().subtract(const Duration(days: 1))`.
   - Date picker allows toggling to any past date.
2. **Smart Conditional Validation**:
   - **Sleep Tracker**: Input accepts a float. Marked passed ONLY if `7.0 <= sleep_hours <= 8.5`.
   - **Focus Split**: Study (`>= 2.0h`), Work (`>= 4.0h`), and Learn (`>= 1.0h`) time blocks.
   - **Dynamic Habit Types**: Supports `boolean`, `numeric_range`, `numeric_min`, and `numeric_max`.
3. **Live Sticky Scoring Engine**:
   - On-the-fly calculation of $\text{Percentage} = (\text{Passed} / \text{Total}) \times 100\%$.
   - Sticky header renders both the fraction (`X / Total`) and percentage (`XX.X%`).
4. **Analytics & Graphing Dashboard (`fl_chart`)**:
   - Dropdown filter: `Overall Potential (%)`, `Sleep Duration (Hours)`, `Study Time`, `Work Time`, `Learn Time`.
   - Timeframe toggles: `7 Days`, `30 Days`, `365 Days`.
   - Upward/downward trajectory indicator and threshold guidelines (80% streak target line, 7.0h/8.5h sleep lines).
5. **Dynamic Rule Management Modal**:
   - Add, rename, reorder, or disable habit rules without SQL.

---

## 1. Supabase Database Setup

1. Open your Supabase Project Dashboard -> **SQL Editor**.
2. Run the migration script located at [`supabase/migrations/20260829_init_schema.sql`](../supabase/migrations/20260829_init_schema.sql).
3. This creates:
   - `profiles`, `habits`, `daily_logs`, and `daily_habit_entries` tables.
   - Row Level Security (RLS) policies.
   - User signup trigger to automatically seed default habits.

---

## 2. Running the Flutter App

### Set Environment Variables:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Run on Web:
```bash
flutter run -d chrome
```

---

## 3. Vercel Web Deployment

The project includes [`vercel.json`](./vercel.json) for Single-Page Application (SPA) routing:

1. Connect your repository to **Vercel**.
2. **Framework Preset**: `Other`.
3. **Build Command**:
   ```bash
   if [ -d "flutter" ]; then cd flutter && git pull && cd ..; else git clone https://github.com/flutter/flutter.git --depth 1 -b stable; fi && export PATH="$PATH:`pwd`/flutter/bin" && flutter channel stable && flutter upgrade && flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
   ```
4. **Output Directory**: `flutter_app/build/web` (or `build/web` if root is `flutter_app`).
5. Set `SUPABASE_URL` and `SUPABASE_ANON_KEY` in Vercel Environment Variables.
