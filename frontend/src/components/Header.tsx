"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import {
  Search,
  Settings,
  RefreshCw,
  TrendingUp,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import DarkModeToggle from "./ui/DarkModeToggle";
import Image from "next/image";

export default function Header() {
  return (
      <header className="bg-card">
        <div className="mx-auto px-4 py-4">
          <div className="flex sm:flex-row flex-col items-center justify-between gap-8">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-accent rounded-lg flex items-center justify-center">
                  <TrendingUp className="w-5 h-5 text-accent-foreground" />
                </div>
                <h1 className="text-2xl font-bold text-foreground">
                  Yield Farming Aggregator
                </h1>
              </div>
              <nav className="hidden lg:flex space-x-6">
                <a
                  href="#"
                  className="text-foreground hover:text-accent transition-colors"
                >
                  Dashboard
                </a>
                <a
                  href="#"
                  className="text-muted-foreground hover:text-accent transition-colors"
                >
                  Markets
                </a>
                <a
                  href="#"
                  className="text-muted-foreground hover:text-accent transition-colors"
                >
                  Portfolio
                </a>
                <a
                  href="#"
                  className="text-muted-foreground hover:text-accent transition-colors"
                >
                  Analytics
                </a>
              </nav>
            </div>
            <div className="flex items-center space-x-3">
                <DarkModeToggle />
              <Button variant="outline" size="sm">
                <Settings className="w-4 h-4" />
              </Button>
              <ConnectButton />
            </div>
          </div>
        </div>
      </header>
  );
}
