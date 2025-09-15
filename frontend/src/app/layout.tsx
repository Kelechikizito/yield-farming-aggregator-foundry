import "./globals.css";
import type { Metadata } from "next";
import { type ReactNode } from "react";
// import Header from "@/components/Header"
import { Providers } from "./providers";

export const metadata: Metadata = {
  title: "Yield-Farming-Aggregator",
  description:
    "A decentralized application to aggregate yield farming opportunities across multiple protocols.",
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/T-Sender.svg" sizes="any" />
      </head>
      <body className="bg-zinc-50">
        I AM THE FUCKING BEST. THAT IS ALL.
        <Providers>
          {/* <Header /> */}
          {props.children}
        </Providers>
      </body>
    </html>
  );
}
