-- =====================================================================
-- PetCare Home Services — Esquema inicial de base de datos
-- Ejecutar en: Supabase Dashboard -> SQL Editor (o via `supabase db push`
-- si usas la CLI de Supabase con este repo como carpeta `supabase/`).
-- =====================================================================

-- ── Extensiones ────────────────────────────────────────────────────────
create extension if not exists "pgcrypto";

-- ── Tipos enumerados ─────────────────────────────────────────────────
create type public.user_role as enum ('owner', 'provider');
create type public.service_category as enum
  ('grooming', 'veterinary_visit', 'walking', 'boarding', 'home_visit');
create type public.provider_type as enum ('employee', 'contractor', 'franchise');
create type public.delivery_mode as enum ('pickup_drop_off', 'home_visit');
create type public.payment_method as enum ('online', 'at_location');
create type public.booking_status as enum
  ('pending', 'confirmed', 'in_progress', 'completed', 'rejected', 'cancelled');
create type public.promotion_scope as enum ('national', 'local');

-- ── profiles ───────────────────────────────────────────────────────────
-- Un registro por usuario de auth.users. El trigger handle_new_user lo crea
-- automáticamente al registrarse (rol por defecto: owner).
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role public.user_role not null default 'owner',
  full_name text not null default '',
  email text not null,
  phone text,
  avatar_url text,
  created_at timestamptz not null default now()
);

-- ── pets ───────────────────────────────────────────────────────────────
create table public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  species text not null,
  breed text not null default '',
  age int not null default 0 check (age >= 0),
  photo_url text,
  requires_special_handling boolean not null default false,
  special_handling_notes text,
  created_at timestamptz not null default now()
);

-- ── vaccination_records ─────────────────────────────────────────────
create table public.vaccination_records (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets (id) on delete cascade,
  document_url text not null,
  uploaded_at timestamptz not null default now(),
  verified boolean not null default false
);

-- ── providers (proveedores de servicios) ────────────────────────────
create table public.providers (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles (id) on delete set null,
  name text not null,
  type public.provider_type not null default 'employee',
  branch_id uuid,
  daily_capacity int not null check (daily_capacity > 0),
  active_bookings int not null default 0 check (active_bookings >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint franchise_requires_branch check (
    type <> 'franchise' or branch_id is not null
  )
);

-- ── provider_services (categorías que ofrece cada proveedor) ─────────
create table public.provider_services (
  provider_id uuid not null references public.providers (id) on delete cascade,
  category public.service_category not null,
  primary key (provider_id, category)
);

-- ── services (catálogo de servicios reservables) ─────────────────────
create table public.services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  price numeric(10, 2) not null check (price >= 0),
  icon text not null default '🐾',
  category public.service_category not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ── promotions ─────────────────────────────────────────────────────────
create table public.promotions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  scope public.promotion_scope not null,
  branch_id uuid,
  provider_id uuid references public.providers (id) on delete cascade,
  discount_percentage numeric(5, 2) not null
    check (discount_percentage > 0 and discount_percentage <= 100),
  valid_from timestamptz not null,
  valid_until timestamptz not null,
  active boolean not null default true,
  constraint valid_range check (valid_until > valid_from),
  constraint local_needs_target check (
    scope <> 'local' or branch_id is not null or provider_id is not null
  ),
  constraint national_has_no_target check (
    scope <> 'national' or (branch_id is null and provider_id is null)
  )
);

-- ── bookings ───────────────────────────────────────────────────────────
create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets (id) on delete restrict,
  owner_id uuid not null references public.profiles (id) on delete cascade,
  provider_id uuid not null references public.providers (id) on delete restrict,
  service_id uuid references public.services (id) on delete set null,
  category public.service_category not null,
  delivery_mode public.delivery_mode not null,
  payment_method public.payment_method not null,
  scheduled_at timestamptz not null,
  address text,
  price numeric(10, 2) not null check (price >= 0),
  promotion_id uuid references public.promotions (id) on delete set null,
  status public.booking_status not null default 'pending',
  rejection_reason text,
  created_at timestamptz not null default now(),
  constraint home_visit_requires_address check (
    delivery_mode <> 'home_visit' or (address is not null and length(trim(address)) > 0)
  )
);

create index bookings_owner_id_idx on public.bookings (owner_id);
create index bookings_provider_id_idx on public.bookings (provider_id);
create index pets_owner_id_idx on public.pets (owner_id);

