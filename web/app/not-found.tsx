import Link from "next/link";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Page Not Found — TripWit",
};

export default function NotFound() {
  return (
    <div className="h-screen flex flex-col bg-[#0c111d]">
      <nav className="px-6 h-14 flex items-center border-b border-white/6 shrink-0">
        <Link href="/" className="flex items-center gap-2.5">
          <img src="/icon-512.png" alt="TripWit" className="w-7 h-7 rounded-xl object-cover shadow-sm" />
          <span className="text-white font-semibold text-[15px]">TripWit</span>
        </Link>
      </nav>

      <div className="flex-1 flex flex-col items-center justify-center px-6 relative overflow-hidden">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[400px] bg-blue-600/10 rounded-full blur-[100px]" />
        </div>

        <div className="relative text-center max-w-sm">
          <div className="text-6xl mb-6">🗺️</div>
          <h1 className="text-2xl font-bold text-white mb-2 tracking-tight">Page not found</h1>
          <p className="text-slate-400 text-sm leading-relaxed mb-8">
            Looks like this destination doesn&apos;t exist. Let&apos;s get you back on track.
          </p>
          <Link
            href="/"
            className="inline-flex items-center gap-2 px-5 py-3 bg-blue-600 text-white rounded-xl font-semibold text-sm hover:bg-blue-500 transition-colors shadow-lg"
          >
            ✈️ Back to TripWit
          </Link>
        </div>
      </div>
    </div>
  );
}
