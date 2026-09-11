-- =========================================================================
-- CIVICSOLVE AI — COMPLETE SUPABASE DATABASE SCHEMA & SEED DATA
-- =========================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES (Users & Innovators)
CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  full_name TEXT NOT NULL,
  email TEXT UNIQUE,
  avatar_url TEXT,
  provider TEXT DEFAULT 'google',
  role TEXT DEFAULT 'student' CHECK (role IN ('student', 'university', 'mentor', 'admin')),
  university TEXT DEFAULT 'BIT Mesra',
  department TEXT DEFAULT 'Electronics & Communication',
  badge_level INTEGER DEFAULT 4,
  verified BOOLEAN DEFAULT false,
  email_verified BOOLEAN DEFAULT false,
  firebase_uid TEXT
);

-- 2. PROBLEMS (Citizen Ground Reports)
CREATE TABLE IF NOT EXISTS public.problems (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  reporter_id TEXT REFERENCES public.profiles(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  location TEXT NOT NULL,
  coordinates TEXT DEFAULT '23.36° N, 85.54° E',
  description TEXT NOT NULL,
  severity TEXT DEFAULT 'High' CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
  status TEXT DEFAULT 'pending_triage' CHECK (status IN ('submitted', 'pending_triage', 'ai_triaged', 'admin_approved', 'challenge_created', 'resolved')),
  evidence_urls TEXT[] DEFAULT '{}',
  ai_confidence NUMERIC DEFAULT 94.8
);

-- 3. CHALLENGES (Civic Challenges Marketplace & Dossiers)
CREATE TABLE IF NOT EXISTS public.challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  problem_id UUID REFERENCES public.problems(id) ON DELETE SET NULL,
  code TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  severity TEXT DEFAULT 'High Priority',
  location TEXT NOT NULL,
  coordinates TEXT DEFAULT '23.36° N, 85.54° E',
  description TEXT NOT NULL,
  tech_stack TEXT[] DEFAULT '{}',
  grant_amount INTEGER DEFAULT 75000,
  impact_score INTEGER DEFAULT 92,
  stage INTEGER DEFAULT 4,
  stage_name TEXT DEFAULT 'Teams Formed (Phase 4 of 7)',
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'claimed', 'in_progress', 'completed')),
  mentor_name TEXT DEFAULT 'Dr. S. K. Mukherjee',
  mentor_organization TEXT DEFAULT 'Tata Steel R&D',
  turbidity_ntu NUMERIC DEFAULT 42,
  tds_ppm NUMERIC DEFAULT 840,
  ph_level NUMERIC DEFAULT 6.1
);

-- 4. TEAMS (Student Contender Squads)
CREATE TABLE IF NOT EXISTS public.teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT now(),
  challenge_id UUID REFERENCES public.challenges(id) ON DELETE CASCADE,
  leader_id TEXT REFERENCES public.profiles(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  university TEXT NOT NULL,
  department TEXT,
  members_count INTEGER DEFAULT 4,
  progress_pct INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active' CHECK (status IN ('ideation', 'bench_test', 'active', 'completed')),
  rank INTEGER DEFAULT 1
);

-- 5. SPRINT_TASKS (Innovator Dashboard Tasks)
CREATE TABLE IF NOT EXISTS public.sprint_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT now(),
  user_id TEXT REFERENCES public.profiles(id) ON DELETE CASCADE,
  team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  priority TEXT DEFAULT 'High Priority',
  due_date TEXT DEFAULT 'Today',
  assigned_to TEXT DEFAULT 'Rahul Sharma',
  project_name TEXT DEFAULT 'AquaSense #S3',
  is_completed BOOLEAN DEFAULT false
);

-- 6. WATCHLISTS (Saved/Bookmarked Challenges)
CREATE TABLE IF NOT EXISTS public.watchlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT now(),
  user_id TEXT REFERENCES public.profiles(id) ON DELETE CASCADE,
  challenge_id UUID REFERENCES public.challenges(id) ON DELETE CASCADE,
  session_id TEXT
);

