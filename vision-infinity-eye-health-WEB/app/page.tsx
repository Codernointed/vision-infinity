import { Suspense } from "react"
import { Loader } from "lucide-react"
import HomeScreen from "@/components/home-screen"

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col bg-white">
      <Suspense fallback={<Loader className="animate-spin h-8 w-8 text-blue-600 mt-20" />}>
        <HomeScreen />
      </Suspense>
    </main>
  )
}

