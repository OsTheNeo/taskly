"use client";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Plus,
  User,
  Target,
  BookOpen,
  Activity,
  Briefcase,
  Sun,
  LogOut,
  Loader2,
} from "lucide-react";
import { useAuth } from "@/lib/hooks/use-auth";
import { useTasks } from "@/lib/hooks/use-tasks";

// Category definitions with colors and icons
const categoryConfig = {
  study: {
    color: "bg-violet-500",
    borderColor: "border-l-violet-500",
    icon: BookOpen,
    name: "Estudio",
  },
  fitness: {
    color: "bg-orange-500",
    borderColor: "border-l-orange-500",
    icon: Activity,
    name: "Fitness",
  },
  mindfulness: {
    color: "bg-cyan-500",
    borderColor: "border-l-cyan-500",
    icon: Sun,
    name: "Mindfulness",
  },
  work: {
    color: "bg-blue-500",
    borderColor: "border-l-blue-500",
    icon: Briefcase,
    name: "Trabajo",
  },
  personal: {
    color: "bg-gray-500",
    borderColor: "border-l-gray-500",
    icon: User,
    name: "Personal",
  },
};

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

// Login Form Component
function LoginForm({ onLogin }: { onLogin: (email: string, name: string) => void }) {
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !name) return;
    setLoading(true);
    await onLogin(email, name);
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle className="text-center">Bienvenido a Taskly</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <Input
                type="text"
                placeholder="Tu nombre"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
            <div>
              <Input
                type="email"
                placeholder="tu@email.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Entrando...
                </>
              ) : (
                "Entrar"
              )}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

// Add Task Dialog
function AddTaskDialog({
  onAdd,
  open,
  onOpenChange,
}: {
  onAdd: (title: string, isGoal: boolean, target?: number) => void;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const [title, setTitle] = useState("");
  const [isGoal, setIsGoal] = useState(false);
  const [target, setTarget] = useState("");

  const handleSubmit = () => {
    if (!title.trim()) return;
    onAdd(title, isGoal, isGoal ? parseInt(target) || 30 : undefined);
    setTitle("");
    setIsGoal(false);
    setTarget("");
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Nueva tarea</DialogTitle>
        </DialogHeader>
        <div className="space-y-4 pt-4">
          <Input
            placeholder="Titulo de la tarea"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            autoFocus
          />
          <div className="flex items-center gap-2">
            <Checkbox
              id="isGoal"
              checked={isGoal}
              onCheckedChange={(checked) => setIsGoal(!!checked)}
            />
            <label htmlFor="isGoal" className="text-sm">
              Es una meta con progreso
            </label>
          </div>
          {isGoal && (
            <Input
              type="number"
              placeholder="Meta (ej: 30 minutos)"
              value={target}
              onChange={(e) => setTarget(e.target.value)}
            />
          )}
          <Button onClick={handleSubmit} className="w-full">
            Agregar tarea
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

export default function AppDashboard() {
  const { user, loading: authLoading, login, logout, getFirebaseUid } = useAuth();
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
  } = useTasks(firebaseUid);

  const [greeting, setGreeting] = useState(getGreeting());
  const [dateInfo, setDateInfo] = useState(getFormattedDate());
  const [addDialogOpen, setAddDialogOpen] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      setGreeting(getGreeting());
      setDateInfo(getFormattedDate());
    }, 60000);
    return () => clearInterval(interval);
  }, []);

  const handleAddTask = async (title: string, isGoal: boolean, target?: number) => {
    await addTask({
      title,
      task_type: isGoal ? "goal" : "task",
      has_progress: isGoal,
      progress_target: target,
      progress_unit: "min",
    });
  };

  // Show login if not authenticated
  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!user) {
    return <LoginForm onLogin={login} />;
  }

  const overallProgress = totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0;

  return (
    <div className="min-h-screen bg-background">
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
          <div className="flex gap-2">
            <Button size="icon" variant="outline" onClick={logout}>
              <LogOut className="size-4" />
            </Button>
            <Button size="icon" className="rounded-full" onClick={() => setAddDialogOpen(true)}>
              <Plus className="size-5" />
            </Button>
          </div>
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
              {/* Circular Progress */}
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

              {/* Metrics */}
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
        <div className="space-y-3">
          <h2 className="text-lg font-semibold text-foreground mb-4">Tareas de hoy</h2>

          {tasksLoading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
            </div>
          ) : tasks.length === 0 ? (
            <Card>
              <CardContent className="py-8 text-center text-muted-foreground">
                No tienes tareas para hoy. Agrega una nueva tarea.
              </CardContent>
            </Card>
          ) : (
            tasks.map((task) => {
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
                  key={task.id}
                  className={`border-l-4 ${category.borderColor} cursor-pointer transition-all hover:shadow-md ${
                    isCompleted ? "opacity-60" : ""
                  }`}
                >
                  <CardContent className="py-4 px-4">
                    <div className="flex items-center gap-4">
                      <Checkbox
                        checked={isCompleted}
                        onCheckedChange={() => toggleComplete(task.id)}
                        onClick={(e) => e.stopPropagation()}
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
                    </div>
                  </CardContent>
                </Card>
              );
            })
          )}
        </div>
      </div>

      {/* Add Task Dialog */}
      <AddTaskDialog
        open={addDialogOpen}
        onOpenChange={setAddDialogOpen}
        onAdd={handleAddTask}
      />
    </div>
  );
}
