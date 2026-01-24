"use client";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
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
  Rocket,
  Plus,
  Link2,
  Trophy,
  Target,
  Flame,
  Star,
  Loader2,
  Copy,
  Users,
} from "lucide-react";
import { useAuth } from "@/lib/hooks/use-auth";
import * as dataService from "@/lib/supabase/data-service";

const CHALLENGE_TYPES = [
  { value: "completion", label: "Completar tareas", icon: Target },
  { value: "streak", label: "Mantener racha", icon: Flame },
  { value: "perfect_day", label: "Dias perfectos", icon: Star },
];

const EMOJIS = ["🏆", "🎯", "🔥", "⭐", "💪", "🚀", "🎖️", "👑", "💎", "🌟"];

export default function ChallengesPage() {
  const { getFirebaseUid } = useAuth();
  const firebaseUid = getFirebaseUid();

  const [myChallenges, setMyChallenges] = useState<Record<string, unknown>[]>([]);
  const [availableChallenges, setAvailableChallenges] = useState<Record<string, unknown>[]>([]);
  const [stats, setStats] = useState<Record<string, unknown>>({});
  const [loading, setLoading] = useState(true);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [joinDialogOpen, setJoinDialogOpen] = useState(false);
  const [selectedChallenge, setSelectedChallenge] = useState<Record<string, unknown> | null>(null);
  const [leaderboard, setLeaderboard] = useState<Record<string, unknown>[]>([]);

  // Create form state
  const [newTitle, setNewTitle] = useState("");
  const [newEmoji, setNewEmoji] = useState("🏆");
  const [newType, setNewType] = useState("completion");
  const [newTarget, setNewTarget] = useState("10");
  const [newDays, setNewDays] = useState("7");
  const [creating, setCreating] = useState(false);
  const [joinCode, setJoinCode] = useState("");
  const [joining, setJoining] = useState(false);

  useEffect(() => {
    if (firebaseUid) loadData();
  }, [firebaseUid]);

  const loadData = async () => {
    if (!firebaseUid) return;
    setLoading(true);

    const [my, available, statsData] = await Promise.all([
      dataService.getMyChallenges(firebaseUid),
      dataService.getAvailableChallenges(firebaseUid),
      dataService.getChallengeStats(firebaseUid),
    ]);

    setMyChallenges(my);
    setAvailableChallenges(available);
    setStats(statsData);
    setLoading(false);
  };

  const handleCreate = async () => {
    if (!firebaseUid || !newTitle.trim()) return;
    setCreating(true);

    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + parseInt(newDays));

    const result = await dataService.createChallenge({
      firebaseUid,
      title: newTitle.trim(),
      emoji: newEmoji,
      challengeType: newType,
      targetValue: parseInt(newTarget),
      startDate: startDate.toISOString().split("T")[0],
      endDate: endDate.toISOString().split("T")[0],
      visibility: "public",
    });

    if (result) {
      setNewTitle("");
      setCreateDialogOpen(false);
      loadData();
    }
    setCreating(false);
  };

  const handleJoin = async () => {
    if (!firebaseUid || !joinCode.trim()) return;
    setJoining(true);

    const result = await dataService.joinChallengeByCode({
      firebaseUid,
      inviteCode: joinCode.trim(),
    });

    if (result) {
      setJoinCode("");
      setJoinDialogOpen(false);
      loadData();
    }
    setJoining(false);
  };

  const handleJoinChallenge = async (challengeId: string) => {
    if (!firebaseUid) return;
    await dataService.joinChallenge({ firebaseUid, challengeId });
    loadData();
  };

  const openChallengeDetail = async (participation: Record<string, unknown>) => {
    const challenge = participation.challenge as Record<string, unknown>;
    setSelectedChallenge({ ...challenge, participation });

    const lb = await dataService.getChallengeLeaderboard(challenge.id as string);
    setLeaderboard(lb);
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="size-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="container mx-auto max-w-lg px-4 py-6">
      <header className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Retos</h1>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={() => setJoinDialogOpen(true)}>
            <Link2 className="size-4 mr-1" />
            Codigo
          </Button>
          <Button size="sm" onClick={() => setCreateDialogOpen(true)}>
            <Plus className="size-4 mr-1" />
            Crear
          </Button>
        </div>
      </header>

      {/* Stats Card */}
      <Card className="mb-6 bg-gradient-to-br from-primary/5 to-primary/10 border-primary/20">
        <CardContent className="py-4">
          <div className="flex justify-around text-center">
            <div>
              <Rocket className="size-5 mx-auto text-primary mb-1" />
              <p className="text-xl font-bold">{(stats.active_challenges as number) || 0}</p>
              <p className="text-xs text-muted-foreground">Activos</p>
            </div>
            <div>
              <Trophy className="size-5 mx-auto text-primary mb-1" />
              <p className="text-xl font-bold">{(stats.challenges_won as number) || 0}</p>
              <p className="text-xs text-muted-foreground">Ganados</p>
            </div>
            <div>
              <Star className="size-5 mx-auto text-primary mb-1" />
              <p className="text-xl font-bold">{(stats.total_points as number) || 0}</p>
              <p className="text-xs text-muted-foreground">Puntos</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Tabs defaultValue="my" className="space-y-4">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="my">Mis retos ({myChallenges.length})</TabsTrigger>
          <TabsTrigger value="discover">Descubrir</TabsTrigger>
        </TabsList>

        <TabsContent value="my" className="space-y-4">
          {myChallenges.length === 0 ? (
            <Card>
              <CardContent className="py-12 text-center">
                <Rocket className="size-12 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-lg font-medium mb-2">No tienes retos activos</h3>
                <p className="text-muted-foreground mb-4">
                  Crea uno o unete a un reto existente
                </p>
                <Button onClick={() => setCreateDialogOpen(true)}>
                  <Plus className="size-4 mr-2" />
                  Crear reto
                </Button>
              </CardContent>
            </Card>
          ) : (
            myChallenges.map((participation) => {
              const challenge = participation.challenge as Record<string, unknown>;
              const currentScore = Number(participation.current_score) || 0;
              const targetValue = Number(challenge.target_value) || 1;
              const progress = Math.min((currentScore / targetValue) * 100, 100);
              const endDate = new Date(String(challenge.end_date));
              const daysLeft = Math.max(0, Math.ceil((endDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24)));

              return (
                <Card
                  key={String(challenge.id)}
                  className="cursor-pointer hover:shadow-md transition-shadow"
                  onClick={() => openChallengeDetail(participation)}
                >
                  <CardContent className="py-4">
                    <div className="flex items-center gap-3 mb-3">
                      <span className="text-3xl">{String(challenge.emoji)}</span>
                      <div className="flex-1">
                        <h3 className="font-semibold">{String(challenge.title)}</h3>
                        <p className="text-sm text-muted-foreground">
                          {currentScore} / {targetValue} completados
                        </p>
                      </div>
                      <Badge variant="secondary">
                        {daysLeft > 0 ? `${daysLeft} dias` : "Hoy"}
                      </Badge>
                    </div>
                    <Progress value={progress} className="h-2" />
                  </CardContent>
                </Card>
              );
            })
          )}
        </TabsContent>

        <TabsContent value="discover" className="space-y-4">
          {/* Join by code card */}
          <Card>
            <CardContent className="py-4">
              <div className="flex items-center gap-3">
                <div className="size-10 rounded-full bg-primary/10 flex items-center justify-center">
                  <Link2 className="size-5 text-primary" />
                </div>
                <div className="flex-1">
                  <p className="font-medium">Unirse con codigo</p>
                  <p className="text-sm text-muted-foreground">Ingresa el codigo del reto</p>
                </div>
                <Button variant="outline" size="sm" onClick={() => setJoinDialogOpen(true)}>
                  Unirse
                </Button>
              </div>
            </CardContent>
          </Card>

          {availableChallenges.length === 0 ? (
            <Card>
              <CardContent className="py-8 text-center text-muted-foreground">
                No hay retos disponibles
              </CardContent>
            </Card>
          ) : (
            availableChallenges.map((challenge) => (
              <Card key={String(challenge.id)}>
                <CardContent className="py-4">
                  <div className="flex items-center gap-3">
                    <span className="text-3xl">{String(challenge.emoji)}</span>
                    <div className="flex-1">
                      <h3 className="font-semibold">{String(challenge.title)}</h3>
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <Users className="size-3" />
                        <span>Publico</span>
                      </div>
                    </div>
                    <Button size="sm" onClick={() => handleJoinChallenge(String(challenge.id))}>
                      Unirse
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))
          )}
        </TabsContent>
      </Tabs>

      {/* Create Dialog */}
      <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Crear reto</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 pt-4">
            {/* Emoji selector */}
            <div>
              <p className="text-sm font-medium mb-2">Icono</p>
              <div className="flex flex-wrap gap-2">
                {EMOJIS.map((emoji) => (
                  <button
                    key={emoji}
                    onClick={() => setNewEmoji(emoji)}
                    className={`size-10 rounded-lg flex items-center justify-center text-xl transition-colors ${
                      newEmoji === emoji
                        ? "bg-primary/20 ring-2 ring-primary"
                        : "bg-muted hover:bg-muted/80"
                    }`}
                  >
                    {emoji}
                  </button>
                ))}
              </div>
            </div>

            <Input
              placeholder="Nombre del reto"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
            />

            <Select value={newType} onValueChange={setNewType}>
              <SelectTrigger>
                <SelectValue placeholder="Tipo de reto" />
              </SelectTrigger>
              <SelectContent>
                {CHALLENGE_TYPES.map((type) => (
                  <SelectItem key={type.value} value={type.value}>
                    {type.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium mb-2">Objetivo</p>
                <Input
                  type="number"
                  value={newTarget}
                  onChange={(e) => setNewTarget(e.target.value)}
                  min="1"
                />
              </div>
              <div>
                <p className="text-sm font-medium mb-2">Duracion (dias)</p>
                <Input
                  type="number"
                  value={newDays}
                  onChange={(e) => setNewDays(e.target.value)}
                  min="1"
                />
              </div>
            </div>

            <Button onClick={handleCreate} className="w-full" disabled={creating}>
              {creating ? (
                <>
                  <Loader2 className="size-4 mr-2 animate-spin" />
                  Creando...
                </>
              ) : (
                "Crear reto"
              )}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Join Dialog */}
      <Dialog open={joinDialogOpen} onOpenChange={setJoinDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Unirse con codigo</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 pt-4">
            <Input
              placeholder="Codigo del reto"
              value={joinCode}
              onChange={(e) => setJoinCode(e.target.value)}
              autoFocus
            />
            <Button onClick={handleJoin} className="w-full" disabled={joining}>
              {joining ? (
                <>
                  <Loader2 className="size-4 mr-2 animate-spin" />
                  Uniendo...
                </>
              ) : (
                "Unirse"
              )}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Challenge Detail Dialog */}
      <Dialog open={!!selectedChallenge} onOpenChange={() => setSelectedChallenge(null)}>
        <DialogContent className="max-h-[80vh] overflow-y-auto">
          {selectedChallenge && (
            <ChallengeDetailContent
              challenge={selectedChallenge}
              leaderboard={leaderboard}
            />
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

function ChallengeDetailContent({
  challenge,
  leaderboard,
}: {
  challenge: Record<string, unknown>;
  leaderboard: Record<string, unknown>[];
}) {
  const emoji = String(challenge.emoji || "🏆");
  const title = String(challenge.title || "Reto");
  const targetValue = Number(challenge.target_value) || 0;
  const endDate = String(challenge.end_date || "");
  const inviteCode = challenge.invite_code ? String(challenge.invite_code) : null;

  const daysLeft = Math.max(
    0,
    Math.ceil((new Date(endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
  );

  return (
    <>
      <DialogHeader>
        <div className="text-center">
          <span className="text-5xl mb-2 block">{emoji}</span>
          <DialogTitle>{title}</DialogTitle>
        </div>
      </DialogHeader>

      <div className="space-y-4 pt-4">
        {/* Stats */}
        <div className="flex justify-around text-center py-4 bg-muted/50 rounded-lg">
          <div>
            <p className="text-2xl font-bold">{targetValue}</p>
            <p className="text-xs text-muted-foreground">Objetivo</p>
          </div>
          <div>
            <p className="text-2xl font-bold">{daysLeft}</p>
            <p className="text-xs text-muted-foreground">Dias</p>
          </div>
          <div>
            <p className="text-2xl font-bold">{leaderboard.length}</p>
            <p className="text-xs text-muted-foreground">Jugadores</p>
          </div>
        </div>

        {/* Invite code */}
        {inviteCode && (
          <div className="flex items-center justify-between bg-muted/50 rounded-lg px-4 py-3">
            <div>
              <p className="text-xs text-muted-foreground">Codigo para invitar</p>
              <p className="font-mono font-bold text-lg">{inviteCode.toUpperCase()}</p>
            </div>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigator.clipboard.writeText(inviteCode)}
            >
              <Copy className="size-4" />
            </Button>
          </div>
        )}

        {/* Leaderboard */}
        <div>
          <h3 className="font-semibold mb-3">Clasificacion</h3>
          <div className="space-y-2">
            {leaderboard.map((participant, index) => {
              const medals = ["🥇", "🥈", "🥉"];
              const displayName = String(participant.display_name || "Usuario");
              const userId = String(participant.user_id || index);
              const currentScore = Number(participant.current_score) || 0;
              const goalReached = Boolean(participant.goal_reached);

              return (
                <div
                  key={userId}
                  className="flex items-center gap-3 p-3 rounded-lg bg-muted/30"
                >
                  <span className="w-8 text-center font-semibold">
                    {index < 3 ? medals[index] : `#${index + 1}`}
                  </span>
                  <div className="size-8 rounded-full bg-primary/10 flex items-center justify-center font-semibold text-sm">
                    {displayName[0].toUpperCase()}
                  </div>
                  <div className="flex-1">
                    <p className="font-medium">{displayName}</p>
                    <p className="text-sm text-muted-foreground">
                      {currentScore} / {targetValue}
                    </p>
                  </div>
                  {goalReached && (
                    <Badge variant="secondary" className="bg-green-500/10 text-green-600">
                      Completado
                    </Badge>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </>
  );
}
