"use client";

import { useState, useEffect, useMemo } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Plus,
  User,
  Target,
  BookOpen,
  Activity,
  Briefcase,
  Sun,
  Loader2,
  Trash2,
  MoreVertical,
  Sparkles,
  CheckCircle2,
  Calendar,
} from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useAuth } from "@/lib/hooks/use-auth";
import { useTasks } from "@/lib/hooks/use-tasks";
import type { RecurrenceFrequency } from "@/lib/supabase";

// Category definitions
const categoryConfig = {
  study: { color: "bg-violet-500", borderColor: "border-l-violet-500", icon: BookOpen, name: "Estudio" },
  fitness: { color: "bg-orange-500", borderColor: "border-l-orange-500", icon: Activity, name: "Fitness" },
  mindfulness: { color: "bg-cyan-500", borderColor: "border-l-cyan-500", icon: Sun, name: "Mindfulness" },
  work: { color: "bg-blue-500", borderColor: "border-l-blue-500", icon: Briefcase, name: "Trabajo" },
  personal: { color: "bg-gray-500", borderColor: "border-l-gray-500", icon: User, name: "Personal" },
};

const RECURRENCE_OPTIONS = [
  { value: "once", label: "Una vez" },
  { value: "daily", label: "Diario" },
  { value: "weekly", label: "Semanal" },
  { value: "monthly", label: "Mensual" },
];

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) return "Buenos dias";
  if (hour >= 12 && hour < 19) return "Buenas tardes";
  return "Buenas noches";
}

function getFormattedDate(): { day: number; month: string } {
  const date = new Date();
  const months = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre",
  ];
  return { day: date.getDate(), month: months[date.getMonth()] };
}

