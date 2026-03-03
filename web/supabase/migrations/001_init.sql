-- TripWit schema
-- Run this in the Supabase SQL editor (Dashboard → SQL Editor → New query)

create table public.trips (
  id                   text        primary key,
  user_id              uuid        not null references auth.users(id) on delete cascade,
  is_public            boolean     not null default false,
  name                 text        not null default '',
  destination          text        not null default '',
  status_raw           text        not null default 'planning',
  notes                text        not null default '',
  has_custom_dates     boolean     not null default false,
  budget_amount        numeric     not null default 0,
  budget_currency_code text        not null default 'USD',
  start_date           text        not null default '',
  end_date             text        not null default '',
  days                 jsonb       not null default '[]',
  bookings             jsonb       not null default '[]',
  lists                jsonb       not null default '[]',
  expenses             jsonb       not null default '[]',
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- Row Level Security
alter table public.trips enable row level security;

-- Owner can read/write their own trips
create policy "owner_all" on public.trips
  for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Anyone (including anonymous) can read public trips
create policy "public_select" on public.trips
  for select
  using (is_public = true);

-- Auto-update updated_at on every write
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trips_updated_at
  before update on public.trips
  for each row execute function public.set_updated_at();
