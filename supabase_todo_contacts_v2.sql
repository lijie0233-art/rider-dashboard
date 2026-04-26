-- 待办事项：记录本周任务、负责人、截止时间、完成状态
create table if not exists public.station_weekly_todos (
  id uuid primary key default gen_random_uuid(),
  task text not null,
  owner text default '',
  due_at timestamptz,
  is_done boolean not null default false,
  week_key text not null,
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 如果之前已经建过 station_weekly_todos，用这句补齐负责人字段
alter table public.station_weekly_todos
add column if not exists owner text default '';

create index if not exists station_weekly_todos_week_key_idx
on public.station_weekly_todos(week_key);

create index if not exists station_weekly_todos_due_at_idx
on public.station_weekly_todos(due_at);

alter table public.station_weekly_todos enable row level security;

drop policy if exists "登录用户可以读取待办事项" on public.station_weekly_todos;
drop policy if exists "登录用户可以新增待办事项" on public.station_weekly_todos;
drop policy if exists "登录用户可以更新待办事项" on public.station_weekly_todos;
drop policy if exists "登录用户可以删除待办事项" on public.station_weekly_todos;

create policy "登录用户可以读取待办事项"
on public.station_weekly_todos
for select
to authenticated
using (true);

create policy "登录用户可以新增待办事项"
on public.station_weekly_todos
for insert
to authenticated
with check (true);

create policy "登录用户可以更新待办事项"
on public.station_weekly_todos
for update
to authenticated
using (true)
with check (true);

create policy "登录用户可以删除待办事项"
on public.station_weekly_todos
for delete
to authenticated
using (true);

-- 骑手通讯录：维护骑手 ID 与手机号，支持网页按 ID 弹出手机号
create table if not exists public.rider_contacts (
  rider_id text primary key,
  rider_name text default '',
  phone text not null,
  note text default '',
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists rider_contacts_phone_idx
on public.rider_contacts(phone);

alter table public.rider_contacts enable row level security;

drop policy if exists "登录用户可以读取骑手通讯录" on public.rider_contacts;
drop policy if exists "登录用户可以新增骑手通讯录" on public.rider_contacts;
drop policy if exists "登录用户可以更新骑手通讯录" on public.rider_contacts;
drop policy if exists "登录用户可以删除骑手通讯录" on public.rider_contacts;

create policy "登录用户可以读取骑手通讯录"
on public.rider_contacts
for select
to authenticated
using (true);

create policy "登录用户可以新增骑手通讯录"
on public.rider_contacts
for insert
to authenticated
with check (true);

create policy "登录用户可以更新骑手通讯录"
on public.rider_contacts
for update
to authenticated
using (true)
with check (true);

create policy "登录用户可以删除骑手通讯录"
on public.rider_contacts
for delete
to authenticated
using (true);
