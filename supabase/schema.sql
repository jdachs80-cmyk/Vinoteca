-- Mis vinotecas · esquema de base de datos para Supabase
-- Pégalo entero en Supabase > SQL Editor > New query y pulsa Run (una sola vez).

-- ---------- tablas ----------
create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  email text not null,
  nombre text
);

create table public.espacios (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  creador uuid not null default auth.uid() references auth.users on delete cascade,
  creado timestamptz not null default now()
);

create table public.miembros (
  espacio_id uuid not null references public.espacios on delete cascade,
  user_id uuid not null references auth.users on delete cascade,
  primary key (espacio_id, user_id)
);

create table public.vinotecas (
  id uuid primary key default gen_random_uuid(),
  espacio_id uuid not null references public.espacios on delete cascade,
  nombre text not null,
  filas int not null default 6 check (filas between 1 and 26),
  cols int not null default 8 check (cols between 1 and 20),
  creado timestamptz not null default now()
);

create table public.vinos (
  id uuid primary key default gen_random_uuid(),
  espacio_id uuid not null references public.espacios on delete cascade,
  vinoteca_id uuid references public.vinotecas on delete set null,
  nombre text not null,
  anada text,
  bodega text,
  tipo text not null default 'tinto',
  dop text,
  region text,
  uvas text,
  crianza text,
  alcohol text,
  precio numeric,
  notas text,
  maridaje text,
  puntuaciones jsonb not null default '[]',
  desde int,
  hasta int,
  cantidad int not null default 1 check (cantidad >= 0),
  pos text[] not null default '{}',
  mi_nota text,
  creado_por uuid default auth.uid() references auth.users on delete set null,
  creado timestamptz not null default now()
);

create table public.consumos (
  id uuid primary key default gen_random_uuid(),
  espacio_id uuid not null references public.espacios on delete cascade,
  vino_id uuid references public.vinos on delete set null,
  nombre text,
  anada text,
  tipo text,
  fecha timestamptz not null default now(),
  por uuid default auth.uid() references auth.users on delete set null
);

create index on public.miembros (user_id);
create index on public.vinotecas (espacio_id);
create index on public.vinos (espacio_id);
create index on public.vinos (vinoteca_id);
create index on public.consumos (espacio_id, fecha desc);

-- ---------- funciones ----------
create or replace function public.is_member(e uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from miembros where espacio_id = e and user_id = auth.uid())
$$;

-- Crea el perfil al registrarse
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, email, nombre)
  values (new.id, new.email,
          coalesce(nullif(trim(new.raw_user_meta_data->>'nombre'), ''), split_part(new.email, '@', 1)));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Quien crea un espacio es miembro automáticamente
create or replace function public.add_creator() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into miembros (espacio_id, user_id) values (new.id, new.creador) on conflict do nothing;
  return new;
end $$;
create trigger on_espacio_created after insert on public.espacios
  for each row execute function public.add_creator();

-- Añadir a alguien a un espacio por su correo (tiene que tener cuenta)
create or replace function public.add_miembro(p_espacio uuid, p_email text) returns uuid
language plpgsql security definer set search_path = public as $$
declare uid uuid;
begin
  if not is_member(p_espacio) then
    raise exception 'not_member' using errcode = '42501';
  end if;
  select id into uid from profiles where lower(email) = lower(trim(p_email));
  if uid is null then
    raise exception 'no_user';
  end if;
  insert into miembros (espacio_id, user_id) values (p_espacio, uid) on conflict do nothing;
  return uid;
end $$;
revoke execute on function public.add_miembro(uuid, text) from public, anon;
grant execute on function public.add_miembro(uuid, text) to authenticated;

-- ---------- permisos (RLS) ----------
alter table public.profiles  enable row level security;
alter table public.espacios  enable row level security;
alter table public.miembros  enable row level security;
alter table public.vinotecas enable row level security;
alter table public.vinos     enable row level security;
alter table public.consumos  enable row level security;

-- Perfiles: el tuyo y los de quienes comparten espacio contigo
create policy profiles_select on public.profiles for select to authenticated using (
  id = auth.uid() or exists (
    select 1 from miembros a join miembros b on a.espacio_id = b.espacio_id
    where a.user_id = auth.uid() and b.user_id = profiles.id)
);
create policy profiles_update on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create policy espacios_select on public.espacios for select to authenticated
  using (creador = auth.uid() or is_member(id));
create policy espacios_insert on public.espacios for insert to authenticated
  with check (creador = auth.uid());
create policy espacios_update on public.espacios for update to authenticated
  using (is_member(id)) with check (is_member(id));
create policy espacios_delete on public.espacios for delete to authenticated
  using (creador = auth.uid());

create policy miembros_select on public.miembros for select to authenticated
  using (is_member(espacio_id));
-- Puedes salir tú, y el creador puede quitar a cualquiera (menos a sí mismo)
create policy miembros_delete on public.miembros for delete to authenticated using (
  (user_id = auth.uid() and not exists (select 1 from espacios e where e.id = espacio_id and e.creador = auth.uid()))
  or (user_id <> auth.uid() and exists (select 1 from espacios e where e.id = espacio_id and e.creador = auth.uid()))
);

create policy vinotecas_all on public.vinotecas for all to authenticated
  using (is_member(espacio_id)) with check (is_member(espacio_id));
create policy vinos_all on public.vinos for all to authenticated
  using (is_member(espacio_id)) with check (is_member(espacio_id));
create policy consumos_all on public.consumos for all to authenticated
  using (is_member(espacio_id)) with check (is_member(espacio_id));

grant select, update on public.profiles to authenticated;
grant select, insert, update, delete on public.espacios, public.vinotecas, public.vinos, public.consumos to authenticated;
grant select, delete on public.miembros to authenticated;

-- ---------- tiempo real (los cambios de otros aparecen solos) ----------
alter publication supabase_realtime add table
  public.espacios, public.miembros, public.vinotecas, public.vinos, public.consumos;
