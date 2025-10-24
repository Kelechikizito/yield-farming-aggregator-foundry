import type React from "react";
import "./globals.css";
import type { Metadata } from "next";
import { type ReactNode } from "react";
import { Providers } from "./providers";
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";
// import { Analytics } from "@vercel/analytics/next";
import Header from "@/components/Header";
import { Suspense } from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: "Yield-Farming-Aggregator",
  description:
    "Discover the highest yields in DeFi. Compare rates across 20+ protocols and maximize your crypto earnings.",
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en" className="dark">
      {/* <head>
        <link rel="icon" href="/T-Sender.svg" sizes="any" />
      </head> */}
      <body
        className={`font-sans ${GeistSans.variable} ${GeistMono.variable} antialiased`}
      >
        <Providers>
          <Header />
          {props.children}
        </Providers>
      </body>
    </html>
  );
}