-- =====================================================================
-- Trigger: crear perfil automáticamente al registrarse
-- =====================================================================
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'owner')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- Trigger: validar transiciones de estado de una reserva.
-- No confiar solo en la validación del cliente (regla de negocio crítica).
-- =====================================================================
create function public.validate_booking_status_transition()
returns trigger
language plpgsql
as $$
begin
  if new.status = old.status then
    return new;
  end if;

  if old.status = 'pending' and new.status in ('confirmed', 'rejected', 'cancelled') then
    return new;
  elsif old.status = 'confirmed' and new.status in ('in_progress', 'rejected', 'cancelled') then
    return new;
  elsif old.status = 'in_progress' and new.status in ('completed', 'cancelled') then
    return new;
  else
    raise exception 'Transición de estado inválida: % -> %', old.status, new.status;
  end if;
end;
$$;

create trigger bookings_status_transition
  before update on public.bookings
  for each row execute function public.validate_booking_status_transition();

-- =====================================================================
-- Row Level Security
-- =====================================================================
alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.vaccination_records enable row level security;
alter table public.providers enable row level security;
alter table public.provider_services enable row level security;
alter table public.services enable row level security;
alter table public.promotions enable row level security;
alter table public.bookings enable row level security;

-- profiles: cada usuario ve/edita su propio perfil.
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- pets: el dueño gestiona sus propias mascotas. Los proveedores pueden ver
-- mascotas asociadas a una reserva que les pertenece (para validar vacunación).
create policy "pets_owner_all" on public.pets
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "pets_provider_read_via_booking" on public.pets
  for select using (
    exists (
      select 1 from public.bookings b
      join public.providers p on p.id = b.provider_id
      where b.pet_id = pets.id and p.profile_id = auth.uid()
    )
  );

-- vaccination_records: visible/editable a través de la propiedad de la mascota.
create policy "vaccination_owner_all" on public.vaccination_records
  for all using (
    exists (select 1 from public.pets pt where pt.id = pet_id and pt.owner_id = auth.uid())
  ) with check (
    exists (select 1 from public.pets pt where pt.id = pet_id and pt.owner_id = auth.uid())
  );

-- providers / provider_services / services: lectura pública para
-- cualquier usuario autenticado (catálogo); sin escritura desde el cliente.
create policy "providers_read_all" on public.providers
  for select using (auth.role() = 'authenticated');
create policy "provider_services_read_all" on public.provider_services
  for select using (auth.role() = 'authenticated');
create policy "services_read_all" on public.services
  for select using (auth.role() = 'authenticated');
create policy "promotions_read_all" on public.promotions
  for select using (auth.role() = 'authenticated');

-- bookings: el dueño ve/crea sus reservas; el proveedor ve/actualiza
-- (solo estado y motivo de rechazo) las reservas que le fueron asignadas.
create policy "bookings_owner_select" on public.bookings
  for select using (auth.uid() = owner_id);
create policy "bookings_owner_insert" on public.bookings
  for insert with check (auth.uid() = owner_id);
create policy "bookings_provider_select" on public.bookings
  for select using (
    exists (select 1 from public.providers p where p.id = provider_id and p.profile_id = auth.uid())
  );
create policy "bookings_provider_update" on public.bookings
  for update using (
    exists (select 1 from public.providers p where p.id = provider_id and p.profile_id = auth.uid())
  );

-- =====================================================================
-- Storage: buckets para fotos de mascotas, documentos de vacunación y avatares
-- =====================================================================
insert into storage.buckets (id, name, public)
values ('pet-photos', 'pet-photos', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('vaccination-docs', 'vaccination-docs', false)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Cada usuario solo puede escribir dentro de una carpeta con su propio uid
-- (convención de ruta: "{auth.uid()}/archivo.ext").
create policy "pet_photos_owner_write" on storage.objects
  for insert with check (
    bucket_id = 'pet-photos' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "pet_photos_public_read" on storage.objects
  for select using (bucket_id = 'pet-photos');

create policy "vaccination_docs_owner_write" on storage.objects
  for insert with check (
    bucket_id = 'vaccination-docs' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "vaccination_docs_owner_read" on storage.objects
  for select using (
    bucket_id = 'vaccination-docs' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars_owner_write" on storage.objects
  for insert with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "avatars_public_read" on storage.objects
  for select using (bucket_id = 'avatars');