-- 7. NATIONAL_METRICS (Platform Aggregates)
CREATE TABLE IF NOT EXISTS public.national_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  problems_count INTEGER DEFAULT 12480,
  active_challenges_count INTEGER DEFAULT 2350,
  partner_universities_count INTEGER DEFAULT 186,
  industry_mentors_count INTEGER DEFAULT 420,
  grants_sanctioned_amount TEXT DEFAULT '₹1.4 Cr',
  ai_triage_accuracy NUMERIC DEFAULT 94.2
);

-- =========================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =========================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sprint_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.national_metrics ENABLE ROW LEVEL SECURITY;

-- Anonymous and Authenticated Read Access for Public Catalogues
CREATE POLICY "Public read profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Public read problems" ON public.problems FOR SELECT USING (true);
CREATE POLICY "Public read challenges" ON public.challenges FOR SELECT USING (true);
CREATE POLICY "Public read teams" ON public.teams FOR SELECT USING (true);
CREATE POLICY "Public read sprint_tasks" ON public.sprint_tasks FOR SELECT USING (true);
CREATE POLICY "Public read watchlists" ON public.watchlists FOR SELECT USING (true);
CREATE POLICY "Public read national_metrics" ON public.national_metrics FOR SELECT USING (true);

-- Insert Permissions
CREATE POLICY "Allow public insert problems" ON public.problems FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert sprint_tasks" ON public.sprint_tasks FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert watchlists" ON public.watchlists FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert teams" ON public.teams FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert challenges" ON public.challenges FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert profiles" ON public.profiles FOR INSERT WITH CHECK (true);

-- Update & Delete Permissions
CREATE POLICY "Allow public update sprint_tasks" ON public.sprint_tasks FOR UPDATE USING (true);
CREATE POLICY "Allow public delete sprint_tasks" ON public.sprint_tasks FOR DELETE USING (true);
CREATE POLICY "Allow public delete watchlists" ON public.watchlists FOR DELETE USING (true);
CREATE POLICY "Allow public update challenges" ON public.challenges FOR UPDATE USING (true);
CREATE POLICY "Allow public update problems" ON public.problems FOR UPDATE USING (true);
CREATE POLICY "Allow public update profiles" ON public.profiles FOR UPDATE USING (true);

-- =========================================================================
-- SEED INITIAL DATA (Matching UI Fidelity)
-- =========================================================================

-- Insert default user profile
INSERT INTO public.profiles (id, full_name, email, role, university, department, badge_level, verified)
VALUES 
  ('a0000000-0000-0000-0000-000000000001', 'Rahul Sharma', 'rahul.sharma@bitmesra.ac.in', 'student', 'BIT Mesra', 'Dept. of Electronics & Communication', 4, true)
ON CONFLICT (id) DO NOTHING;

