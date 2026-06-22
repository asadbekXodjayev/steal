import type { Metadata, Viewport } from "next";
import { Oswald, JetBrains_Mono } from "next/font/google";
import { Providers } from "@/components/providers/Providers";
import "./globals.css";

// Oswald covers latin + latin-ext + cyrillic, so en / uz / ru all render in the
// SAME display font. This fixes the font swap + layout shift on language toggle:
// Barlow Condensed was latin-only and had no Cyrillic glyphs, so Russian fell
// back to a different system font with different metrics.
const oswald = Oswald({
  subsets: ["latin", "latin-ext", "cyrillic"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-heading",
  display: "swap",
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin", "latin-ext", "cyrillic"],
  weight: ["400", "500", "600"],
  variable: "--font-mono",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "STEEL — Forge Your Steel",
    template: "%s | STEEL",
  },
  description: "No excuses. No hand-holding. Build something real.",
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "STEEL",
  },
};

export const viewport: Viewport = {
  themeColor: "#0a0a0a",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`dark ${oswald.variable} ${jetbrainsMono.variable}`}
    >
      <body className="relative min-h-dvh bg-background text-foreground antialiased">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
