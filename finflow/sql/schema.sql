-- ============================================================
-- FinFlow — Supabase Schema
-- Run this entire file in your Supabase SQL Editor
-- ============================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================================
-- PROFILES (extends Supabase auth.users)
-- ============================================================
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  currency    text not null default 'PHP',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ============================================================
-- INCOME
-- ============================================================
create table if not exists public.income (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  date        date not null,
  source      text not null,
  category    text not null default 'Other',
  amount      numeric(12,2) not null check (amount >= 0),
  notes       text,
  created_at  timestamptz not null default now()
);

create index if not exists income_user_date on public.income(user_id, date desc);

-- ============================================================
-- EXPENSES
-- ============================================================
create table if not exists public.expenses (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  date        date not null,
  description text not null,
  category    text not null default 'Other',
  amount      numeric(12,2) not null check (amount >= 0),
  notes       text,
  created_at  timestamptz not null default now()
);

create index if not exists expenses_user_date on public.expenses(user_id, date desc);
create index if not exists expenses_user_cat  on public.expenses(user_id, category);

-- ============================================================
-- SCHEDULE (recurring items)
-- ============================================================
create table if not exists public.schedule (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  type        text not null check (type in ('income','expense')),
  amount      numeric(12,2) not null check (amount >= 0),
  frequency   text not null check (frequency in ('Daily','Weekly','Monthly','Quarterly','Yearly')),
  next_date   date not null,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

create index if not exists schedule_user_active on public.schedule(user_id, active, next_date);

-- ============================================================
-- BUDGETS
-- ============================================================
create table if not exists public.budgets (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  category    text not null,
  amount      numeric(12,2) not null check (amount >= 0),
  created_at  timestamptz not null default now(),
  unique(user_id, category)
);

-- ============================================================
-- GOALS
-- ============================================================
create table if not exists public.goals (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  target      numeric(12,2) not null check (target > 0),
  current     numeric(12,2) not null default 0 check (current >= 0),
  deadline    date not null,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- ROW LEVEL SECURITY — users only see their own data
-- ============================================================
alter table public.profiles  enable row level security;
alter table public.income    enable row level security;
alter table public.expenses  enable row level security;
alter table public.schedule  enable row level security;
alter table public.budgets   enable row level security;
alter table public.goals     enable row level security;

-- profiles
create policy "profiles: owner access" on public.profiles
  for all using (auth.uid() = id);

-- income
create policy "income: owner access" on public.income
  for all using (auth.uid() = user_id);

-- expenses
create policy "expenses: owner access" on public.expenses
  for all using (auth.uid() = user_id);

-- schedule
create policy "schedule: owner access" on public.schedule
  for all using (auth.uid() = user_id);

-- budgets
create policy "budgets: owner access" on public.budgets
  for all using (auth.uid() = user_id);

-- goals
create policy "goals: owner access" on public.goals
  for all using (auth.uid() = user_id);

-- ============================================================
-- AUTO-CREATE PROFILE on signup trigger
-- ============================================================
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, full_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- UPDATED_AT trigger for profiles
-- ============================================================
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
