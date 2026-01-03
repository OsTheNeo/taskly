"use client";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Plus,
  User,
  Target,
  BookOpen,
  Activity,
  Briefcase,
  Sun,
} from "lucide-react";

// Category definitions with colors and icons
const categories = {
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
};

type CategoryKey = keyof typeof categories;

interface Task {
  id: string;
  title: string;
  category: CategoryKey;
  completed: boolean;
  isGoal: boolean;
  currentProgress?: number;
  targetProgress?: number;
}

// Sample tasks matching the Flutter app
const initialTasks: Task[] = [
  {
    id: "1",
    title: "Leer 30 minutos",
    category: "study",
    completed: false,
    isGoal: true,
    currentProgress: 15,
    targetProgress: 30,
  },
  {
    id: "2",
    title: "Ejercicio",
    category: "fitness",
    completed: false,
    isGoal: true,
    currentProgress: 0,
    targetProgress: 45,
  },
  {
    id: "3",
    title: "Meditar",
    category: "mindfulness",
    completed: true,
    isGoal: false,
  },
  {
    id: "4",
    title: "Revisar correos",
    category: "work",
    completed: false,
    isGoal: false,
  },
];

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour >= 5 && hour < 12) {
    return "Buenos dias";
  } else if (hour >= 12 && hour < 19) {
    return "Buenas tardes";
  } else {
    return "Buenas noches";
  }
}

function getFormattedDate(): { day: number; month: string } {
  const date = new Date();
  const months = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre",
  ];
  return {
    day: date.getDate(),
    month: months[date.getMonth()],
  };
}

export default function AppDashboard() {
  const [tasks, setTasks] = useState<Task[]>(initialTasks);
  const [greeting, setGreeting] = useState(getGreeting());
  const [dateInfo, setDateInfo] = useState(getFormattedDate());

  useEffect(() => {
    // Update greeting every minute
    const interval = setInterval(() => {
      setGreeting(getGreeting());
      setDateInfo(getFormattedDate());
    }, 60000);
    return () => clearInterval(interval);
  }, []);

  const toggleTaskCompletion = (taskId: string) => {
    setTasks((prev) =>
      prev.map((task) =>
        task.id === taskId ? { ...task, completed: !task.completed } : task
      )
    );
  };

  const handleGoalClick = (task: Task) => {
    if (task.isGoal && task.currentProgress !== undefined && task.targetProgress !== undefined) {
      console.log(
        `Progreso de "${task.title}": ${task.currentProgress}/${task.targetProgress}`
      );
      // In a real app, this would open a dialog to update progress
    }
  };

  // Calculate progress metrics
  const completedTasks = tasks.filter((t) => t.completed).length;
  const totalTasks = tasks.length;
  const goals = tasks.filter((t) => t.isGoal);
  const completedGoals = goals.filter((t) => t.completed).length;
  const totalGoals = goals.length;
  const overallProgress =
    totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

  return (
    <div className="min-h-screen bg-background">
      <div className="container mx-auto max-w-lg px-4 py-6">
        {/* Header */}
        <header className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-4">
            <Avatar className="size-12 border-2 border-primary/20">
              <AvatarFallback className="bg-primary/10">
                <User className="size-6 text-primary" />
              </AvatarFallback>
            </Avatar>
            <div>
              <h1 className="text-xl font-semibold text-foreground">
                {greeting}
              </h1>
              <p className="text-muted-foreground">
                {dateInfo.day} de {dateInfo.month}
              </p>
            </div>
          </div>
          <Button size="icon" className="rounded-full">
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
              {/* Circular Progress Indicator */}
              <div className="relative size-24 flex-shrink-0">
                <svg
                  className="size-full -rotate-90"
                  viewBox="0 0 100 100"
                >
                  {/* Background circle */}
                  <circle
                    cx="50"
                    cy="50"
                    r="40"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="8"
                    className="text-primary/20"
                  />
                  {/* Progress circle */}
                  <circle
                    cx="50"
                    cy="50"
                    r="40"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="8"
                    strokeLinecap="round"
                    className="text-primary transition-all duration-500"
                    strokeDasharray={`${overallProgress * 2.51} 251`}
                  />
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-2xl font-bold text-foreground">
                    {overallProgress}%
                  </span>
                </div>
              </div>

              {/* Metrics */}
              <div className="flex-1 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Metas</span>
                  <span className="font-semibold text-foreground">
                    {completedGoals}/{totalGoals} Metas
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Tareas</span>
                  <span className="font-semibold text-foreground">
                    {completedTasks}/{totalTasks} Tareas
                  </span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Task List */}
        <div className="space-y-3">
          <h2 className="text-lg font-semibold text-foreground mb-4">
            Tareas de hoy
          </h2>
          {tasks.map((task) => {
            const category = categories[task.category];
            const CategoryIcon = category.icon;
            const goalProgress =
              task.isGoal && task.currentProgress !== undefined && task.targetProgress !== undefined
                ? Math.round((task.currentProgress / task.targetProgress) * 100)
                : 0;

            return (
              <Card
                key={task.id}
                className={`border-l-4 ${category.borderColor} cursor-pointer transition-all hover:shadow-md ${
                  task.completed ? "opacity-60" : ""
                }`}
                onClick={() => handleGoalClick(task)}
              >
                <CardContent className="py-4 px-4">
                  <div className="flex items-center gap-4">
                    {/* Checkbox */}
                    <Checkbox
                      checked={task.completed}
                      onCheckedChange={() => toggleTaskCompletion(task.id)}
                      onClick={(e) => e.stopPropagation()}
                      className="size-5"
                    />

                    {/* Task content */}
                    <div className="flex-1 min-w-0">
                      <p
                        className={`font-medium ${
                          task.completed
                            ? "line-through text-muted-foreground"
                            : "text-foreground"
                        }`}
                      >
                        {task.title}
                      </p>

                      {/* Goal progress bar */}
                      {task.isGoal && task.currentProgress !== undefined && task.targetProgress !== undefined && (
                        <div className="mt-2 space-y-1">
                          <Progress value={goalProgress} className="h-2" />
                          <p className="text-xs text-muted-foreground">
                            {task.currentProgress}/{task.targetProgress} min
                          </p>
                        </div>
                      )}
                    </div>

                    {/* Category icon */}
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
          })}
        </div>
      </div>
    </div>
  );
}
