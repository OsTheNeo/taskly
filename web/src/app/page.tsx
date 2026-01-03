import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  CheckCircle2,
  Target,
  Users,
  Calendar,
  Bell,
  Smartphone,
  ArrowRight,
  Check,
  Star,
} from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <div className="flex items-center gap-8">
            {/* Logo */}
            <a href="/" className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded bg-black">
                <Check className="h-5 w-5 text-white" />
              </div>
              <span className="text-xl font-bold">Taskly</span>
            </a>
            {/* Nav Links */}
            <nav className="hidden md:flex items-center gap-6">
              <a
                href="#caracteristicas"
                className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
              >
                Caracteristicas
              </a>
              <a
                href="#como-funciona"
                className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
              >
                Como funciona
              </a>
            </nav>
          </div>
          {/* Auth Buttons */}
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="sm">
              Iniciar sesion
            </Button>
            <Button size="sm">Registrarse</Button>
          </div>
        </div>
      </header>

      <main>
        {/* Hero Section */}
        <section className="container mx-auto px-4 py-20 md:py-32">
          <div className="grid gap-12 lg:grid-cols-2 lg:gap-8 items-center">
            <div className="flex flex-col gap-6">
              <Badge variant="secondary" className="w-fit">
                <Star className="h-3 w-3" />
                Nueva version disponible
              </Badge>
              <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl">
                Organiza tu vida, alcanza tus{" "}
                <span className="text-primary">metas</span>
              </h1>
              <p className="text-lg text-muted-foreground max-w-md">
                La herramienta de gestion de tareas que te ayuda a mantener el
                control de tus proyectos personales y profesionales. Simple,
                potente y siempre contigo.
              </p>
              <div className="flex flex-col sm:flex-row gap-3">
                <Button size="lg">
                  Comenzar gratis
                  <ArrowRight className="h-4 w-4" />
                </Button>
                <Button variant="outline" size="lg">
                  Ver caracteristicas
                </Button>
              </div>
            </div>
            {/* Preview Cards */}
            <div className="relative">
              <div className="flex flex-col gap-4">
                <Card className="border-l-4 border-l-violet-500">
                  <CardContent className="py-4">
                    <div className="flex items-center gap-3">
                      <CheckCircle2 className="h-5 w-5 text-violet-500" />
                      <div>
                        <p className="font-medium">Revisar informe mensual</p>
                        <p className="text-sm text-muted-foreground">
                          Trabajo - Vence hoy
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
                <Card className="border-l-4 border-l-orange-500">
                  <CardContent className="py-4">
                    <div className="flex items-center gap-3">
                      <Target className="h-5 w-5 text-orange-500" />
                      <div>
                        <p className="font-medium">Correr 5km diarios</p>
                        <p className="text-sm text-muted-foreground">
                          Meta personal - 60% completado
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
                <Card className="border-l-4 border-l-cyan-500">
                  <CardContent className="py-4">
                    <div className="flex items-center gap-3">
                      <Users className="h-5 w-5 text-cyan-500" />
                      <div>
                        <p className="font-medium">Planificar viaje en grupo</p>
                        <p className="text-sm text-muted-foreground">
                          Compartido - 3 participantes
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
          </div>
        </section>

        {/* Features Section */}
        <section
          id="caracteristicas"
          className="container mx-auto px-4 py-20 md:py-32"
        >
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl mb-4">
              Todo lo que necesitas para ser productivo
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Taskly combina las mejores herramientas de productividad en una
              sola aplicacion intuitiva y facil de usar.
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            <Card>
              <CardHeader>
                <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 mb-2">
                  <CheckCircle2 className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Tareas personales</CardTitle>
                <CardDescription>
                  Organiza tus tareas diarias con listas personalizadas,
                  prioridades y fechas de vencimiento.
                </CardDescription>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader>
                <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 mb-2">
                  <Target className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Metas con progreso</CardTitle>
                <CardDescription>
                  Define objetivos a largo plazo y visualiza tu progreso con
                  graficos e indicadores claros.
                </CardDescription>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader>
                <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 mb-2">
                  <Users className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Tareas grupales</CardTitle>
                <CardDescription>
                  Colabora con tu equipo, asigna tareas y mantente sincronizado
                  en tiempo real.
                </CardDescription>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader>
                <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 mb-2">
                  <Calendar className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Recurrencia flexible</CardTitle>
                <CardDescription>
                  Configura tareas que se repiten diaria, semanal o mensualmente
                  con total flexibilidad.
                </CardDescription>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader>
                <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 mb-2">
                  <Bell className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Recordatorios</CardTitle>
                <CardDescription>
                  Nunca olvides una tarea importante con notificaciones
                  inteligentes y personalizables.
                </CardDescription>
              </CardHeader>
            </Card>
            <Card>
              <CardHeader>
                <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10 mb-2">
                  <Smartphone className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Multiplataforma</CardTitle>
                <CardDescription>
                  Accede a tus tareas desde cualquier dispositivo: web, movil o
                  escritorio.
                </CardDescription>
              </CardHeader>
            </Card>
          </div>
        </section>

        {/* How it Works Section */}
        <section
          id="como-funciona"
          className="container mx-auto px-4 py-20 md:py-32"
        >
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl mb-4">
              Como funciona
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Empieza a organizar tu vida en solo tres sencillos pasos.
            </p>
          </div>
          <div className="grid gap-8 md:grid-cols-3">
            <div className="flex flex-col items-center text-center">
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary text-primary-foreground text-2xl font-bold mb-4">
                1
              </div>
              <h3 className="text-xl font-semibold mb-2">Crea tu cuenta</h3>
              <p className="text-muted-foreground">
                Registrate gratis en segundos con tu correo electronico o cuenta
                de Google.
              </p>
            </div>
            <div className="flex flex-col items-center text-center">
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary text-primary-foreground text-2xl font-bold mb-4">
                2
              </div>
              <h3 className="text-xl font-semibold mb-2">Anade tus tareas</h3>
              <p className="text-muted-foreground">
                Crea listas, establece prioridades y organiza tus proyectos como
                prefieras.
              </p>
            </div>
            <div className="flex flex-col items-center text-center">
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary text-primary-foreground text-2xl font-bold mb-4">
                3
              </div>
              <h3 className="text-xl font-semibold mb-2">Alcanza tus metas</h3>
              <p className="text-muted-foreground">
                Completa tus tareas, sigue tu progreso y celebra tus logros.
              </p>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="bg-foreground text-background">
          <div className="container mx-auto px-4 py-20 md:py-32">
            <div className="flex flex-col items-center text-center gap-6">
              <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
                Empieza a ser mas productivo hoy
              </h2>
              <p className="text-lg opacity-80 max-w-2xl">
                Unete a miles de usuarios que ya han transformado su forma de
                trabajar con Taskly. Es gratis para siempre.
              </p>
              <Button
                size="lg"
                variant="secondary"
                className="bg-background text-foreground hover:bg-background/90"
              >
                Comenzar gratis
                <ArrowRight className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t">
        <div className="container mx-auto px-4 py-12">
          <div className="grid gap-8 md:grid-cols-4">
            <div className="flex flex-col gap-4">
              <a href="/" className="flex items-center gap-2">
                <div className="flex h-8 w-8 items-center justify-center rounded bg-black">
                  <Check className="h-5 w-5 text-white" />
                </div>
                <span className="text-xl font-bold">Taskly</span>
              </a>
              <p className="text-sm text-muted-foreground">
                La herramienta de productividad que te ayuda a alcanzar tus
                metas.
              </p>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Producto</h4>
              <ul className="space-y-2 text-sm text-muted-foreground">
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Caracteristicas
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Precios
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Integraciones
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Empresa</h4>
              <ul className="space-y-2 text-sm text-muted-foreground">
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Sobre nosotros
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Blog
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Contacto
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Legal</h4>
              <ul className="space-y-2 text-sm text-muted-foreground">
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Privacidad
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Terminos
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-foreground transition-colors">
                    Cookies
                  </a>
                </li>
              </ul>
            </div>
          </div>
          <div className="border-t mt-8 pt-8 text-center text-sm text-muted-foreground">
            <p>&copy; 2026 Taskly. Todos los derechos reservados.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
