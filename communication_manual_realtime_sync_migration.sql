-- 沟通手册：启用 Supabase Realtime 实时同步
-- 用途：后台修改话术状态或内容后，外部 communication_manual.html 可立即收到数据库变更。
-- 执行前请确保 communication_manual_scripts 表已经存在。

-- 让 Realtime 在 UPDATE / DELETE 时能够稳定识别记录。
alter table public.communication_manual_scripts replica identity full;

-- 将沟通手册表加入 Supabase Realtime publication；已加入时不会重复执行。
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'communication_manual_scripts'
  ) then
    alter publication supabase_realtime add table public.communication_manual_scripts;
  end if;
end
$$;

-- 外部页面使用 anon 角色读取 Realtime 事件，继续依赖现有 SELECT RLS 策略。
grant select on public.communication_manual_scripts to anon, authenticated;
