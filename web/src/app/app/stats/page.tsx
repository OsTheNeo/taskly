"use client";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { Flame, CheckCircle, Calendar, TrendingUp, Loader2 } from "lucide-react";
import { useAuth } from "@/lib/hooks/use-auth";
import * as dataService from "@/lib/supabase/data-service";

const categoryConfig: Record<string, { color: string; name: string }> = {
  study: { color: "bg-violet-500", name: "Estudio" },
  fitness: { color: "bg-orange-500", name: "Fitness" },
  mindfulness: { color: "bg-cyan-500", name: "Mindfulness" },
  work: { color: "bg-blue-500", name: "Trabajo" },
  personal: { color: "bg-gray-500", name: "Personal" },
};

const weekDays = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"];

export default function StatsPage() {
  const { getFirebaseUid } = useAuth();
  const firebaseUid = getFirebaseUid();

  const [stats, setStats] = useState<Record<string, unknown>>({});
  const [history, setHistory] = useState<Record<string, unknown>[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (firebaseUid) loadData();
  }, [firebaseUid]);

  const loadData = async () => {
    if (!firebaseUid) return;
    setLoading(true);

    const [statsData, historyData] = await Promise.all([
      dataService.getCompletionStats(firebaseUid, 30),
      dataService.getCompletionHistory(firebaseUid, 30),
    ]);

    setStats(statsData);
    setHistory(historyData);
    setLoading(false);
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="size-8 animate-spin text-primary" />
      </div>
    );
  }

  const streak = (stats.current_streak as number) || 0;
  const totalCompletions = (stats.total_completions as number) || 0;
  const completionsByDate = (stats.completions_by_date as Record<string, number>) || {};

  // Get last 7 days for chart
  const last7Days = [];
  const today = new Date();
  for (let i = 6; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    const dateStr = date.toISOString().split("T")[0];
    last7Days.push({
      date: dateStr,
      count: completionsByDate[dateStr] || 0,
      dayIndex: date.getDay(),
      isToday: i === 0,
    });
  }

  const maxCount = Math.max(...last7Days.map((d) => d.count), 1);

  // Group history by date
  const historyByDate: Record<string, Record<string, unknown>[]> = {};
  history.forEach((item) => {
    const date = item.completion_date as string;
    if (!historyByDate[date]) historyByDate[date] = [];
    historyByDate[date].push(item);
  });

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const now = new Date();
    const diff = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24));

    if (diff === 0) return "Hoy";
    if (diff === 1) return "Ayer";
    if (diff < 7) return `Hace ${diff} dias`;

    const months = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre",
    ];
    return `${date.getDate()} ${months[date.getMonth()]}`;
  };

  return (
    <div className="container mx-auto max-w-lg px-4 py-6">
      <header className="mb-6">
        <h1 className="text-2xl font-bold">Estadisticas</h1>
      </header>

      {/* Streak Card */}
      <Card className="mb-6 bg-gradient-to-br from-orange-500/10 to-orange-500/5 border-orange-500/20">
        <CardContent className="py-6">
          <div className="flex items-center gap-6">
            <div className="size-20 rounded-full bg-orange-500/20 flex flex-col items-center justify-center">
              <Flame className="size-6 text-orange-500" />
              <span className="text-2xl font-bold text-orange-500">{streak}</span>
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold">
                {streak === 1 ? "dia de racha" : "dias de racha"}
              </h3>
              <p className="text-sm text-muted-foreground">
                Sigue asi para mantener tu racha
              </p>
              <div className="flex gap-4 mt-3">
                <div className="flex items-center gap-1 text-sm">
                  <CheckCircle className="size-4 text-muted-foreground" />
                  <span className="font-semibold">{totalCompletions}</span>
                  <span className="text-muted-foreground">completadas</span>
                </div>
                <div className="flex items-center gap-1 text-sm">
                  <Calendar className="size-4 text-muted-foreground" />
                  <span className="font-semibold">30</span>
                  <span className="text-muted-foreground">dias</span>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Weekly Chart */}
      <Card className="mb-6">
        <CardHeader className="pb-2">
          <div className="flex items-center justify-between">
            <CardTitle className="text-base">Esta semana</CardTitle>
            <Badge variant="secondary" className="bg-primary/10 text-primary">
              {last7Days.reduce((sum, d) => sum + d.count, 0)} tareas
            </Badge>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex items-end justify-around h-32 pt-4">
            {last7Days.map((day, index) => {
              const height = day.count === 0 ? 8 : (day.count / maxCount) * 80 + 20;
              const dayLabel = day.isToday ? "Hoy" : weekDays[(day.dayIndex + 6) % 7];

              return (
                <div key={day.date} className="flex flex-col items-center gap-1">
                  {day.count > 0 && (
                    <span className="text-xs font-semibold">{day.count}</span>
                  )}
                  <div
                    className={`w-8 rounded-md transition-all ${
                      day.count > 0
                        ? day.isToday
                          ? "bg-primary"
                          : "bg-primary/60"
                        : "bg-muted"
                    }`}
                    style={{ height: `${height}px` }}
                  />
                  <span
                    className={`text-xs ${
                      day.isToday
                        ? "font-semibold text-primary"
                        : "text-muted-foreground"
                    }`}
                  >
                    {dayLabel}
                  </span>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* History */}
      <div>
        <h2 className="text-lg font-semibold mb-4">Historial reciente</h2>

        {Object.keys(historyByDate).length === 0 ? (
          <Card>
            <CardContent className="py-8 text-center">
              <TrendingUp className="size-12 mx-auto text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No hay actividad reciente</p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-4">
            {Object.entries(historyByDate).map(([date, items]) => (
              <div key={date}>
                <p className="text-sm font-medium text-muted-foreground mb-2">
                  {formatDate(date)}
                </p>
                <div className="space-y-2">
                  {items.map((item) => {
                    const task = item.task as Record<string, string> | null;
                    const categoryKey = task?.color || "personal";
                    const category = categoryConfig[categoryKey] || categoryConfig.personal;
                    const status = item.status as string;

                    return (
                      <Card key={item.id as string}>
                        <CardContent className="py-3 px-4">
                          <div className="flex items-center gap-3">
                            <div
                              className={`size-9 rounded-lg ${category.color}/10 flex items-center justify-center`}
                            >
                              <CheckCircle
                                className={`size-4 ${
                                  status === "completed"
                                    ? "text-green-500"
                                    : status === "partial"
                                    ? "text-orange-500"
                                    : "text-red-500"
                                }`}
                              />
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="font-medium truncate">
                                {task?.title || "Tarea"}
                              </p>
                              <Badge
                                variant="secondary"
                                className={`text-xs ${category.color}/10`}
                              >
                                {category.name}
                              </Badge>
                            </div>
                            <Badge
                              variant="secondary"
                              className={`text-xs ${
                                status === "completed"
                                  ? "bg-green-500/10 text-green-600"
                                  : status === "partial"
                                  ? "bg-orange-500/10 text-orange-600"
                                  : "bg-red-500/10 text-red-600"
                              }`}
                            >
                              {status === "completed"
                                ? "Completada"
                                : status === "partial"
                                ? "Parcial"
                                : "Omitida"}
                            </Badge>
                          </div>
                        </CardContent>
                      </Card>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
