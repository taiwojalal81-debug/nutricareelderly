import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "NutriCare | Smart Nutrition for Nigerian Seniors",
  description:
    "Personalized dietary recommendations for elderly Nigerians managing chronic conditions like diabetes and hypertension. Track meals, medications, and weight with ease.",
  keywords: [
    "nutrition app nigeria",
    "elderly health app",
    "diabetes diet nigeria",
    "medication reminder",
    "Nigerian food nutrition",
    "senior health app",
  ],
  openGraph: {
    title: "NutriCare | Smart Nutrition for Nigerian Seniors",
    description:
      "Personalized dietary recommendations for elderly Nigerians. Manage diabetes, hypertension & more with local Nigerian foods.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
