import type { Metadata } from "next";
import Script from "next/script";
import { Inter } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/contexts/AuthContext";
import CookieBanner from "@/components/layout/CookieBanner";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const adsenseClientId = process.env.NEXT_PUBLIC_ADSENSE_CLIENT_ID;

export const metadata: Metadata = {
  metadataBase: new URL("https://tripwit.app"),
  title: "TripWit — Travel Planner",
  description:
    "Plan trips, track your itinerary, and stay organized — from your desktop.",
  icons: {
    icon: [
      { url: "/favicon-16x16.png", sizes: "16x16", type: "image/png" },
      { url: "/favicon-32x32.png", sizes: "32x32", type: "image/png" },
      { url: "/icon-192.png",      sizes: "192x192", type: "image/png" },
      { url: "/icon-512.png",      sizes: "512x512", type: "image/png" },
    ],
    apple: { url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
    shortcut: "/favicon.ico",
  },
  openGraph: {
    title: "TripWit — Travel Planner",
    description: "Plan trips, track your itinerary, and stay organized.",
    type: "website",
    images: [{ url: "/icon-512.png", width: 512, height: 512, alt: "TripWit" }],
  },
  manifest: "/site.webmanifest",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={inter.variable}>
      <head>
        {/* Chrome Origin Trial: Prompt API for Gemini Nano (expires 2026-04-14) */}
        <meta httpEquiv="origin-trial" content="A4b3/xwI3jHH7ZaxUYbEeLpkRGh+BYt9r6m15JOsWWM+Z1U5l0Ekdc0p12h8CFaloaJG6L4/UZZH67MLPfgdRgsAAACKeyJvcmlnaW4iOiJodHRwczovL3d3dy50cmlwd2l0LmFwcDo0NDMiLCJmZWF0dXJlIjoiQUlQcm9tcHRBUElNdWx0aW1vZGFsSW5wdXQiLCJleHBpcnkiOjE3ODE1NjgwMDAsImlzU3ViZG9tYWluIjp0cnVlLCJpc1RoaXJkUGFydHkiOnRydWV9" />
        {adsenseClientId && (
          <Script
            async
            src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${adsenseClientId}`}
            crossOrigin="anonymous"
            strategy="afterInteractive"
          />
        )}
      </head>
      <body className="font-sans antialiased">
        <AuthProvider>{children}</AuthProvider>
        <CookieBanner />
      </body>
    </html>
  );
}
