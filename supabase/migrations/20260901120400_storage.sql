-- Public bucket (matches StorageConst.rootDirectory = "images" convention on
-- the Flutter side): read access is public so profile/team images just work
-- via a plain URL. Writes are gated by RLS to each user's own path prefix
-- (every upload path is "images/<uid>/...", matching the existing
-- StorageConst.*UploadPath() helpers).
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do nothing;

create policy "images_insert_own_prefix" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "images_update_own_prefix" on storage.objects
  for update to authenticated
  using (bucket_id = 'images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "images_delete_own_prefix" on storage.objects
  for delete to authenticated
  using (bucket_id = 'images' and (storage.foldername(name))[1] = auth.uid()::text);