-- Insert core seed challenges
INSERT INTO public.challenges (id, code, title, category, severity, location, description, tech_stack, grant_amount, impact_score, stage, stage_name, status, mentor_name, mentor_organization, turbidity_ntu, tds_ppm, ph_level)
VALUES 
  (
    'c0000000-0000-0000-0000-000000000001',
    'WT-09',
    'Smart Water Quality Telemetry & Contamination Tracer',
    'Water & Sanitation',
    'High Priority',
    'Ranchi, Jharkhand (Ward 14 & 18)',
    'Heavy industrial runoff infiltrating municipal piped drinking lines. Requires low-power battery spectrophotometric nodes transmitting via GSM/LoRa.',
    ARRAY['IoT', 'Embedded C', 'Python', 'Spectrometry', 'LoRaWAN'],
    75000,
    92,
    4,
    'Teams Formed (Phase 4 of 7)',
    'open',
    'Dr. S. K. Mukherjee',
    'Tata Steel R&D',
    42,
    840,
    6.1
  ),
  (
    'c0000000-0000-0000-0000-000000000002',
    'ENV-04',
    'Intelligent Waste Segregation & Circular Fleet Routing',
    'Solid Waste & Drainage',
    'Medium Priority',
    'Pune, Maharashtra (Smart City Zone)',
    'Unsegregated municipal dumps overloading processing plants. Build an edge-AI optical camera classifier mounted onto compactor hoppers for instant segregation audit.',
    ARRAY['Computer Vision', 'Edge AI', 'YOLOv8', 'Route Optimization'],
    60000,
    87,
    3,
    'Problem Scoping (Phase 3 of 7)',
    'open',
    'Er. Rajiv Nair',
    'Pune Smart City Dev Corp',
    12,
    320,
    7.2
  ),
  (
    'c0000000-0000-0000-0000-000000000003',
    'HLT-12',
    'Solar Cold-Chain & Telemetry for Primary Health Centers',
    'Healthcare & Energy',
    'High Priority',
    'Kalahandi, Odisha (Tribal Sub-Divisions)',
    'Vaccine spoilage due to frequent 8-hour grid cutoffs in remote dispensaries. Requires hybrid thermal storage and cellular temperature audit logs.',
    ARRAY['Thermal Storage', 'Telemetry', 'Solar MPPT', 'LiFePO4'],
    85000,
    95,
    2,
    'AI Synthesized (Phase 2 of 7)',
    'open',
    'Dr. Ananya Roy',
    'National Health Mission',
    5,
    180,
    7.0
  ),
  (
    'c0000000-0000-0000-0000-000000000004',
    'AG-04',
    'AgriVision Pest Early Warning System',
    'Agriculture & IoT',
    'Active Sprint',
    'Ranchi, Jharkhand (Birsa Agri Zone)',
    'Autonomous solar edge cameras analyzing Kharif crop pest infestations using lightweight neural networks deployed on microcontrollers.',
    ARRAY['TinyML', 'ESP32-CAM', 'AgriTech', 'Modbus'],
    50000,
    89,
    1,
    'Data Synthesis (Phase 1 of 7)',
    'in_progress',
    'Prof. K. N. Soren',
    'Birsa Agricultural University',
    8,
    240,
    6.8
  )
ON CONFLICT (id) DO NOTHING;

-- Insert seed sprint tasks for Rahul Sharma
INSERT INTO public.sprint_tasks (id, user_id, title, priority, due_date, assigned_to, project_name, is_completed)
VALUES 
  ('t0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Flash firmware with deep-sleep power saving mode (ESP32)', 'High Priority', 'Due Today', 'Rahul Sharma', 'AquaSense #S3', false),
  ('t0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'Finalize IP68 enclosure 3D print model for field casing', 'CAD / Fab', 'Nov 02', 'Team AquaSense', 'AquaSense #S3', false),
  ('t0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'Submit Sprint 2 Code Review & Telemetry Log to Tata Steel Mentor', 'Corporate Mentorship', 'Nov 04', 'Er. V. Singhal', 'AquaSense #S3', false)
ON CONFLICT (id) DO NOTHING;

-- Insert seed teams
INSERT INTO public.teams (id, challenge_id, leader_id, name, university, department, members_count, progress_pct, status, rank)
VALUES 
  ('m0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Team AquaSense', 'BIT Mesra', 'Dept of Chemical & Electronics Engg', 5, 64, 'active', 1),
  ('m0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', NULL, 'HydroMesh Innovators', 'IIT (ISM) Dhanbad', 'Dept of Environmental Science', 4, 48, 'bench_test', 2),
  ('m0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', NULL, 'JalSuraksha Tech', 'NIT Jamshedpur', 'Dept of Civil & Water Engg', 4, 30, 'ideation', 3)
ON CONFLICT (id) DO NOTHING;

-- Insert initial national platform metrics
INSERT INTO public.national_metrics (id, problems_count, active_challenges_count, partner_universities_count, industry_mentors_count, grants_sanctioned_amount, ai_triage_accuracy)
VALUES 
  ('n0000000-0000-0000-0000-000000000001', 12480, 2350, 186, 420, '₹1.4 Cr', 94.2)
ON CONFLICT (id) DO NOTHING;
