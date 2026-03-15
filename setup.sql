create table if not exists public.room_messages (
  id bigint generated always as identity primary key,
  room_id text not null,
  telegram_id text not null,
  author_name text not null,
  username text,
  text text not null check (char_length(text) > 0 and char_length(text) <= 1000),
  created_at timestamptz not null default now()
);

alter table public.room_messages enable row level security;

-- Быстрый MVP: разрешаем чтение и отправку с anon/publishable key.
-- Для реально безопасного закрытого чата позже нужно вынести проверку Telegram initData
-- на backend / Edge Function и ужесточить RLS.

drop policy if exists "room_messages_read_all" on public.room_messages;
create policy "room_messages_read_all"
  on public.room_messages
  for select
  to anon, authenticated
  using (true);

drop policy if exists "room_messages_insert_all" on public.room_messages;
create policy "room_messages_insert_all"
  on public.room_messages
  for insert
  to anon, authenticated
  with check (true);