export default function AppDashboard() {
  const { user, loading: authLoading, getFirebaseUid } = useAuth();
  const firebaseUid = getFirebaseUid();
  const {
    tasks,
    loading: tasksLoading,
    completedCount,
    totalCount,
    completedGoals,
    totalGoals,
    toggleComplete,
    addTask,
    updateProgress,
    deleteTask,
  } = useTasks(firebaseUid);

  const [greeting, setGreeting] = useState(getGreeting());
  const [dateInfo, setDateInfo] = useState(getFormattedDate());
  const [addDialogOpen, setAddDialogOpen] = useState(false);

  // Task form state
  const [newTitle, setNewTitle] = useState("");
  const [newIsGoal, setNewIsGoal] = useState(false);
  const [newTarget, setNewTarget] = useState("30");
  const [newCategory, setNewCategory] = useState("personal");
  const [newRecurrence, setNewRecurrence] = useState<RecurrenceFrequency>("daily");
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      setGreeting(getGreeting());
      setDateInfo(getFormattedDate());
    }, 60000);
    return () => clearInterval(interval);
  }, []);

  // Separate pending and completed tasks
  const pendingTasks = useMemo(() =>
    tasks.filter((t) => t.completion?.status !== "completed"),
    [tasks]
  );

  const completedTasks = useMemo(() =>
    tasks.filter((t) => t.completion?.status === "completed"),
    [tasks]
  );

  const handleAddTask = async () => {
    if (!newTitle.trim()) return;
    setCreating(true);

    await addTask({
      title: newTitle.trim(),
      task_type: newIsGoal ? "goal" : "task",
      has_progress: newIsGoal,
      progress_target: newIsGoal ? parseInt(newTarget) : undefined,
      progress_unit: "min",
      color: newCategory,
      recurrence: newRecurrence,
    });

    setNewTitle("");
    setNewIsGoal(false);
    setNewTarget("30");
    setNewCategory("personal");
    setAddDialogOpen(false);
    setCreating(false);
  };

  const handleDeleteTask = async (taskId: string) => {
    if (deleteTask) {
      await deleteTask(taskId);
    }
  };

  // Loading state
  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="size-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Card className="w-full max-w-md mx-4">
          <CardContent className="py-8 text-center">
            <User className="size-12 mx-auto text-muted-foreground mb-4" />
            <h2 className="text-xl font-semibold mb-2">Bienvenido a Taskly</h2>
            <p className="text-muted-foreground mb-4">
              Inicia sesion para gestionar tus tareas
            </p>
            <Button onClick={() => (window.location.href = "/auth/login")}>
              Iniciar sesion
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const overallProgress = totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0;

  return (
    <div className="container mx-auto max-w-lg px-4 py-6">
      {/* Header */}
      <header className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <Avatar className="size-12 border-2 border-primary/20">
            <AvatarFallback className="bg-primary/10">
              {user.display_name?.[0]?.toUpperCase() || <User className="size-6 text-primary" />}
            </AvatarFallback>
          </Avatar>
          <div>
            <h1 className="text-xl font-semibold text-foreground">{greeting}</h1>
            <p className="text-muted-foreground">
              {dateInfo.day} de {dateInfo.month}
            </p>
          </div>
        </div>
        <Button size="icon" className="rounded-full" onClick={() => setAddDialogOpen(true)}>
          <Plus className="size-5" />
        </Button>
      </header>

      {/* Progress Card */}
      <Card className="mb-6 bg-gradient-to-br from-primary/5 to-primary/10 border-primary/20">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg flex items-center gap-2">
            <Target className="size-5 text-primary" />
            Progreso de hoy
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-6">
            <div className="relative size-24 flex-shrink-0">
              <svg className="size-full -rotate-90" viewBox="0 0 100 100">
                <circle
                  cx="50" cy="50" r="40"
                  fill="none" stroke="currentColor" strokeWidth="8"
                  className="text-primary/20"
                />
                <circle
                  cx="50" cy="50" r="40"
                  fill="none" stroke="currentColor" strokeWidth="8" strokeLinecap="round"
                  className="text-primary transition-all duration-500"
                  strokeDasharray={`${overallProgress * 2.51} 251`}
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center">
                <span className="text-2xl font-bold text-foreground">{overallProgress}%</span>
              </div>
            </div>

            <div className="flex-1 space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Metas</span>
                <span className="font-semibold text-foreground">
                  {completedGoals}/{totalGoals}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Tareas</span>
                <span className="font-semibold text-foreground">
                  {completedCount}/{totalCount}
                </span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Task List */}
      {tasksLoading ? (
        <div className="flex justify-center py-12">
          <Loader2 className="size-8 animate-spin text-primary" />
        </div>
      ) : tasks.length === 0 ? (
        <EmptyState onAddTask={() => setAddDialogOpen(true)} />
      ) : (
        <div className="space-y-6">
          {/* Pending Tasks */}
          {pendingTasks.length > 0 && (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-semibold text-foreground">
                  Pendientes
                </h2>
                <Badge variant="secondary">{pendingTasks.length}</Badge>
              </div>
              {pendingTasks.map((task) => (
                <TaskCard
                  key={task.id}
                  task={task}
                  onToggle={() => toggleComplete(task.id)}
                  onDelete={() => handleDeleteTask(task.id)}
                />
              ))}
            </div>
          )}

          {/* Completed Tasks */}
          {completedTasks.length > 0 && (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <h2 className="text-base font-medium text-muted-foreground">
                  Completadas
                </h2>
                <Badge variant="outline" className="text-muted-foreground">
                  {completedTasks.length}
                </Badge>
              </div>
              {completedTasks.map((task) => (
                <TaskCard
                  key={task.id}
                  task={task}
                  onToggle={() => toggleComplete(task.id)}
                  onDelete={() => handleDeleteTask(task.id)}
                />
              ))}
            </div>
          )}

          {/* All completed message */}
          {pendingTasks.length === 0 && completedTasks.length > 0 && (
            <Card className="bg-gradient-to-br from-green-500/10 to-emerald-500/5 border-green-500/20">
              <CardContent className="py-6 text-center">
                <div className="size-12 mx-auto mb-3 rounded-full bg-green-500/20 flex items-center justify-center">
                  <CheckCircle2 className="size-6 text-green-600" />
                </div>
                <h3 className="font-semibold text-green-700 dark:text-green-400">
                  Excelente trabajo!
                </h3>
                <p className="text-sm text-muted-foreground mt-1">
                  Completaste todas tus tareas de hoy
                </p>
              </CardContent>
            </Card>
          )}
        </div>
      )}

      {/* Floating Add Button (when tasks exist) */}
      {tasks.length > 0 && (
        <Button
          size="lg"
          className="fixed bottom-24 right-4 rounded-full size-14 shadow-lg"
          onClick={() => setAddDialogOpen(true)}
        >
          <Plus className="size-6" />
        </Button>
      )}

      {/* Add Task Dialog */}
      <Dialog open={addDialogOpen} onOpenChange={setAddDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Nueva tarea</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 pt-4">
            <Input
              placeholder="Titulo de la tarea"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              autoFocus
            />

            <Select value={newCategory} onValueChange={setNewCategory}>
              <SelectTrigger>
                <SelectValue placeholder="Categoria" />
              </SelectTrigger>
              <SelectContent>
                {Object.entries(categoryConfig).map(([key, config]) => (
                  <SelectItem key={key} value={key}>
                    <div className="flex items-center gap-2">
                      <div className={`size-3 rounded-full ${config.color}`} />
                      {config.name}
                    </div>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Select value={newRecurrence} onValueChange={(v) => setNewRecurrence(v as RecurrenceFrequency)}>
              <SelectTrigger>
                <SelectValue placeholder="Recurrencia" />
              </SelectTrigger>
              <SelectContent>
                {RECURRENCE_OPTIONS.map((opt) => (
                  <SelectItem key={opt.value} value={opt.value}>
                    {opt.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <div className="flex items-center gap-2">
              <Checkbox
                id="isGoal"
                checked={newIsGoal}
                onCheckedChange={(checked) => setNewIsGoal(!!checked)}
              />
              <label htmlFor="isGoal" className="text-sm">
                Es una meta con progreso
              </label>
            </div>

            {newIsGoal && (
              <Input
                type="number"
                placeholder="Meta (ej: 30 minutos)"
                value={newTarget}
                onChange={(e) => setNewTarget(e.target.value)}
              />
            )}

            <Button onClick={handleAddTask} className="w-full" disabled={creating}>
              {creating ? (
                <>
                  <Loader2 className="size-4 mr-2 animate-spin" />
                  Creando...
                </>
              ) : (
                "Agregar tarea"
              )}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// Empty state component
function EmptyState({ onAddTask }: { onAddTask: () => void }) {
  return (
    <Card className="border-dashed">
      <CardContent className="py-12">
        <div className="text-center">
          {/* Illustration */}
          <div className="relative mx-auto mb-6 size-32">
            <div className="absolute inset-0 bg-gradient-to-br from-primary/20 to-primary/5 rounded-full" />
            <div className="absolute inset-4 bg-gradient-to-br from-primary/30 to-primary/10 rounded-full flex items-center justify-center">
              <Sparkles className="size-12 text-primary" />
            </div>
            {/* Decorative elements */}
            <div className="absolute -top-1 -right-1 size-6 bg-orange-400 rounded-full flex items-center justify-center">
              <Calendar className="size-3 text-white" />
            </div>
            <div className="absolute -bottom-1 -left-1 size-5 bg-green-400 rounded-full flex items-center justify-center">
              <CheckCircle2 className="size-3 text-white" />
            </div>
          </div>

          {/* Message */}
          <h3 className="text-xl font-semibold mb-2">
            Empieza tu dia productivo
          </h3>
          <p className="text-muted-foreground mb-6 max-w-xs mx-auto">
            Agrega tu primera tarea y comienza a construir habitos positivos
          </p>

          {/* CTA Button */}
          <Button size="lg" onClick={onAddTask} className="gap-2">
            <Plus className="size-5" />
            Agregar primera tarea
          </Button>

          {/* Tips */}
          <div className="mt-8 pt-6 border-t">
            <p className="text-xs text-muted-foreground mb-3">Ideas para comenzar:</p>
            <div className="flex flex-wrap justify-center gap-2">
              {["Meditar 10 min", "Leer 20 paginas", "Ejercicio", "Estudiar"].map((tip) => (
                <span
                  key={tip}
                  className="px-3 py-1 bg-muted rounded-full text-xs text-muted-foreground"
                >
                  {tip}
                </span>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

// Task card component
function TaskCard({
  task,
  onToggle,
  onDelete,
}: {
  task: {
    id: string;
    title: string;
    color?: string | null;
    has_progress?: boolean;
    progress_target?: number | null;
    progress_unit?: string | null;
    completion?: {
      status?: string;
      progress_value?: number | null;
    } | null;
  };
  onToggle: () => void;
  onDelete: () => void;
}) {
  const isCompleted = task.completion?.status === "completed";
  const categoryKey = (task.color || "personal") as keyof typeof categoryConfig;
  const category = categoryConfig[categoryKey] || categoryConfig.personal;
  const CategoryIcon = category.icon;
  const goalProgress =
    task.has_progress && task.completion?.progress_value && task.progress_target
      ? Math.round((task.completion.progress_value / task.progress_target) * 100)
      : 0;

  return (
    <Card
      className={`border-l-4 ${category.borderColor} transition-all hover:shadow-md ${
        isCompleted ? "opacity-60" : ""
      }`}
    >
      <CardContent className="py-4 px-4">
        <div className="flex items-center gap-4">
          <Checkbox
            checked={isCompleted}
            onCheckedChange={onToggle}
            className="size-5"
          />

          <div className="flex-1 min-w-0">
            <p
              className={`font-medium ${
                isCompleted
                  ? "line-through text-muted-foreground"
                  : "text-foreground"
              }`}
            >
              {task.title}
            </p>

            {task.has_progress && task.progress_target && (
              <div className="mt-2 space-y-1">
                <Progress value={goalProgress} className="h-2" />
                <p className="text-xs text-muted-foreground">
                  {task.completion?.progress_value || 0}/{task.progress_target}{" "}
                  {task.progress_unit || "min"}
                </p>
              </div>
            )}
          </div>

          <div
            className={`size-10 rounded-full flex items-center justify-center ${category.color}/10`}
          >
            <CategoryIcon
              className={`size-5 ${category.color.replace("bg-", "text-")}`}
            />
          </div>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="size-8">
                <MoreVertical className="size-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={onDelete}>
                <Trash2 className="size-4 mr-2 text-red-500" />
                <span className="text-red-500">Eliminar</span>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardContent>
    </Card>
  );
}
