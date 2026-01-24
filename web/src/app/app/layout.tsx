"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Home, Users, Rocket, BarChart3, User } from "lucide-react";
import { cn } from "@/lib/utils";

const navItems = [
  { href: "/app", icon: Home, label: "Inicio" },
  { href: "/app/groups", icon: Users, label: "Grupos" },
  { href: "/app/challenges", icon: Rocket, label: "Retos" },
  { href: "/app/stats", icon: BarChart3, label: "Stats" },
  { href: "/app/profile", icon: User, label: "Perfil" },
];

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="min-h-screen bg-background pb-20">
      {children}

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 z-50 border-t bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container mx-auto max-w-lg">
          <div className="flex items-center justify-around py-2">
            {navItems.map((item) => {
              const isActive = pathname === item.href ||
                (item.href !== "/app" && pathname.startsWith(item.href));
              const Icon = item.icon;

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "flex flex-col items-center gap-1 px-3 py-2 rounded-lg transition-colors",
                    isActive
                      ? "text-primary"
                      : "text-muted-foreground hover:text-foreground"
                  )}
                >
                  <Icon className="size-5" />
                  <span className="text-xs font-medium">{item.label}</span>
                </Link>
              );
            })}
          </div>
        </div>
      </nav>
    </div>
  );
}
