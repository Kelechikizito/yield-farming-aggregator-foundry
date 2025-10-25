// components/Hero.tsx
import React from "react";

type Props = {
  lastUpdated: number | null;
};

export default function Hero({ lastUpdated }: Props) {
  const [timeAgo, setTimeAgo] = React.useState<string>("updated just now");

  React.useEffect(() => {
    if (!lastUpdated) {
      setTimeAgo("no data yet");
      return;
    }

    const update = () => {
      const diff = Date.now() - lastUpdated;
      const minutes = Math.floor(diff / 60000);
      const seconds = Math.floor((diff % 60000) / 1000);

      if (minutes >= 60) {
        const hours = Math.floor(minutes / 60);
        setTimeAgo(`${hours}h ${minutes % 60}m ago`);
      } else if (minutes >= 1) {
        setTimeAgo(`${minutes} minute${minutes > 1 ? "s" : ""} ago`);
      } else {
        setTimeAgo(`${seconds} second${seconds !== 1 ? "s" : ""} ago`);
      }
    };

    // initial compute
    update();

    // update every 30s so the text remains fresh (does NOT trigger data fetch)
    const timer = setInterval(update, 30000);
    return () => clearInterval(timer);
  }, [lastUpdated]);

  return (
    <div className="mb-8">
      <h2 className="text-3xl font-bold text-foreground mb-2 text-balance">
        Discover the highest yields in Single Asset Pools
      </h2>
      <p className="text-muted-foreground text-lg text-pretty">
        Compare rates across protocols and maximize your crypto earnings.
      </p>
      <div className="flex items-center text-sm text-muted-foreground mt-4">
        <div className="w-2 h-2 bg-accent rounded-full mr-2 animate-pulse"></div>
        Data updated {timeAgo}
      </div>
    </div>
  );
}
