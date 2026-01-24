"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Separator } from "@/components/ui/separator";
import {
  User,
  LogOut,
  Moon,
  Sun,
  Globe,
  Bell,
  ChevronRight,
  Settings,
} from "lucide-react";
import { useAuth } from "@/lib/hooks/use-auth";

export default function ProfilePage() {
  const { user, logout } = useAuth();
  const [theme, setTheme] = useState<"light" | "dark">("light");

  const handleLogout = () => {
    logout();
    window.location.href = "/";
  };

  const toggleTheme = () => {
    const newTheme = theme === "light" ? "dark" : "light";
    setTheme(newTheme);
    document.documentElement.classList.toggle("dark", newTheme === "dark");
  };

  return (
    <div className="container mx-auto max-w-lg px-4 py-6">
      <header className="mb-6">
        <h1 className="text-2xl font-bold">Perfil</h1>
      </header>

      {/* Profile Card */}
      <Card className="mb-6">
        <CardContent className="py-6">
          <div className="flex items-center gap-4">
            <Avatar className="size-16 border-2 border-primary/20">
              <AvatarFallback className="bg-primary/10 text-xl">
                {user?.display_name?.[0]?.toUpperCase() || <User className="size-6" />}
              </AvatarFallback>
            </Avatar>
            <div>
              <h2 className="text-xl font-semibold">
                {user?.display_name || "Usuario"}
              </h2>
              <p className="text-muted-foreground">{user?.email}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Settings */}
      <Card className="mb-6">
        <CardHeader className="pb-2">
          <CardTitle className="text-base flex items-center gap-2">
            <Settings className="size-4" />
            Configuracion
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <SettingsItem
            icon={theme === "light" ? Sun : Moon}
            label="Tema"
            value={theme === "light" ? "Claro" : "Oscuro"}
            onClick={toggleTheme}
          />
          <Separator />
          <SettingsItem
            icon={Globe}
            label="Idioma"
            value="Espanol"
            onClick={() => {}}
          />
          <Separator />
          <SettingsItem
            icon={Bell}
            label="Notificaciones"
            value="Activadas"
            onClick={() => {}}
          />
        </CardContent>
      </Card>

      {/* Logout */}
      <Card>
        <CardContent className="p-0">
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-4 text-red-500 hover:bg-red-500/5 transition-colors"
          >
            <LogOut className="size-5" />
            <span className="font-medium">Cerrar sesion</span>
          </button>
        </CardContent>
      </Card>

      {/* App info */}
      <div className="mt-8 text-center text-sm text-muted-foreground">
        <p>Taskly v1.0.0</p>
        <p className="mt-1">Hecho con ❤️</p>
      </div>
    </div>
  );
}

function SettingsItem({
  icon: Icon,
  label,
  value,
  onClick,
}: {
  icon: React.ElementType;
  label: string;
  value: string;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className="w-full flex items-center gap-3 px-4 py-4 hover:bg-muted/50 transition-colors"
    >
      <Icon className="size-5 text-muted-foreground" />
      <span className="flex-1 text-left font-medium">{label}</span>
      <span className="text-sm text-muted-foreground">{value}</span>
      <ChevronRight className="size-4 text-muted-foreground" />
    </button>
  );
}
