"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Separator } from "@/components/ui/separator";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { DuotoneIcon, DuotoneIconNames } from "@/components/ui/duotone-icon";
import { useAuth } from "@/lib/hooks/use-auth";

// Accent colors matching mobile app
const accentColors = [
  "#000000", // Black (default)
  "#8b5cf6", // Violet
  "#f97316", // Orange
  "#06b6d4", // Cyan
  "#22c55e", // Green
  "#ec4899", // Pink
  "#eab308", // Yellow
  "#3b82f6", // Blue
];

export default function ProfilePage() {
  const { user, logout } = useAuth();
  const [theme, setTheme] = useState<"light" | "dark">("light");
  const [language, setLanguage] = useState<"es" | "en">("es");
  const [accentColorIndex, setAccentColorIndex] = useState(0);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  // Dialogs
  const [colorDialogOpen, setColorDialogOpen] = useState(false);
  const [languageDialogOpen, setLanguageDialogOpen] = useState(false);
  const [aboutDialogOpen, setAboutDialogOpen] = useState(false);
  const [helpDialogOpen, setHelpDialogOpen] = useState(false);
  const [logoutDialogOpen, setLogoutDialogOpen] = useState(false);

  const handleLogout = () => {
    logout();
    window.location.href = "/";
  };

  const toggleTheme = () => {
    const newTheme = theme === "light" ? "dark" : "light";
    setTheme(newTheme);
    document.documentElement.classList.toggle("dark", newTheme === "dark");
  };

  const currentAccent = accentColors[accentColorIndex];

  return (
    <div className="container mx-auto px-4 py-6 max-w-lg lg:max-w-2xl">
      {/* Header with Avatar */}
      <header className="mb-6">
        <div className="flex items-center gap-4">
          <Avatar className="size-20 border-4 border-primary/20">
            <AvatarFallback
              className="text-2xl font-bold"
              style={{ backgroundColor: `${currentAccent}20`, color: currentAccent }}
            >
              {user?.display_name?.[0]?.toUpperCase() || (
                <DuotoneIcon name={DuotoneIconNames.user} size={32} />
              )}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1">
            <h1 className="text-2xl font-bold">
              {user?.display_name || "Usuario"}
            </h1>
            <p className="text-muted-foreground">{user?.email}</p>
          </div>
        </div>
      </header>

      {/* Stats Card */}
      <Card className="mb-6">
        <CardContent className="p-0">
          <SettingsItem
            icon={DuotoneIconNames.chart}
            label="Estadisticas"
            onClick={() => window.location.href = "/app/challenges"}
            accentColor={currentAccent}
          />
        </CardContent>
      </Card>

      {/* Settings */}
      <Card className="mb-6">
        <CardHeader className="pb-2">
          <CardTitle className="text-base flex items-center gap-2">
            <DuotoneIcon name={DuotoneIconNames.gear} size={16} accentColor={currentAccent} />
            Configuracion
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          {/* Notifications */}
          <SettingsItem
            icon={DuotoneIconNames.bell}
            label="Notificaciones"
            accentColor={currentAccent}
            trailing={
              <Switch
                checked={notificationsEnabled}
                onCheckedChange={setNotificationsEnabled}
              />
            }
          />
          <Separator />

          {/* Theme */}
          <SettingsItem
            icon={theme === "light" ? DuotoneIconNames.sun : DuotoneIconNames.moon}
            label="Tema oscuro"
            accentColor={currentAccent}
            trailing={
              <Switch
                checked={theme === "dark"}
                onCheckedChange={toggleTheme}
              />
            }
          />
          <Separator />

          {/* Language */}
          <SettingsItem
            icon={DuotoneIconNames.globe}
            label="Idioma"
            value={language === "es" ? "Espanol" : "English"}
            onClick={() => setLanguageDialogOpen(true)}
            accentColor={currentAccent}
          />
          <Separator />

          {/* Accent Color */}
          <SettingsItem
            icon={DuotoneIconNames.sparkle}
            label="Color de acento"
            onClick={() => setColorDialogOpen(true)}
            accentColor={currentAccent}
            trailing={
              <div
                className="size-6 rounded-md border"
                style={{ backgroundColor: currentAccent }}
              />
            }
          />
        </CardContent>
      </Card>

      {/* Help & About */}
      <Card className="mb-6">
        <CardContent className="p-0">
          <SettingsItem
            icon={DuotoneIconNames.info}
            label="Ayuda"
            onClick={() => setHelpDialogOpen(true)}
            accentColor={currentAccent}
          />
          <Separator />
          <SettingsItem
            icon={DuotoneIconNames.info}
            label="Acerca de"
            onClick={() => setAboutDialogOpen(true)}
            accentColor={currentAccent}
          />
          <Separator />
          <button
            onClick={() => setLogoutDialogOpen(true)}
            className="w-full flex items-center gap-3 px-4 py-4 text-red-500 hover:bg-red-500/5 transition-colors"
          >
            <div
              className="size-9 rounded-lg flex items-center justify-center"
              style={{ backgroundColor: "#ef444420" }}
            >
              <DuotoneIcon name={DuotoneIconNames.exit} size={18} strokeColor="#ef4444" accentColor="#ef4444" />
            </div>
            <span className="font-medium">Cerrar sesion</span>
          </button>
        </CardContent>
      </Card>

      {/* App info */}
      <div className="text-center text-sm text-muted-foreground">
        <p>Taskly v1.0.0</p>
        <p className="mt-1">Hecho con amor</p>
      </div>

      {/* Color Picker Dialog */}
      <Dialog open={colorDialogOpen} onOpenChange={setColorDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Color de acento</DialogTitle>
          </DialogHeader>
          <div className="pt-4">
            <div className="flex flex-wrap gap-4 justify-center">
              {accentColors.map((color, index) => (
                <button
                  key={color}
                  onClick={() => {
                    setAccentColorIndex(index);
                    setColorDialogOpen(false);
                  }}
                  className={`size-12 rounded-xl transition-all ${
                    index === accentColorIndex
                      ? "ring-2 ring-offset-2 ring-foreground scale-110"
                      : "hover:scale-105"
                  }`}
                  style={{ backgroundColor: color }}
                >
                  {index === accentColorIndex && (
                    <DuotoneIcon
                      name={DuotoneIconNames.check}
                      size={20}
                      strokeColor={index === 0 ? "white" : "white"}
                      className="mx-auto"
                    />
                  )}
                </button>
              ))}
            </div>

            {/* Preview */}
            <div className="mt-8 p-4 rounded-xl border bg-muted/30">
              <p className="text-xs text-muted-foreground mb-4">Vista previa</p>
              <div className="flex justify-around">
                {[DuotoneIconNames.home, DuotoneIconNames.check, DuotoneIconNames.bell, DuotoneIconNames.user].map((icon, i) => (
                  <div key={i} className="flex flex-col items-center gap-2">
                    <div
                      className="size-12 rounded-xl flex items-center justify-center"
                      style={{ backgroundColor: `${currentAccent}15` }}
                    >
                      <DuotoneIcon name={icon} size={22} accentColor={currentAccent} />
                    </div>
                  </div>
                ))}
              </div>
              <Button
                className="w-full mt-4"
                style={{ backgroundColor: currentAccent }}
              >
                Boton de accion
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Language Dialog */}
      <Dialog open={languageDialogOpen} onOpenChange={setLanguageDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Idioma</DialogTitle>
          </DialogHeader>
          <div className="pt-4 space-y-2">
            <button
              onClick={() => {
                setLanguage("es");
                setLanguageDialogOpen(false);
              }}
              className={`w-full flex items-center gap-4 p-4 rounded-xl transition-colors ${
                language === "es" ? "bg-primary/10 border border-primary" : "hover:bg-muted"
              }`}
            >
              <span className="text-2xl">🇪🇸</span>
              <span className="flex-1 text-left font-medium">Espanol</span>
              {language === "es" && (
                <DuotoneIcon name={DuotoneIconNames.check} size={20} accentColor={currentAccent} />
              )}
            </button>
            <button
              onClick={() => {
                setLanguage("en");
                setLanguageDialogOpen(false);
              }}
              className={`w-full flex items-center gap-4 p-4 rounded-xl transition-colors ${
                language === "en" ? "bg-primary/10 border border-primary" : "hover:bg-muted"
              }`}
            >
              <span className="text-2xl">🇺🇸</span>
              <span className="flex-1 text-left font-medium">English</span>
              {language === "en" && (
                <DuotoneIcon name={DuotoneIconNames.check} size={20} accentColor={currentAccent} />
              )}
            </button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Help Dialog */}
      <Dialog open={helpDialogOpen} onOpenChange={setHelpDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Ayuda</DialogTitle>
          </DialogHeader>
          <div className="pt-4 space-y-4">
            <HelpItem
              title="Como creo una tarea?"
              content="Toca el boton + en la pantalla principal y completa el formulario con los detalles de tu tarea."
            />
            <HelpItem
              title="Como comparto tareas con otros?"
              content="Crea un grupo desde la pestana Tareas, luego invita a otros usando el codigo de grupo."
            />
            <HelpItem
              title="Como activo los recordatorios?"
              content="Al crear o editar una tarea, activa el switch de recordatorio y selecciona la hora deseada."
            />
          </div>
        </DialogContent>
      </Dialog>

      {/* About Dialog */}
      <Dialog open={aboutDialogOpen} onOpenChange={setAboutDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="flex items-center gap-3">
              <div
                className="size-10 rounded-lg flex items-center justify-center"
                style={{ backgroundColor: currentAccent }}
              >
                <DuotoneIcon name={DuotoneIconNames.check} size={20} strokeColor="white" />
              </div>
              Taskly
            </DialogTitle>
          </DialogHeader>
          <div className="pt-4 space-y-2 text-muted-foreground">
            <p>Version: 1.0.0</p>
            <p>Tu asistente de productividad personal para gestionar tareas diarias y habitos.</p>
          </div>
        </DialogContent>
      </Dialog>

      {/* Logout Confirmation Dialog */}
      <Dialog open={logoutDialogOpen} onOpenChange={setLogoutDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Cerrar sesion</DialogTitle>
          </DialogHeader>
          <div className="pt-4">
            <p className="text-muted-foreground mb-6">
              Estas seguro de que quieres cerrar sesion?
            </p>
            <div className="flex gap-3">
              <Button
                variant="outline"
                className="flex-1"
                onClick={() => setLogoutDialogOpen(false)}
              >
                Cancelar
              </Button>
              <Button
                variant="destructive"
                className="flex-1"
                onClick={handleLogout}
              >
                Cerrar sesion
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function SettingsItem({
  icon,
  label,
  value,
  onClick,
  trailing,
  accentColor,
}: {
  icon: string;
  label: string;
  value?: string;
  onClick?: () => void;
  trailing?: React.ReactNode;
  accentColor: string;
}) {
  const content = (
    <div className="w-full flex items-center gap-3 px-4 py-4 hover:bg-muted/50 transition-colors">
      <div
        className="size-9 rounded-lg flex items-center justify-center"
        style={{ backgroundColor: `${accentColor}15` }}
      >
        <DuotoneIcon name={icon} size={18} accentColor={accentColor} />
      </div>
      <span className="flex-1 text-left font-medium">{label}</span>
      {value && (
        <span className="text-sm text-muted-foreground">{value}</span>
      )}
      {trailing}
      {!trailing && onClick && (
        <DuotoneIcon name={DuotoneIconNames.chevronRight} size={16} className="text-muted-foreground" />
      )}
    </div>
  );

  if (onClick && !trailing) {
    return <button onClick={onClick} className="w-full">{content}</button>;
  }

  return content;
}

function HelpItem({ title, content }: { title: string; content: string }) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="border rounded-lg">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between p-4"
      >
        <span className="font-medium text-left">{title}</span>
        <DuotoneIcon
          name={isOpen ? DuotoneIconNames.chevronRight : DuotoneIconNames.chevronRight}
          size={16}
          className={`text-muted-foreground transition-transform ${isOpen ? "rotate-90" : ""}`}
        />
      </button>
      {isOpen && (
        <div className="px-4 pb-4 text-sm text-muted-foreground">
          {content}
        </div>
      )}
    </div>
  );
}
