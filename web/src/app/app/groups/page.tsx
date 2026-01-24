"use client";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Users, Plus, Link2, Copy, Loader2, CheckCircle } from "lucide-react";
import { useAuth } from "@/lib/hooks/use-auth";
import * as dataService from "@/lib/supabase/data-service";

interface Household {
  id: string;
  name: string;
  description?: string;
  invite_code: string;
  created_at: string;
}

export default function GroupsPage() {
  const { getFirebaseUid } = useAuth();
  const firebaseUid = getFirebaseUid();

  const [households, setHouseholds] = useState<Household[]>([]);
  const [loading, setLoading] = useState(true);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [joinDialogOpen, setJoinDialogOpen] = useState(false);
  const [newGroupName, setNewGroupName] = useState("");
  const [joinCode, setJoinCode] = useState("");
  const [creating, setCreating] = useState(false);
  const [joining, setJoining] = useState(false);
  const [copiedCode, setCopiedCode] = useState<string | null>(null);

  useEffect(() => {
    if (firebaseUid) loadHouseholds();
  }, [firebaseUid]);

  const loadHouseholds = async () => {
    if (!firebaseUid) return;
    setLoading(true);
    const data = await dataService.getHouseholds(firebaseUid);
    setHouseholds(data as Household[]);
    setLoading(false);
  };

  const handleCreateGroup = async () => {
    if (!firebaseUid || !newGroupName.trim()) return;
    setCreating(true);

    const result = await dataService.createHousehold({
      firebaseUid,
      name: newGroupName.trim(),
    });

    if (result) {
      setNewGroupName("");
      setCreateDialogOpen(false);
      loadHouseholds();
    }
    setCreating(false);
  };

  const handleJoinGroup = async () => {
    if (!firebaseUid || !joinCode.trim()) return;
    setJoining(true);

    const result = await dataService.joinHousehold({
      firebaseUid,
      inviteCode: joinCode.trim(),
    });

    if (result) {
      setJoinCode("");
      setJoinDialogOpen(false);
      loadHouseholds();
    }
    setJoining(false);
  };

  const copyInviteCode = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopiedCode(code);
    setTimeout(() => setCopiedCode(null), 2000);
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
        <h1 className="text-2xl font-bold">Grupos</h1>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={() => setJoinDialogOpen(true)}>
            <Link2 className="size-4 mr-1" />
            Unirse
          </Button>
          <Button size="sm" onClick={() => setCreateDialogOpen(true)}>
            <Plus className="size-4 mr-1" />
            Crear
          </Button>
        </div>
      </header>

      {households.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <Users className="size-12 mx-auto text-muted-foreground mb-4" />
            <h3 className="text-lg font-medium mb-2">No tienes grupos</h3>
            <p className="text-muted-foreground mb-4">
              Crea un grupo para compartir tareas con familia o amigos
            </p>
            <Button onClick={() => setCreateDialogOpen(true)}>
              <Plus className="size-4 mr-2" />
              Crear grupo
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {households.map((household) => (
            <Card key={household.id} className="cursor-pointer hover:shadow-md transition-shadow">
              <CardHeader className="pb-2">
                <div className="flex items-center gap-3">
                  <Avatar className="size-12 bg-primary/10">
                    <AvatarFallback className="text-primary font-semibold">
                      {household.name.substring(0, 2).toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <CardTitle className="text-lg">{household.name}</CardTitle>
                    {household.description && (
                      <p className="text-sm text-muted-foreground">{household.description}</p>
                    )}
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between bg-muted/50 rounded-lg px-3 py-2">
                  <div>
                    <p className="text-xs text-muted-foreground">Codigo de invitacion</p>
                    <p className="font-mono font-semibold">{household.invite_code}</p>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => copyInviteCode(household.invite_code)}
                  >
                    {copiedCode === household.invite_code ? (
                      <CheckCircle className="size-4 text-green-500" />
                    ) : (
                      <Copy className="size-4" />
                    )}
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Create Dialog */}
      <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Crear grupo</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 pt-4">
            <Input
              placeholder="Nombre del grupo"
              value={newGroupName}
              onChange={(e) => setNewGroupName(e.target.value)}
              autoFocus
            />
            <Button onClick={handleCreateGroup} className="w-full" disabled={creating}>
              {creating ? (
                <>
                  <Loader2 className="size-4 mr-2 animate-spin" />
                  Creando...
                </>
              ) : (
                "Crear grupo"
              )}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Join Dialog */}
      <Dialog open={joinDialogOpen} onOpenChange={setJoinDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Unirse a un grupo</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 pt-4">
            <Input
              placeholder="Codigo de invitacion"
              value={joinCode}
              onChange={(e) => setJoinCode(e.target.value)}
              autoFocus
            />
            <Button onClick={handleJoinGroup} className="w-full" disabled={joining}>
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
    </div>
  );
}
