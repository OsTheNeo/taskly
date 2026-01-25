"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { cn } from "@/lib/utils";
import { DuotoneIcon, DuotoneIconNames } from "@/components/ui/duotone-icon";

const navItems = [
  { href: "/app", icon: DuotoneIconNames.home, label: "Hoy" },
  { href: "/app/groups", icon: DuotoneIconNames.users, label: "Tareas" },
  { href: "/app/challenges", icon: DuotoneIconNames.rocket, label: "Retos" },
  { href: "/app/profile", icon: DuotoneIconNames.user, label: "Perfil" },
];

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  // Find active index
  const activeIndex = navItems.findIndex((item) =>
    item.href === "/app"
      ? pathname === item.href
      : pathname.startsWith(item.href)
  );

  return (
    <div className="min-h-screen bg-background pb-24">
      {children}

      {/* Floating Bottom Navigation - Mobile style */}
      <nav className="fixed bottom-0 left-0 right-0 z-50 flex justify-center pb-4 px-4">
        <div
          className={cn(
            "flex items-center gap-4 p-1 rounded-full",
            "bg-white dark:bg-zinc-900",
            "border border-border",
            "shadow-lg shadow-black/5 dark:shadow-black/20"
          )}
        >
          {navItems.map((item, index) => {
            const isActive = mounted && (
              item.href === "/app"
                ? pathname === item.href
                : pathname.startsWith(item.href)
            );

            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "relative flex items-center gap-2 rounded-full transition-all duration-300 ease-out",
                  isActive
                    ? "bg-black dark:bg-white px-4 py-2"
                    : "p-2 hover:bg-muted"
                )}
              >
                {/* Icon container */}
                <div
                  className={cn(
                    "flex items-center justify-center",
                    isActive ? "size-5" : "size-6"
                  )}
                >
                  <DuotoneIcon
                    name={item.icon}
                    size={isActive ? 18 : 22}
                    strokeColor={
                      isActive
                        ? "var(--primary)"
                        : undefined
                    }
                    fillColor={
                      isActive
                        ? "var(--primary)"
                        : undefined
                    }
                    accentColor="var(--primary)"
                    className={cn(
                      isActive
                        ? "text-primary"
                        : "text-muted-foreground"
                    )}
                  />
                </div>

                {/* Label - only show when active */}
                {isActive && (
                  <span
                    className={cn(
                      "text-sm font-semibold whitespace-nowrap",
                      "text-white dark:text-black",
                      "animate-in fade-in slide-in-from-left-2 duration-200"
                    )}
                  >
                    {item.label}
                  </span>
                )}
              </Link>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
