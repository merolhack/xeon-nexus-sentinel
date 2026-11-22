import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Xeon-Nexus-Sentinel | Telemetría Headless",
  description: "Panel de control para servidor HP ProLiant Xeon con AlmaLinux 9, IA local y minería",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className="min-h-screen bg-darkbg text-gray-100 antialiased selection:bg-accent selection:text-white">
        {children}
      </body>
    </html>
  );
}
