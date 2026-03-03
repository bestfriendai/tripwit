import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  // Placeholder fallbacks prevent build-time crash when env vars aren't set.
  // Real API calls only happen at runtime when actual values are present.
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL ?? "https://placeholder.supabase.co",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "placeholder-anon-key"
  );
}
