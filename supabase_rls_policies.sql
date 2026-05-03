-- ==============================================================================
-- 🛡️ SOVEREIGN MAAREG — ROW LEVEL SECURITY (RLS) POLICIES
-- Execute this script in your Supabase SQL Editor to secure the database.
-- ==============================================================================

-- 1. Visas Table (Public Catalog)
-- Anon users can only READ records where is_active is true.
-- No inserts, updates, or deletes allowed for anon users.
ALTER TABLE visas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_active_visas" ON visas
  FOR SELECT TO anon USING (is_active = true);

-- 2. Categories Table (Public Catalog)
-- Anon users can only READ categories.
-- No inserts, updates, or deletes allowed for anon users.
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_categories" ON categories
  FOR SELECT TO anon USING (true);

-- 3. Leads Table (Private Data)
-- Anon users can only INSERT new leads.
-- Anon users CANNOT SELECT (read back) the data they or anyone else submitted.
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_insert_leads" ON leads
  FOR INSERT TO anon WITH CHECK (true);

-- 4. Contact Messages Table (Private Data)
-- Create the table if it does not exist (CRIT-03 remediation)
CREATE TABLE IF NOT EXISTS contact_messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  email text NOT NULL,
  message text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Anon users can only INSERT new messages.
-- Anon users CANNOT SELECT (read back) the messages.
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_insert_contact_messages" ON contact_messages
  FOR INSERT TO anon WITH CHECK (true);

-- ==============================================================================
-- NOTE: Authenticated admin users (e.g., using Supabase Dashboard or authenticated
-- as service_role/admin) will naturally bypass these restrictions or use their
-- own authenticated role policies to read/manage all data.
-- ==============================================================================
